import 'package:flutter/foundation.dart';
import '../core/services/embedded_ai_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/demo_service.dart';
import '../models/app_models.dart';
import '../core/constants/app_constants.dart';

class AppProvider extends ChangeNotifier {
  // ====== IA Embarquée ======
  final _ai = EmbeddedAIService();

  // ====== User State ======
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _userRole;
  String? _userTerritory;
  bool _isLoggedIn = false;
  bool _isOnboardingComplete = false;
  bool _isDemoUser = false;
  DemoProfile? _activeDemoProfile;

  // ====== Profile & Assessment ======
  UserProfile? _userProfile;
  String? _aiAssessment;
  bool _isLoadingAssessment = false;
  String? _assessmentError;

  // ====== Exercises ======
  List<Exercise> _exercises = [];
  List<Exercise> _filteredExercises = [];
  String _activeFilter = 'all';

  // ====== Sessions & Progress ======
  List<WorkoutSession> _sessions = [];
  double _weeklyAdherence = 0.0;
  int _totalActiveDays = 0;
  int _totalSessionCount = 0;
  int _totalMinutes = 0;
  double _avgPainLevel = 0.0;
  String? _aiWeeklyAnalysis;
  bool _isLoadingProgress = false;

  // ====== Demo Profiles ======
  List<DemoProfile> _demoProfiles = [];

  // ====== Onboarding Form State ======
  final Map<String, dynamic> _onboardingData = {};

  // ====== Getters ======
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;
  String? get userTerritory => _userTerritory;
  bool get isLoggedIn => _isLoggedIn;
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isDemoUser => _isDemoUser;
  DemoProfile? get activeDemoProfile => _activeDemoProfile;
  UserProfile? get userProfile => _userProfile;
  String? get aiAssessment => _aiAssessment;
  bool get isLoadingAssessment => _isLoadingAssessment;
  String? get assessmentError => _assessmentError;
  List<Exercise> get exercises => _exercises;
  List<Exercise> get filteredExercises =>
      _filteredExercises.isEmpty && _activeFilter == 'all'
          ? _exercises
          : _filteredExercises;
  String get activeFilter => _activeFilter;
  List<WorkoutSession> get sessions => _sessions;
  double get weeklyAdherence => _weeklyAdherence;
  int get totalActiveDays => _totalActiveDays;
  int get totalSessionCount => _totalSessionCount;
  int get totalMinutes => _totalMinutes;
  double get avgPainLevel => _avgPainLevel;
  String? get aiWeeklyAnalysis => _aiWeeklyAnalysis;
  bool get isLoadingProgress => _isLoadingProgress;
  Map<String, dynamic> get onboardingData => _onboardingData;
  List<DemoProfile> get demoProfiles => _demoProfiles;

  // ====== Init ======
  void initialize() {
    _demoProfiles = DemoService.getDemoProfiles();
    _userId = StorageService.getUserId();
    _userName = StorageService.getUserName();
    _userEmail = StorageService.getUserEmail();
    _isLoggedIn = _userId != null;
    _isOnboardingComplete = StorageService.isOnboardingComplete();

    final profileMap = StorageService.getUserProfile();
    if (profileMap != null) {
      _userProfile = UserProfile.fromMap(profileMap);
    }

    _aiAssessment = StorageService.getAssessment();

    final savedSessions = StorageService.getAllSessions();
    _sessions = savedSessions
        .map((s) => WorkoutSession(
              id: s['id']?.toString() ?? '',
              userId: s['userId']?.toString() ?? '',
              date: DateTime.tryParse(s['date']?.toString() ?? '') ??
                  DateTime.now(),
              exercicesCompletes:
                  List<String>.from(s['exercicesCompletes'] as List? ?? []),
              dureeMinutes: (s['dureeMinutes'] as num?)?.toInt() ?? 0,
              niveauDouleur:
                  (s['niveauDouleur'] as num?)?.toDouble() ?? 0.0,
            ))
        .toList();

    _computeStats();
    _loadExercises();
    notifyListeners();
  }

