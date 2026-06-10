// core/services/daily_plan_service.dart
// Service Plan Quotidien — 2 exercices/jour + déblocage séquentiel
// SANTEO Connect — Architecture SharedPreferences + Firestore catalogue

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════════
//  MODÈLE — Slot exercice du plan quotidien
// ═══════════════════════════════════════════════════════════════════

enum DailySlotStatus { locked, available, completed }

class DailyExerciseSlot {
  final int slot;           // 0 ou 1 (1er ou 2ème exercice)
  final Map<String, dynamic> exerciseData; // données brutes Firestore
  final DailySlotStatus status;
  final DateTime? completedAt;

  const DailyExerciseSlot({
    required this.slot,
    required this.exerciseData,
    required this.status,
    this.completedAt,
  });

  String get id => exerciseData['id'] as String? ?? '';
  String get titre => exerciseData['titre'] as String? ?? 'Exercice';
  String get categorie => exerciseData['categorie'] as String? ?? '';
  String get difficulte => exerciseData['difficulte'] as String? ?? 'debutant';
  String get videoUrl => exerciseData['video_url'] as String? ?? '';
  List<String> get zones => List<String>.from(exerciseData['zones'] as List? ?? []);
  int get series => (exerciseData['series'] as num?)?.toInt() ?? 3;
  int get dureeSerieSec => (exerciseData['duree_serie_sec'] as num?)?.toInt() ?? 0;
  int get reps => (exerciseData['reps'] as num?)?.toInt() ?? 0;
  String get typeComptage => exerciseData['type_comptage'] as String? ?? 'reps';

  bool get isLocked => status == DailySlotStatus.locked;
  bool get isAvailable => status == DailySlotStatus.available;
  bool get isCompleted => status == DailySlotStatus.completed;

  /// Durée estimée en minutes
  int get estimatedMinutes {
    if (dureeSerieSec > 0) {
      return ((series * dureeSerieSec) / 60).ceil().clamp(1, 30);
    }
    return ((series * reps * 3) / 60).ceil().clamp(2, 20);
  }

