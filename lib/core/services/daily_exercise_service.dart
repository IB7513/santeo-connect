// core/services/daily_exercise_service.dart
// Service exercice du jour SANTEO Connect
// Architecture : catalogue Firestore extensible + anti-répétition + filtre profil

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/exercise.dart';

class DailyExerciseService {
  static final DailyExerciseService _instance = DailyExerciseService._internal();
  factory DailyExerciseService() => _instance;
  DailyExerciseService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Clés SharedPreferences ────────────────────────────────────────────────
  static const _keyDailyExerciseId   = 'daily_exercise_id';
  static const _keyDailyExerciseDate = 'daily_exercise_date';
  static const _keyRecentExercises   = 'recent_exercise_ids'; // JSON list
  static const _keyStreak            = 'daily_exercise_streak';
  static const _keyLastCompletedDate = 'daily_exercise_last_completed';

  // ── Obtenir l'exercice du jour ────────────────────────────────────────────
  /// Retourne l'exercice du jour.
  /// - Même exercice toute la journée (stocké en SharedPreferences)
  /// - Anti-répétition sur les 7 derniers jours
  /// - Filtre optionnel par profil utilisateur
  Future<Exercise?> getDailyExercise({
    String? userProfile,       // ex: 'sedentaire', 'senior', etc.
    ExerciseDifficulty? difficulte,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _todayString();

      // ── 1. Vérifier si on a déjà sélectionné un exercice aujourd'hui ─────
      final storedDate = prefs.getString(_keyDailyExerciseDate);
      final storedId   = prefs.getString(_keyDailyExerciseId);

      if (storedDate == today && storedId != null && storedId.isNotEmpty) {
        // Récupérer l'exercice depuis Firestore
        final doc = await _db.collection('exercises').doc(storedId).get();
        if (doc.exists && doc.data() != null) {
          return Exercise.fromFirestore(doc.data()!, doc.id);
        }
      }

      // ── 2. Sélectionner un nouvel exercice ────────────────────────────────
      final exercise = await _selectNewExercise(prefs, userProfile, difficulte);
      if (exercise != null) {
        await prefs.setString(_keyDailyExerciseId, exercise.id);
        await prefs.setString(_keyDailyExerciseDate, today);
        await _addToRecent(prefs, exercise.id);
      }
      return exercise;

    } catch (e) {
      if (kDebugMode) debugPrint('DailyExerciseService.getDailyExercise error: $e');
      return null;
    }
  }

  // ── Sélection intelligente ────────────────────────────────────────────────
  Future<Exercise?> _selectNewExercise(
    SharedPreferences prefs,
    String? userProfile,
    ExerciseDifficulty? difficulte,
  ) async {
    // Récupérer les IDs récents (anti-répétition)
    final recentIds = _getRecentIds(prefs);

    // Requête Firestore : exercices actifs uniquement
    // On évite les requêtes composites pour ne pas nécessiter d'index
    Query query = _db.collection('exercises').where('actif', isEqualTo: true);

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) return null;

    // Convertir en objets Exercise
    var exercises = snapshot.docs
        .map((doc) => Exercise.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    // ── Filtre profil utilisateur (en mémoire) ────────────────────────────
    if (userProfile != null && userProfile != 'tous') {
      final target = _parseTarget(userProfile);
      final filtered = exercises.where((e) =>
        e.cibles.contains(ExerciseTarget.tous) ||
        e.cibles.contains(target)
      ).toList();
      if (filtered.isNotEmpty) exercises = filtered;
    }

    // ── Filtre difficulté (en mémoire) ────────────────────────────────────
    if (difficulte != null) {
      final filtered = exercises.where((e) => e.difficulte == difficulte).toList();
      if (filtered.isNotEmpty) exercises = filtered;
    }

    // ── Anti-répétition : exclure les 7 derniers ──────────────────────────
    final withoutRecent = exercises.where((e) => !recentIds.contains(e.id)).toList();
    final pool = withoutRecent.isNotEmpty ? withoutRecent : exercises;

    // ── Sélection déterministe basée sur la date (même exo toute la journée)
    final dayIndex = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
    final index = dayIndex % pool.length;
    return pool[index];
  }

  // ── Marquer l'exercice comme complété ────────────────────────────────────
  Future<void> markCompleted(String exerciseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _todayString();
      final lastCompleted = prefs.getString(_keyLastCompletedDate);

      // Calculer le streak
      int streak = prefs.getInt(_keyStreak) ?? 0;
      if (lastCompleted == null) {
        streak = 1;
      } else {
        final last = DateTime.parse(lastCompleted);
        final diff = DateTime.now().difference(last).inDays;
        if (diff == 1) {
          streak += 1; // Jour consécutif
        } else if (diff > 1) {
          streak = 1;  // Streak cassé
        }
        // diff == 0 → déjà complété aujourd'hui, pas de changement
      }

      await prefs.setInt(_keyStreak, streak);
      await prefs.setString(_keyLastCompletedDate, today);

      // Sauvegarder dans Firestore (anonyme — pas de user_id)
      // On sauvegarde juste des stats agrégées
      if (kDebugMode) debugPrint('Exercice $exerciseId complété ! Streak: $streak');

    } catch (e) {
      if (kDebugMode) debugPrint('markCompleted error: $e');
    }
  }

  // ── Getters état ──────────────────────────────────────────────────────────
  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStreak) ?? 0;
  }

  Future<bool> isCompletedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_keyLastCompletedDate);
    return last == _todayString();
  }

  // ── Récupérer tout le catalogue (pour admin / affichage liste) ────────────
  Future<List<Exercise>> getCatalogue({
    ExerciseCategory? categorie,
    ExerciseDifficulty? difficulte,
    bool activeOnly = true,
  }) async {
    try {
      Query query = _db.collection('exercises');
      if (activeOnly) query = query.where('actif', isEqualTo: true);

      final snapshot = await query.get();
      var exercises = snapshot.docs
          .map((doc) => Exercise.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      if (categorie != null) {
        exercises = exercises.where((e) => e.categorie == categorie).toList();
      }
      if (difficulte != null) {
        exercises = exercises.where((e) => e.difficulte == difficulte).toList();
      }

      exercises.sort((a, b) => a.titre.compareTo(b.titre));
      return exercises;

    } catch (e) {
      if (kDebugMode) debugPrint('getCatalogue error: $e');
      return [];
    }
  }

  // ── Helpers privés ────────────────────────────────────────────────────────
  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }

  List<String> _getRecentIds(SharedPreferences prefs) {
    return prefs.getStringList(_keyRecentExercises) ?? [];
  }

  Future<void> _addToRecent(SharedPreferences prefs, String id) async {
    var recent = prefs.getStringList(_keyRecentExercises) ?? [];
    recent.insert(0, id);
    if (recent.length > 7) recent = recent.sublist(0, 7); // Garder 7 derniers
    await prefs.setStringList(_keyRecentExercises, recent);
  }

  ExerciseTarget _parseTarget(String val) {
    switch (val) {
      case 'sedentaire':  return ExerciseTarget.sedentaire;
      case 'actif':       return ExerciseTarget.actif;
      case 'senior':      return ExerciseTarget.senior;
      case 'grossesse':   return ExerciseTarget.grossesse;
      case 'mal_de_dos':  return ExerciseTarget.malDeDos;
      case 'stress':      return ExerciseTarget.stress;
      default:            return ExerciseTarget.tous;
    }
  }
}