  // ====== Demo Login ======
  Future<void> demoLogin(DemoProfile profile) async {
    _userId = profile.id;
    _userName = profile.name;
    _userEmail = profile.email;
    _userRole = profile.role;
    _userTerritory = profile.territory;
    _isLoggedIn = true;
    _isDemoUser = true;
    _isOnboardingComplete = true;
    _activeDemoProfile = profile;

    // Charger les données complètes du profil démo
    _userProfile = profile.profile;
    _aiAssessment = profile.aiAssessment;
    _sessions = profile.sessions;
    _exercises = profile.exercises.isNotEmpty
        ? profile.exercises
        : AppConstants.seedExercises;
    _aiWeeklyAnalysis = profile.weeklyAnalysis;

    _computeStats();
    notifyListeners();
  }

  // ====== Login / Logout ======
  Future<void> login(String userId, String name, String email) async {
    await StorageService.saveUserId(userId);
    await StorageService.saveUserName(name);
    await StorageService.saveUserEmail(email);
    _userId = userId;
    _userName = name;
    _userEmail = email;
    _isLoggedIn = true;
    _isDemoUser = false;
    _activeDemoProfile = null;
    _isOnboardingComplete = StorageService.isOnboardingComplete();
    notifyListeners();
  }

  Future<void> logout() async {
    await StorageService.logout();
    _userId = null;
    _userName = null;
    _userEmail = null;
    _userRole = null;
    _userTerritory = null;
    _isLoggedIn = false;
    _isDemoUser = false;
    _activeDemoProfile = null;
    _isOnboardingComplete = false;
    _userProfile = null;
    _aiAssessment = null;
    _aiWeeklyAnalysis = null;
    _sessions = [];
    _exercises = AppConstants.seedExercises;
    _computeStats();
    notifyListeners();
  }

  // ====== Onboarding ======
  void updateOnboardingData(Map<String, dynamic> data) {
    _onboardingData.addAll(data);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    if (_userId == null) return;

    final profile = UserProfile(
      userId: _userId!,
      prenom: _onboardingData['prenom']?.toString() ?? _userName ?? '',
      age: _onboardingData['age']?.toString() ?? '',
      genre: _onboardingData['genre']?.toString() ?? '',
      localisation:
          _onboardingData['localisation']?.toString() ?? 'Pacifique',
      objectifSante: _onboardingData['objectifSante']?.toString() ?? '',
      douleursActuelles: _onboardingData['douleursActuelles'] == true,
      zonesDouleur:
          List<String>.from(_onboardingData['zonesDouleur'] as List? ?? []),
      niveauMobilite:
          (_onboardingData['niveauMobilite'] as num?)?.toInt() ?? 3,
      niveauActivite: _onboardingData['niveauActivite']?.toString() ?? '',
      problemesSante:
          List<String>.from(_onboardingData['problemesSante'] as List? ?? []),
      chirurgies: _onboardingData['chirurgies']?.toString() ?? '',
      traitements: _onboardingData['traitements']?.toString() ?? '',
      dureeSeance:
          _onboardingData['dureeSeance']?.toString() ?? '20 minutes',
      frequenceSemaine:
          _onboardingData['frequenceSemaine']?.toString() ?? '3 jours/semaine',
      preferencesExercices: List<String>.from(
          _onboardingData['preferencesExercices'] as List? ?? []),
      createdAt: DateTime.now(),
    );

    _userProfile = profile;
    await StorageService.saveUserProfile(profile.toMap());
    await StorageService.setOnboardingComplete(true);
    _isOnboardingComplete = true;
    notifyListeners();
  }

  // ====== Génération Bilan IA Embarquée ======
  Future<void> generateAssessment() async {
    if (_userProfile == null) return;

    _isLoadingAssessment = true;
    _assessmentError = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      final result = _ai.generateAssessment(_userProfile!);
      _aiAssessment = result;
      if (!_isDemoUser) {
        await StorageService.saveAssessment(result);
      }
      _generateAIProgram();
    } catch (e) {
      _assessmentError =
          'Erreur lors de la génération du bilan. Veuillez réessayer.';
      if (kDebugMode) debugPrint('Assessment error: $e');
    }

