// core/services/daily_exercise_service.dart
// Service exercice du jour SANTEO Connect
// Architecture : catalogue Firestore extensible + anti-répétition + filtre profil

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/app_models.dart';
import '../../core/constants/app_constants.dart';

class DailyExerciseService {
  static final DailyExerciseService _instance = DailyExerciseService._internal();
  factory DailyExerciseService() => _instance;
  DailyExerciseService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Clés SharedPreferences ────────────────────────────────────────────────
  static const _keyDailyExerciseId   = 'daily_exercise_id';
  static const _keyDailyExerciseDate = 'daily_exercise_date';
  static const _keyRecentExercises   = 'recent_exercise_ids';
  static const _keyStreak            = 'daily_exercise_streak';
  static const _keyLastCompletedDate = 'daily_exercise_last_completed';

  // ── Obtenir l'exercice du jour ────────────────────────────────────────────
  /// Retourne l'exercice du jour.
  /// - Même exercice toute la journée (stocké en SharedPreferences)
  /// - Anti-répétition sur les 7 derniers jours
  /// - Filtre optionnel par zone cible (dos, epaules, etc.)
  Future<Exercise?> getDailyExercise({
    String? userProfile,
    String? difficulte,   // 'facile' | 'moyen' | 'difficile'
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _todayString();

      // ── 1. Vérifier si on a déjà sélectionné un exercice aujourd'hui ─────
      final storedDate = prefs.getString(_keyDailyExerciseDate);
      final storedId   = prefs.getString(_keyDailyExerciseId);

      if (storedDate == today && storedId != null && storedId.isNotEmpty) {
        // Essayer d'abord dans Firestore
        try {
          final doc = await _db.collection('exercises').doc(storedId).get();
          if (doc.exists && doc.data() != null) {
            return Exercise.fromMap({...doc.data()!, 'id': doc.id});
          }
        } catch (_) {}
        // Fallback : chercher dans seedExercises
        final seed = AppConstants.seedExercises.where((e) => e.id == storedId).firstOrNull;
        if (seed != null) return seed;
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
    String? difficulte,
  ) async {
    // Récupérer les IDs récents (anti-répétition)
    final recentIds = _getRecentIds(prefs);

    List<Exercise> exercises = [];

    // Essayer Firestore d'abord
    try {
      final snapshot = await _db
          .collection('exercises')
          .where('actif', isEqualTo: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        exercises = snapshot.docs
            .map((doc) => Exercise.fromMap({...doc.data(), 'id': doc.id}))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Firestore indisponible, fallback seedExercises: $e');
    }

    // Fallback : utiliser les seed exercises
    if (exercises.isEmpty) {
      exercises = List<Exercise>.from(AppConstants.seedExercises);
    }

    // ── Filtre zone / profil utilisateur (en mémoire) ─────────────────────
    if (userProfile != null && userProfile != 'tous' && userProfile.isNotEmpty) {
      final filtered = exercises
          .where((e) => e.targetZone.toLowerCase().contains(userProfile.toLowerCase()))
          .toList();
      if (filtered.isNotEmpty) exercises = filtered;
    }

    // ── Filtre difficulté (en mémoire) ────────────────────────────────────
    if (difficulte != null && difficulte.isNotEmpty) {
      final filtered = exercises
          .where((e) => e.difficulty == difficulte)
          .toList();
      if (filtered.isNotEmpty) exercises = filtered;
    }

    // ── Anti-répétition : exclure les 7 derniers ──────────────────────────
    final withoutRecent = exercises.where((e) => !recentIds.contains(e.id)).toList();
    final pool = withoutRecent.isNotEmpty ? withoutRecent : exercises;

    if (pool.isEmpty) return null;

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
          streak += 1;
        } else if (diff > 1) {
          streak = 1;
        }
        // diff == 0 → déjà complété aujourd'hui, pas de changement
      }

      await prefs.setInt(_keyStreak, streak);
      await prefs.setString(_keyLastCompletedDate, today);

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

  // ── Récupérer tout le catalogue ────────────────────────────────────────
  Future<List<Exercise>> getCatalogue({
    String? categorie,    // 'renforcement' | 'mobilite' | 'etirement' | 'cardio'
    String? difficulte,   // 'facile' | 'moyen' | 'difficile'
    bool activeOnly = true,
  }) async {
    try {
      Query query = _db.collection('exercises');
      if (activeOnly) query = query.where('actif', isEqualTo: true);

      final snapshot = await query.get();
      List<Exercise> exercises = snapshot.docs
          .map((doc) => Exercise.fromMap({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();

      if (categorie != null && categorie.isNotEmpty) {
        exercises = exercises.where((e) => e.type == categorie).toList();
      }
      if (difficulte != null && difficulte.isNotEmpty) {
        exercises = exercises.where((e) => e.difficulty == difficulte).toList();
      }

      exercises.sort((a, b) => a.ordre.compareTo(b.ordre));
      return exercises;

    } catch (e) {
      if (kDebugMode) debugPrint('getCatalogue error: $e');
      // Fallback sur seedExercises
      var seeds = List<Exercise>.from(AppConstants.seedExercises);
      if (categorie != null) seeds = seeds.where((e) => e.type == categorie).toList();
      if (difficulte != null) seeds = seeds.where((e) => e.difficulty == difficulte).toList();
      return seeds;
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
    if (recent.length > 7) recent = recent.sublist(0, 7);
    await prefs.setStringList(_keyRecentExercises, recent);
  }
}