  DailyExerciseSlot copyWith({DailySlotStatus? status, DateTime? completedAt}) {
    return DailyExerciseSlot(
      slot: slot,
      exerciseData: exerciseData,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SERVICE
// ═══════════════════════════════════════════════════════════════════

class DailyPlanService {
  static final DailyPlanService _instance = DailyPlanService._internal();
  factory DailyPlanService() => _instance;
  DailyPlanService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Clés SharedPreferences ────────────────────────────────────────────────
  static const _keyPlanDate       = 'daily_plan_date';
  static const _keyPlanSlot0Id    = 'daily_plan_slot0_id';
  static const _keyPlanSlot1Id    = 'daily_plan_slot1_id';
  static const _keySlot0Completed = 'daily_plan_slot0_completed';
  static const _keySlot1Completed = 'daily_plan_slot1_completed';
  static const _keySlot0CompAt    = 'daily_plan_slot0_completed_at';
  static const _keySlot1CompAt    = 'daily_plan_slot1_completed_at';
  static const _keyRecentIds      = 'daily_plan_recent_ids';  // JSON list
  static const _keyStreak         = 'daily_plan_streak';
  static const _keyLastStreakDate = 'daily_plan_last_streak_date';

  // ── Cache mémoire ─────────────────────────────────────────────────────────
  List<DailyExerciseSlot>? _cachedPlan;
  String? _cachedDate;

  // ═════════════════════════════════════════════════════════════════
  //  OBTENIR LE PLAN DU JOUR
  // ═════════════════════════════════════════════════════════════════

  /// Retourne les 2 slots du plan quotidien avec leur statut.
  /// Même plan toute la journée — reset automatique à minuit.
  Future<List<DailyExerciseSlot>> getDailyPlan({
    String? userProfile,  // 'sedentaire' | 'actif' | 'senior' | etc.
    String? difficulty,   // 'debutant' | 'intermediaire' | 'avance'
  }) async {
    try {
      final today = _todayString();

      // ── Cache hit ─────────────────────────────────────────────────────────
      if (_cachedDate == today && _cachedPlan != null) {
        return await _refreshStatuses(_cachedPlan!);
      }

      final prefs = await SharedPreferences.getInstance();
      final storedDate = prefs.getString(_keyPlanDate);

      // ── Reset à minuit ────────────────────────────────────────────────────
      if (storedDate != today) {
        await _resetDailyPlan(prefs);
      }

      // ── Vérifier si on a déjà les IDs du jour ─────────────────────────────
      final slot0Id = prefs.getString(_keyPlanSlot0Id);
      final slot1Id = prefs.getString(_keyPlanSlot1Id);

      List<Map<String, dynamic>> exercises;

      if (slot0Id != null && slot1Id != null && storedDate == today) {
        // Récupérer les données depuis Firestore
        exercises = await _fetchExercisesById([slot0Id, slot1Id]);
        if (exercises.length < 2) {
          // Données corrompues → sélectionner de nouveaux
          exercises = await _selectDailyExercises(prefs, userProfile, difficulty);
          await _savePlanIds(prefs, exercises);
        }
      } else {
        // Sélectionner 2 nouveaux exercices
        exercises = await _selectDailyExercises(prefs, userProfile, difficulty);
        await _savePlanIds(prefs, exercises);
        await prefs.setString(_keyPlanDate, today);
      }

      // ── Construire les slots avec statuts ─────────────────────────────────
      final slot0Done = prefs.getBool(_keySlot0Completed) ?? false;
      final slot1Done = prefs.getBool(_keySlot1Completed) ?? false;
      final slot0At   = prefs.getString(_keySlot0CompAt);
      final slot1At   = prefs.getString(_keySlot1CompAt);

      final plan = [
        DailyExerciseSlot(
          slot: 0,
          exerciseData: exercises.isNotEmpty ? exercises[0] : {},
          status: slot0Done
              ? DailySlotStatus.completed
              : DailySlotStatus.available,
          completedAt: slot0At != null ? DateTime.tryParse(slot0At) : null,
        ),
        DailyExerciseSlot(
          slot: 1,
          exerciseData: exercises.length > 1 ? exercises[1] : {},
          // Slot 1 verrouillé jusqu'à complétion du slot 0
          status: slot1Done
              ? DailySlotStatus.completed
              : (slot0Done ? DailySlotStatus.available : DailySlotStatus.locked),
          completedAt: slot1At != null ? DateTime.tryParse(slot1At) : null,
        ),
      ];

      _cachedPlan = plan;
      _cachedDate = today;
      return plan;

    } catch (e) {
      if (kDebugMode) debugPrint('DailyPlanService.getDailyPlan error: $e');
      return _fallbackPlan();
    }
  }

  // ═════════════════════════════════════════════════════════════════
  //  MARQUER UN EXERCICE COMME COMPLÉTÉ
  // ═════════════════════════════════════════════════════════════════

  Future<List<DailyExerciseSlot>> markSlotCompleted(int slot) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().toIso8601String();

      if (slot == 0) {
        await prefs.setBool(_keySlot0Completed, true);
        await prefs.setString(_keySlot0CompAt, now);
      } else if (slot == 1) {
        await prefs.setBool(_keySlot1Completed, true);
        await prefs.setString(_keySlot1CompAt, now);
        // Mettre à jour le streak (les 2 exos du jour complétés)
        await _updateStreak(prefs);
      }

      // Invalider le cache pour forcer rafraîchissement
      _cachedPlan = null;

      // Retourner le plan mis à jour
      return await getDailyPlan();

    } catch (e) {
      if (kDebugMode) debugPrint('markSlotCompleted error: $e');
      return _cachedPlan ?? [];
    }
  }

  // ═════════════════════════════════════════════════════════════════
  //  GETTERS ÉTAT
  // ═════════════════════════════════════════════════════════════════

  Future<bool> isBothCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final planDate = prefs.getString(_keyPlanDate);
    if (planDate != today) return false;
    return (prefs.getBool(_keySlot0Completed) ?? false) &&
        (prefs.getBool(_keySlot1Completed) ?? false);
  }

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStreak) ?? 0;
  }

  Future<bool> isFirstExerciseCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final planDate = prefs.getString(_keyPlanDate);
    if (planDate != today) return false;
    return prefs.getBool(_keySlot0Completed) ?? false;
  }

  // ═════════════════════════════════════════════════════════════════
  //  SÉLECTION INTELLIGENTE — 2 exercices complémentaires
  // ═════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> _selectDailyExercises(
    SharedPreferences prefs,
    String? userProfile,
    String? difficulty,
  ) async {
    try {
      // Récupérer tous les exercices actifs
      final snapshot = await _db
          .collection('exercises')
          .where('actif', isEqualTo: true)
          .get();

      if (snapshot.docs.isEmpty) return [];

      var allExercises = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      // ── Filtre profil utilisateur ─────────────────────────────────────────
      if (userProfile != null && userProfile != 'tous') {
        final filtered = allExercises.where((e) {
          final cibles = List<String>.from(e['cibles'] as List? ?? []);
          return cibles.contains('tous') || cibles.contains(userProfile);
        }).toList();
        if (filtered.isNotEmpty) allExercises = filtered;
      }

      // ── Filtre difficulté ─────────────────────────────────────────────────
      if (difficulty != null) {
        final filtered = allExercises
            .where((e) => e['difficulte'] == difficulty)
            .toList();
        if (filtered.isNotEmpty) allExercises = filtered;
      }

      // ── Anti-répétition ───────────────────────────────────────────────────
      final recentIds = prefs.getStringList(_keyRecentIds) ?? [];
      final withoutRecent = allExercises
          .where((e) => !recentIds.contains(e['id']))
          .toList();
      final pool = withoutRecent.isNotEmpty ? withoutRecent : allExercises;

      if (pool.isEmpty) return [];

      // ── Sélection déterministe + diversité catégorie ──────────────────────
      final dayIndex = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;

      // Premier exercice
      final idx0 = dayIndex % pool.length;
      final ex0 = pool[idx0];

      // Deuxième exercice : différente catégorie si possible
      final cat0 = ex0['categorie'] as String? ?? '';
      final poolAlt = pool
          .where((e) => e['id'] != ex0['id'] && e['categorie'] != cat0)
          .toList();
      final poolFor1 = poolAlt.isNotEmpty ? poolAlt : pool
          .where((e) => e['id'] != ex0['id'])
          .toList();

      if (poolFor1.isEmpty) return [ex0];

      final idx1 = (dayIndex + 7) % poolFor1.length; // offset pour diversité
      final ex1 = poolFor1[idx1];

      // Mettre à jour les IDs récents
      final newRecent = [ex0['id'] as String, ex1['id'] as String, ...recentIds];
      final trimmed = newRecent.length > 14 ? newRecent.sublist(0, 14) : newRecent;
      await prefs.setStringList(_keyRecentIds, trimmed);

      return [ex0, ex1];

    } catch (e) {
      if (kDebugMode) debugPrint('_selectDailyExercises error: $e');
      return [];
    }
  }

  // ═════════════════════════════════════════════════════════════════
  //  HELPERS FIRESTORE
  // ═════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> _fetchExercisesById(List<String> ids) async {
    final results = <Map<String, dynamic>>[];
    for (final id in ids) {
      try {
        final doc = await _db.collection('exercises').doc(id).get();
        if (doc.exists && doc.data() != null) {
          results.add({'id': doc.id, ...doc.data()!});
        }
      } catch (_) {}
    }
    return results;
  }

  Future<void> _savePlanIds(
    SharedPreferences prefs,
    List<Map<String, dynamic>> exercises,
  ) async {
    if (exercises.isNotEmpty) {
      await prefs.setString(_keyPlanSlot0Id, exercises[0]['id'] as String? ?? '');
    }
    if (exercises.length > 1) {
      await prefs.setString(_keyPlanSlot1Id, exercises[1]['id'] as String? ?? '');
    }
  }

  // ═════════════════════════════════════════════════════════════════
  //  REFRESH STATUTS (depuis cache)
  // ═════════════════════════════════════════════════════════════════

  Future<List<DailyExerciseSlot>> _refreshStatuses(
    List<DailyExerciseSlot> plan,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final slot0Done = prefs.getBool(_keySlot0Completed) ?? false;
    final slot1Done = prefs.getBool(_keySlot1Completed) ?? false;
    final slot0At   = prefs.getString(_keySlot0CompAt);
    final slot1At   = prefs.getString(_keySlot1CompAt);

    return [
      plan[0].copyWith(
        status: slot0Done ? DailySlotStatus.completed : DailySlotStatus.available,
        completedAt: slot0At != null ? DateTime.tryParse(slot0At) : null,
      ),
      if (plan.length > 1)
        plan[1].copyWith(
          status: slot1Done
              ? DailySlotStatus.completed
              : (slot0Done ? DailySlotStatus.available : DailySlotStatus.locked),
          completedAt: slot1At != null ? DateTime.tryParse(slot1At) : null,
        ),
    ];
  }

  // ═════════════════════════════════════════════════════════════════
  //  STREAK
  // ═════════════════════════════════════════════════════════════════

  Future<void> _updateStreak(SharedPreferences prefs) async {
    final today = _todayString();
    final lastDate = prefs.getString(_keyLastStreakDate);
    int streak = prefs.getInt(_keyStreak) ?? 0;

    if (lastDate == null) {
      streak = 1;
    } else {
      final last = DateTime.tryParse(lastDate);
      if (last != null) {
        final diff = DateTime.now().difference(last).inDays;
        if (diff == 1) {
          streak += 1;
        } else if (diff > 1) {
          streak = 1;
        }
        // diff == 0 → déjà complété aujourd'hui
      }
    }

    await prefs.setInt(_keyStreak, streak);
    await prefs.setString(_keyLastStreakDate, today);
  }

  // ═════════════════════════════════════════════════════════════════
  //  RESET
  // ═════════════════════════════════════════════════════════════════

  Future<void> _resetDailyPlan(SharedPreferences prefs) async {
    await prefs.remove(_keyPlanSlot0Id);
    await prefs.remove(_keyPlanSlot1Id);
    await prefs.remove(_keySlot0Completed);
    await prefs.remove(_keySlot1Completed);
    await prefs.remove(_keySlot0CompAt);
    await prefs.remove(_keySlot1CompAt);
    _cachedPlan = null;
    _cachedDate = null;
  }

  // ── Reset forcé (pour debug / tests) ─────────────────────────────────────
  Future<void> forceReset() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetDailyPlan(prefs);
    await prefs.remove(_keyPlanDate);
  }

  // ═════════════════════════════════════════════════════════════════
  //  FALLBACK (si Firestore indisponible)
  // ═════════════════════════════════════════════════════════════════

  List<DailyExerciseSlot> _fallbackPlan() {
    return [
      DailyExerciseSlot(
        slot: 0,
        exerciseData: {
          'id': 'ex_cat_cow',
          'titre': 'Cat-Cow',
          'categorie': 'mobilite',
          'difficulte': 'debutant',
          'video_url': 'https://drive.google.com/file/d/1K565Sz8GZMXk1eFpsAucxWzcMOshnvsk/preview',
          'series': 1,
          'reps': 10,
          'duree_serie_sec': 0,
          'repos_sec': 0,
          'type_comptage': 'reps',
          'zones': ['colonne', 'bas_dos'],
          'voix_intro': 'Le Cat-Cow. À quatre pattes, mains sous les épaules.',
          'voix_pendant': 'Inspirez en creusant, expirez en arrondissant.',
          'voix_repos': 'Continuez doucement.',
          'voix_fin': 'Parfait réveil de la colonne !',
        },
        status: DailySlotStatus.available,
      ),
      DailyExerciseSlot(
        slot: 1,
        exerciseData: {
          'id': 'ex_auto_embrassade',
          'titre': 'Auto-embrassade',
          'categorie': 'mobilite',
          'difficulte': 'debutant',
          'video_url': 'https://drive.google.com/file/d/1LND1nBrmLNtenu0y4NXiBtshtS2DD2s7/preview',
          'series': 3,
          'reps': 0,
          'duree_serie_sec': 30,
          'repos_sec': 15,
          'type_comptage': 'chrono',
          'zones': ['epaules', 'haut_dos'],
          'voix_intro': "L'auto-embrassade. Croisez les bras devant vous.",
          'voix_pendant': 'Inspirez doucement, expirez en serrant légèrement.',
          'voix_repos': 'Bien. Relâchez les épaules.',
          'voix_fin': 'Vos épaules et votre dos vont mieux !',
        },
        status: DailySlotStatus.locked,
      ),
    ];
  }

  // ═════════════════════════════════════════════════════════════════
  //  HELPER DATE
  // ═════════════════════════════════════════════════════════════════

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }
}