    _isLoadingAssessment = false;
    notifyListeners();
  }

  void _generateAIProgram() {
    if (_userProfile == null) return;
    try {
      final aiExercises = _ai.generateWeekProgram(_userProfile!);
      _exercises = [
        ...aiExercises,
        ...AppConstants.seedExercises
            .where((e) => !aiExercises.any((ai) => ai.id == e.id)),
      ];
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('Program generation error: $e');
    }
  }

  // ====== Analyse Progression Hebdomadaire ======
  Future<void> analyzeWeeklyProgress() async {
    if (_userProfile == null) return;

    _isLoadingProgress = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final analysis = _ai.analyzeProgress(
        adherence: _weeklyAdherence,
        tempsTotal: _totalMinutes,
        niveauDouleur: _avgPainLevel,
        prenom: _userProfile!.prenom,
      );
      _aiWeeklyAnalysis = analysis;
    } catch (e) {
      if (kDebugMode) debugPrint('Progress analysis error: $e');
    }

    _isLoadingProgress = false;
    notifyListeners();
  }

  // ====== Enregistrement Session ======
  Future<void> recordSession(WorkoutSession session) async {
    _sessions.add(session);
    if (!_isDemoUser) {
      await StorageService.saveSessionData(session.toMap());
    }
    _computeStats();
    notifyListeners();
    _checkEscalation(session.niveauDouleur);
  }

  Map<String, String> _checkEscalation(double painLevel) {
    return _ai.detectEscalation(
      douleur: painLevel,
      adherence: _weeklyAdherence,
      dureeEnSemaines: _getWeeksActive(),
      prenom: _userProfile?.prenom ?? 'Utilisateur',
    );
  }

  int _getWeeksActive() {
    if (_sessions.isEmpty) return 0;
    final oldest = _sessions
        .map((s) => s.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    return DateTime.now().difference(oldest).inDays ~/ 7;
  }

  // ====== Calcul Stats ======
  void _computeStats() {
    if (_sessions.isEmpty) {
      _totalActiveDays = 0;
      _totalSessionCount = 0;
      _totalMinutes = 0;
      _weeklyAdherence = 0;
      _avgPainLevel = 0;
      return;
    }

    _totalSessionCount = _sessions.length;
    _totalMinutes =
        _sessions.fold(0, (sum, s) => sum + s.dureeMinutes);
    _avgPainLevel = _sessions.isNotEmpty
        ? _sessions.fold(0.0, (sum, s) => sum + s.niveauDouleur) /
            _sessions.length
        : 0.0;

    final days =
        _sessions.map((s) => _dayKey(s.date)).toSet();
    _totalActiveDays = days.length;

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekSessions =
        _sessions.where((s) => s.date.isAfter(weekAgo)).length;
    final targetFreq = _userProfile != null
        ? _parseFrequency(_userProfile!.frequenceSemaine)
        : 3;
    _weeklyAdherence =
        (weekSessions / targetFreq * 100).clamp(0.0, 100.0);
  }

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  int _parseFrequency(String freq) {
    final match = RegExp(r'\d+').firstMatch(freq);
    return int.tryParse(match?.group(0) ?? '3') ?? 3;
  }

  // ====== Exercises ======
  void _loadExercises() {
    _exercises = List.from(AppConstants.seedExercises);
    if (_userProfile != null) {
      _generateAIProgram();
    }
    _filteredExercises = [];
    notifyListeners();
  }

  void filterExercises(String filter) {
    _activeFilter = filter;
    if (filter == 'all') {
      _filteredExercises = [];
    } else {
      _filteredExercises =
          _exercises.where((e) => e.type == filter).toList();
    }
    notifyListeners();
  }

  void searchExercises(String query) {
    if (query.isEmpty) {
      _filteredExercises = [];
      _activeFilter = 'all';
    } else {
      _filteredExercises = _exercises
          .where((e) =>
              e.name.toLowerCase().contains(query.toLowerCase()) ||
              e.targetZone
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              e.description
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // ====== Mise à jour nom ======
  Future<void> updateUserName(String name) async {
    if (!_isDemoUser) {
      await StorageService.saveUserName(name);
    }
    _userName = name;
    notifyListeners();
  }
}
