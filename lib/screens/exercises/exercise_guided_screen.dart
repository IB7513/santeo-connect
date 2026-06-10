// screens/exercises/exercise_guided_screen.dart
// Écran de séance guidée — SANTEO Connect
// Vidéo Google Drive en boucle + chrono + TTS + séries + signal sonore
// Portrait : vidéo 16:9 + contrôles en bas
// Paysage  : vidéo plein écran automatique (SystemChrome)

// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/daily_exercise_service.dart';

// ═══════════════════════════════════════════════════════════════════
//  MODÈLE DONNÉES EXERCICE GUIDÉ
// ═══════════════════════════════════════════════════════════════════

class ExerciseGuidedData {
  final String id;
  final String titre;
  final String titreCourt;
  final String categorie;
  final String difficulte;
  final String videoUrl;
  final int series;
  final int reps;
  final int dureeSerieSec;
  final int reposSec;
  final String typeComptage; // 'reps' | 'chrono' | 'reps_par_cote' | 'chrono_par_cote'
  final String voixIntro;
  final String voixPendant;
  final String voixRepos;
  final String voixFin;
  final List<String> zones;

  const ExerciseGuidedData({
    required this.id,
    required this.titre,
    required this.titreCourt,
    required this.categorie,
    required this.difficulte,
    required this.videoUrl,
    required this.series,
    required this.reps,
    required this.dureeSerieSec,
    required this.reposSec,
    required this.typeComptage,
    required this.voixIntro,
    required this.voixPendant,
    required this.voixRepos,
    required this.voixFin,
    required this.zones,
  });

  factory ExerciseGuidedData.fromMap(Map<String, dynamic> data) {
    return ExerciseGuidedData(
      id: data['id'] as String? ?? '',
      titre: data['titre'] as String? ?? 'Exercice',
      titreCourt: data['titre_court'] as String? ?? data['titre'] as String? ?? 'Exercice',
      categorie: data['categorie'] as String? ?? 'renforcement',
      difficulte: data['difficulte'] as String? ?? 'debutant',
      videoUrl: data['video_url'] as String? ?? '',
      series: (data['series'] as num?)?.toInt() ?? 3,
      reps: (data['reps'] as num?)?.toInt() ?? 0,
      dureeSerieSec: (data['duree_serie_sec'] as num?)?.toInt() ?? 30,
      reposSec: (data['repos_sec'] as num?)?.toInt() ?? 30,
      typeComptage: data['type_comptage'] as String? ?? 'reps',
      voixIntro: data['voix_intro'] as String? ?? '',
      voixPendant: data['voix_pendant'] as String? ?? '',
      voixRepos: data['voix_repos'] as String? ?? '',
      voixFin: data['voix_fin'] as String? ?? '',
      zones: List<String>.from(data['zones'] as List? ?? []),
    );
  }

  bool get isChronoType => typeComptage == 'chrono' || typeComptage == 'chrono_par_cote';
  bool get isParCote => typeComptage == 'reps_par_cote' || typeComptage == 'chrono_par_cote';
}

// ═══════════════════════════════════════════════════════════════════
//  PHASE DE LA SÉANCE
// ═══════════════════════════════════════════════════════════════════

enum _Phase { intro, serie, repos, fin }

// ═══════════════════════════════════════════════════════════════════
//  WIDGET PRINCIPAL
// ═══════════════════════════════════════════════════════════════════

class ExerciseGuidedScreen extends StatefulWidget {
  final Map<String, dynamic> exerciseData;
  final VoidCallback? onCompleted;
  final bool isFromDailyPlan; // true = depuis le plan du jour

  const ExerciseGuidedScreen({
    super.key,
    required this.exerciseData,
    this.onCompleted,
    this.isFromDailyPlan = false,
  });

  @override
  State<ExerciseGuidedScreen> createState() => _ExerciseGuidedScreenState();
}

class _ExerciseGuidedScreenState extends State<ExerciseGuidedScreen>
    with TickerProviderStateMixin {

  // ── Données exercice ───────────────────────────────────────────────────────
  late ExerciseGuidedData _exercise;

  // ── État séance ────────────────────────────────────────────────────────────
  _Phase _phase = _Phase.intro;
  int _currentSerie = 0;      // 0-based
  int _currentCote = 0;       // 0 = gauche/premier, 1 = droite/second (par côté)
  int _countdown = 0;         // secondes restantes (chrono)
  // ignore: unused_field — réservé pour future logique
  bool _isRunning = false;
  bool _isPaused = false;
  bool _sessionCompleted = false;

  // ── Timers & animations ────────────────────────────────────────────────────
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  // ── TTS Web (Speech Synthesis API) ────────────────────────────────────────
  bool _ttsEnabled = true;
  bool _ttsSupported = false;

  // ── Vidéo WebView ──────────────────────────────────────────────────────────
  late final String _videoViewId;
  static final Set<String> _registeredVideoIds = {};

  // ── Orientation ────────────────────────────────────────────────────────────
  bool _isLandscape = false;

  // ── Message TTS affiché ────────────────────────────────────────────────────
  String _currentVoiceText = '';

  @override
  void initState() {
    super.initState();
    _exercise = ExerciseGuidedData.fromMap(widget.exerciseData);

    // ── Autoriser toutes les orientations pour cet écran ────────────────────
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // ── Animations ───────────────────────────────────────────────────────────
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    // ── Enregistrer le lecteur vidéo ─────────────────────────────────────────
    _registerVideoPlayer();

    // ── Vérifier support TTS ─────────────────────────────────────────────────
    _checkTtsSupport();

    // ── Démarrer l'intro après un court délai ─────────────────────────────────
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startIntro();
    });
  }

  @override
  void dispose() {
    // ── Revenir au portrait seulement ────────────────────────────────────────
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    _timer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    _ttsStop();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════════
  //  VIDÉO WEBVIEW — Google Drive iframe en boucle
  // ═════════════════════════════════════════════════════════════════

  void _registerVideoPlayer() {
    _videoViewId = 'guided-video-${_exercise.id}-${DateTime.now().millisecondsSinceEpoch}';
    if (!_registeredVideoIds.contains(_videoViewId)) {
      _registeredVideoIds.add(_videoViewId);
      ui_web.platformViewRegistry.registerViewFactory(_videoViewId, (int viewId) {
        final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
        iframe.src = _exercise.videoUrl;
        iframe.setAttribute('frameborder', '0');
        iframe.setAttribute('allowfullscreen', 'true');
        iframe.setAttribute('allow', 'autoplay; fullscreen');
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        iframe.style.border = 'none';
        iframe.style.backgroundColor = '#000000';
        return iframe; // ignore: unnecessary_null_comparison
      });
    }
  }

  Widget _buildVideoPlayer() {
    return HtmlElementView(viewType: _videoViewId);
  }

  // ═════════════════════════════════════════════════════════════════
  //  TTS — Speech Synthesis API Web
  // ═════════════════════════════════════════════════════════════════

  void _checkTtsSupport() {
    if (kIsWeb) {
      try {
        // Vérifie que speechSynthesis est disponible
        _ttsSupported = true; // disponible sur tous les navigateurs modernes
      } catch (_) {
        _ttsSupported = false;
      }
    }
  }

  void _ttsSpeak(String text) {
    if (!_ttsEnabled || !_ttsSupported || text.isEmpty) return;
    try {
      final synth = web.window.speechSynthesis;
      synth.cancel(); // Annuler ce qui joue
      final utterance = web.SpeechSynthesisUtterance(text);
      utterance.lang = 'fr-FR';
      utterance.rate = 0.9;
      utterance.pitch = 1.0;
      utterance.volume = 1.0;
      synth.speak(utterance);
      if (mounted) setState(() => _currentVoiceText = text);
    } catch (e) {
      if (kDebugMode) debugPrint('TTS error: $e');
    }
  }

  void _ttsStop() {
    if (!kIsWeb || !_ttsSupported) return;
    try {
      web.window.speechSynthesis.cancel();
    } catch (_) {}
    if (mounted) setState(() => _currentVoiceText = '');
  }

  // ═════════════════════════════════════════════════════════════════
  //  LOGIQUE SÉANCE
  // ═════════════════════════════════════════════════════════════════

  void _startIntro() {
    setState(() {
      _phase = _Phase.intro;
      _currentSerie = 0;
      _currentCote = 0;
      _isRunning = false;
    });
    // TTS intro après 800ms (laisser l'écran se charger)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _ttsSpeak(_exercise.voixIntro);
    });
  }

  void _startSerie() {
    _timer?.cancel();
    _ttsStop();

    setState(() {
      _phase = _Phase.serie;
      _isRunning = true;
      _isPaused = false;
    });

    // TTS voix pendant la série
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _ttsSpeak(_exercise.voixPendant);
    });

    // Si chrono : démarrer le compte à rebours
    if (_exercise.isChronoType && _exercise.dureeSerieSec > 0) {
      setState(() => _countdown = _exercise.dureeSerieSec);
      _startCountdown(onEnd: _onSerieEnd);
    }
  }

  void _startCountdown({required VoidCallback onEnd}) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_isPaused) return;
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _countdown = 0;
          t.cancel();
          onEnd();
        }
      });
    });
  }

  void _onSerieEnd() {
    _ttsStop();

    // Cas par côté : alterner gauche/droite avant de compter une série
    if (_exercise.isParCote && _currentCote == 0) {
      setState(() => _currentCote = 1);
      _ttsSpeak('Autre côté. ${_exercise.voixPendant}');
      if (_exercise.isChronoType && _exercise.dureeSerieSec > 0) {
        setState(() => _countdown = _exercise.dureeSerieSec);
        _startCountdown(onEnd: _onSerieEnd);
      }
      return;
    }

    // Série terminée
    _currentCote = 0;
    final seriesFaites = _currentSerie + 1;

    if (seriesFaites >= _exercise.series) {
      // Toutes les séries terminées
      _startFin();
    } else {
      // Repos avant prochaine série
      _startRepos();
    }
  }

  void _startRepos() {
    _timer?.cancel();
    setState(() {
      _phase = _Phase.repos;
      _currentSerie++;
      _isRunning = false;
    });

    if (_exercise.reposSec > 0) {
      _ttsSpeak(_exercise.voixRepos);
      setState(() => _countdown = _exercise.reposSec);
      _startCountdown(onEnd: _onReposEnd);
    } else {
      // Pas de repos configuré
      _ttsSpeak(_exercise.voixRepos);
    }
  }

  void _onReposEnd() {
    if (mounted) _startSerie();
  }

  void _startFin() {
    _timer?.cancel();
    setState(() {
      _phase = _Phase.fin;
      _isRunning = false;
      _sessionCompleted = true;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _ttsSpeak(_exercise.voixFin);
    });

    // Marquer comme complété dans SharedPreferences
    _markCompleted();
  }

  Future<void> _markCompleted() async {
    try {
      await DailyExerciseService().markCompleted(_exercise.id);
    } catch (e) {
      if (kDebugMode) debugPrint('markCompleted error: $e');
    }
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      _ttsStop();
      _pulseController.stop();
    } else {
      _pulseController.repeat(reverse: true);
      if (_exercise.isChronoType && _phase == _Phase.serie) {
        _ttsSpeak(_exercise.voixPendant);
      }
    }
  }

  // ── Comptage reps manuel ──────────────────────────────────────────────────
  int _repsDone = 0;

  void _incrementRep() {
    final total = _exercise.isParCote
        ? _exercise.reps * 2
        : _exercise.reps;
    setState(() => _repsDone++);
    if (_repsDone >= total) {
      Future.delayed(const Duration(milliseconds: 300), _onSerieEnd);
    }
  }

  void _validateRepsManually() {
    // L'utilisateur valide manuellement la fin de série (si pas auto)
    _repsDone = _exercise.reps;
    _onSerieEnd();
  }



  // ═════════════════════════════════════════════════════════════════
  //  ORIENTATION
  // ═════════════════════════════════════════════════════════════════

  void _handleOrientationChange(bool isLandscape) {
    if (_isLandscape == isLandscape) return;
    setState(() => _isLandscape = isLandscape);
    if (isLandscape) {
      // Plein écran en paysage
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      // Restaurer la UI en portrait
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  // ═════════════════════════════════════════════════════════════════
  //  BUILD PRINCIPAL
  // ═════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        // Réagir au changement d'orientation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleOrientationChange(isLandscape);
        });

        if (isLandscape) {
          return _buildLandscapeLayout(context);
        }
        return _buildPortraitLayout(context);
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════
  //  LAYOUT PAYSAGE — Vidéo plein écran
  // ═════════════════════════════════════════════════════════════════

  Widget _buildLandscapeLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Vidéo plein écran ─────────────────────────────────────────
          Positioned.fill(
            child: _buildVideoPlayer(),
          ),

          // ── Overlay sombre semi-transparent (info + contrôles) ────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Bouton retour
                  GestureDetector(
                    onTap: _onBackPressed,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _exercise.titre,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Indicateur série
                  if (_phase == _Phase.serie || _phase == _Phase.repos)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Série ${_currentSerie + 1}/${_exercise.series}',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Overlay bas : chrono + contrôles ─────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_phase == _Phase.intro) ...[
                    _LandscapeButton(
                      label: 'Démarrer',
                      icon: Icons.play_arrow_rounded,
                      color: AppTheme.primary,
                      onTap: () {
                        setState(() => _repsDone = 0);
                        _startSerie();
                      },
                    ),
                  ] else if (_phase == _Phase.serie) ...[
                    // Chrono ou reps
                    if (_exercise.isChronoType)
                      _LandscapeChronoChip(seconds: _countdown, isRepos: false)
                    else
                      _LandscapeRepsChip(
                        done: _repsDone,
                        total: _exercise.isParCote
                            ? _exercise.reps * 2
                            : _exercise.reps,
                      ),
                    const SizedBox(width: 16),
                    _LandscapeButton(
                      label: _isPaused ? 'Reprendre' : 'Pause',
                      icon: _isPaused ? Icons.play_arrow : Icons.pause,
                      color: Colors.white.withValues(alpha: 0.25),
                      onTap: _togglePause,
                    ),
                    if (!_exercise.isChronoType) ...[
                      const SizedBox(width: 12),
                      _LandscapeButton(
                        label: 'Valider',
                        icon: Icons.check_circle_outline,
                        color: AppTheme.success.withValues(alpha: 0.85),
                        onTap: _validateRepsManually,
                      ),
                    ],
                  ] else if (_phase == _Phase.repos) ...[
                    _LandscapeChronoChip(seconds: _countdown, isRepos: true),
                    const SizedBox(width: 16),
                    _LandscapeButton(
                      label: 'Passer',
                      icon: Icons.skip_next,
                      color: Colors.white.withValues(alpha: 0.25),
                      onTap: _onReposEnd,
                    ),
                  ] else if (_phase == _Phase.fin) ...[
                    _LandscapeButton(
                      label: 'Terminer',
                      icon: Icons.emoji_events_outlined,
                      color: AppTheme.success,
                      onTap: _onFinish,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Tournez l'écran hint (portrait) ──────────────────────────
          // Déjà en paysage, rien à afficher
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  //  LAYOUT PORTRAIT
  // ═════════════════════════════════════════════════════════════════

  Widget _buildPortraitLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            _buildHeader(context),

            // ── Vidéo 16:9 ────────────────────────────────────────────
            _buildVideoSection(),

            // ── Contenu scrollable ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ── Phase banner ─────────────────────────────────
                      _buildPhaseBanner(),
                      const SizedBox(height: 16),

                      // ── Indicateur séries ─────────────────────────────
                      if (_phase != _Phase.intro && _phase != _Phase.fin)
                        _buildSeriesIndicator(),

                      // ── Chrono ou compteur reps ───────────────────────
                      if (_phase == _Phase.serie || _phase == _Phase.repos)
                        _buildChronoOrReps(),

                      // ── Voix TTS display ──────────────────────────────
                      if (_currentVoiceText.isNotEmpty)
                        _buildVoiceDisplay(),

                      // ── Boutons d'action ──────────────────────────────
                      const SizedBox(height: 20),
                      _buildActionButtons(context),

                      // ── Conseil rotation ──────────────────────────────
                      _buildRotationHint(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppTheme.textPrimary, size: 20),
            onPressed: _onBackPressed,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _exercise.titre,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    _DifficultyDot(difficulte: _exercise.difficulte),
                    const SizedBox(width: 4),
                    Text(
                      _difficulteLabel(_exercise.difficulte),
                      style: GoogleFonts.roboto(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3, height: 3,
                      decoration: const BoxDecoration(
                        color: AppTheme.textLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_exercise.series} séries',
                      style: GoogleFonts.roboto(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Toggle TTS
          GestureDetector(
            onTap: () {
              setState(() => _ttsEnabled = !_ttsEnabled);
              if (!_ttsEnabled) _ttsStop();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _ttsEnabled
                    ? AppTheme.primary.withValues(alpha: 0.12)
                    : AppTheme.divider,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _ttsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: _ttsEnabled ? AppTheme.primary : AppTheme.textLight,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  SECTION VIDÉO — 16:9 avec hint rotation
  // ─────────────────────────────────────────────────────────────────

  Widget _buildVideoSection() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Ratio 16:9
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildVideoPlayer(),
          ),

          // Pastille "Tournez pour agrandir"
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.screen_rotation,
                      color: Colors.white70, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'Tournez pour agrandir',
                    style: GoogleFonts.roboto(
                        color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  PHASE BANNER
  // ─────────────────────────────────────────────────────────────────

  Widget _buildPhaseBanner() {
    Color bannerColor;
    String bannerLabel;
    IconData bannerIcon;

    switch (_phase) {
      case _Phase.intro:
        bannerColor = AppTheme.primary;
        bannerLabel = 'Préparez-vous';
        bannerIcon = Icons.self_improvement_rounded;
      case _Phase.serie:
        bannerColor = _isPaused ? AppTheme.warning : AppTheme.secondary;
        bannerLabel = _isPaused
            ? 'En pause'
            : (_exercise.isParCote && _currentCote == 1
                ? 'Autre côté — Série ${_currentSerie + 1}'
                : 'Série ${_currentSerie + 1} / ${_exercise.series}');
        bannerIcon = _isPaused ? Icons.pause_circle_outline : Icons.fitness_center;
      case _Phase.repos:
        bannerColor = const Color(0xFF7E57C2);
        bannerLabel = 'Récupération';
        bannerIcon = Icons.air_rounded;
      case _Phase.fin:
        bannerColor = AppTheme.success;
        bannerLabel = 'Exercice terminé !';
        bannerIcon = Icons.emoji_events_rounded;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: bannerColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) => Transform.scale(
              scale: (_phase == _Phase.serie && !_isPaused)
                  ? _pulseAnim.value
                  : 1.0,
              child: child,
            ),
            child: Icon(bannerIcon, color: bannerColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              bannerLabel,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: bannerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  INDICATEUR SÉRIES
  // ─────────────────────────────────────────────────────────────────

  Widget _buildSeriesIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: List.generate(_exercise.series, (i) {
          final done = i < _currentSerie;
          final current = i == _currentSerie;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              decoration: BoxDecoration(
                color: done
                    ? AppTheme.success
                    : current
                        ? AppTheme.primary
                        : AppTheme.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  CHRONO OU COMPTEUR REPS
  // ─────────────────────────────────────────────────────────────────

  Widget _buildChronoOrReps() {
    final isRepos = _phase == _Phase.repos;

    if (_exercise.isChronoType || isRepos) {
      // Affichage chrono circulaire
      final maxTime = isRepos ? _exercise.reposSec : _exercise.dureeSerieSec;
      final progress = maxTime > 0 ? _countdown / maxTime : 0.0;
      final color = isRepos ? const Color(0xFF7E57C2) : AppTheme.secondary;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 8,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(_countdown),
                      style: GoogleFonts.montserrat(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      isRepos ? 'repos' : 'restantes',
                      style: GoogleFonts.roboto(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Compteur reps
      final total = _exercise.isParCote
          ? _exercise.reps * 2
          : _exercise.reps;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_repsDone',
                  style: GoogleFonts.montserrat(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.secondary,
                  ),
                ),
                Text(
                  ' / $total',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            Text(
              _exercise.isParCote
                  ? (_currentCote == 0 ? 'côté gauche' : 'côté droit')
                  : 'répétitions',
              style: GoogleFonts.roboto(
                  fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            // Bouton +1 rep
            GestureDetector(
              onTap: _isPaused ? null : _incrementRep,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _isPaused
                      ? AppTheme.divider
                      : AppTheme.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isPaused ? AppTheme.textLight : AppTheme.secondary,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 36,
                  color: _isPaused ? AppTheme.textLight : AppTheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tapez à chaque répétition',
              style: GoogleFonts.roboto(
                  fontSize: 11, color: AppTheme.textLight),
            ),
          ],
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  VOIX TTS DISPLAY
  // ─────────────────────────────────────────────────────────────────

  Widget _buildVoiceDisplay() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AnimatedOpacity(
        opacity: _currentVoiceText.isNotEmpty ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.record_voice_over_rounded,
                  color: AppTheme.primary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentVoiceText,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AppTheme.primaryDark,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  BOUTONS D'ACTION
  // ─────────────────────────────────────────────────────────────────

  Widget _buildActionButtons(BuildContext context) {
    switch (_phase) {
      case _Phase.intro:
        return Column(
          children: [
            _ActionButton(
              label: 'Commencer',
              icon: Icons.play_arrow_rounded,
              color: AppTheme.primary,
              onTap: () {
                setState(() => _repsDone = 0);
                _startSerie();
              },
            ),
          ],
        );

      case _Phase.serie:
        return Column(
          children: [
            if (!_exercise.isChronoType) ...[
              _ActionButton(
                label: 'Série terminée ✓',
                icon: Icons.check_rounded,
                color: AppTheme.success,
                onTap: _validateRepsManually,
              ),
              const SizedBox(height: 10),
            ],
            _ActionButton(
              label: _isPaused ? 'Reprendre' : 'Pause',
              icon: _isPaused ? Icons.play_arrow : Icons.pause,
              color: AppTheme.textLight,
              outlined: true,
              onTap: _togglePause,
            ),
          ],
        );

      case _Phase.repos:
        return Column(
          children: [
            _ActionButton(
              label: 'Je suis prêt(e) — Passer',
              icon: Icons.skip_next_rounded,
              color: const Color(0xFF7E57C2),
              onTap: () {
                _timer?.cancel();
                _onReposEnd();
              },
            ),
          ],
        );

      case _Phase.fin:
        return Column(
          children: [
            _ActionButton(
              label: 'Excellent ! Terminer',
              icon: Icons.emoji_events_rounded,
              color: AppTheme.success,
              onTap: _onFinish,
            ),
            const SizedBox(height: 10),
            _ActionButton(
              label: 'Recommencer',
              icon: Icons.replay_rounded,
              color: AppTheme.primary,
              outlined: true,
              onTap: () {
                setState(() {
                  _sessionCompleted = false;
                  _repsDone = 0;
                  _countdown = 0;
                  _currentVoiceText = '';
                });
                _startIntro();
              },
            ),
          ],
        );
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  HINT ROTATION
  // ─────────────────────────────────────────────────────────────────

  Widget _buildRotationHint() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.screen_rotation_outlined,
              size: 14, color: AppTheme.textLight),
          const SizedBox(width: 6),
          Text(
            'Tournez votre écran pour la vidéo plein écran',
            style: GoogleFonts.roboto(
                fontSize: 11, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  //  ACTIONS
  // ═════════════════════════════════════════════════════════════════

  void _onBackPressed() {
    _timer?.cancel();
    _ttsStop();
    if (_sessionCompleted) {
      widget.onCompleted?.call();
    }
    Navigator.of(context).pop(_sessionCompleted);
  }

  void _onFinish() {
    _ttsStop();
    widget.onCompleted?.call();
    Navigator.of(context).pop(true);
    // Afficher snackbar succès depuis le parent
  }

  // ═════════════════════════════════════════════════════════════════
  //  HELPERS
  // ═════════════════════════════════════════════════════════════════

  String _formatTime(int totalSeconds) {
    if (totalSeconds < 0) return '0:00';
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return m > 0
        ? '$m:${s.toString().padLeft(2, '0')}'
        : '0:${s.toString().padLeft(2, '0')}';
  }

  String _difficulteLabel(String d) {
    switch (d) {
      case 'debutant': return 'Débutant';
      case 'intermediaire': return 'Intermédiaire';
      case 'avance': return 'Avancé';
      default: return d;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  WIDGETS RÉUTILISABLES PORTRAIT
// ═══════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          icon: Icon(icon, size: 20),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color, width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            textStyle: GoogleFonts.montserrat(
                fontSize: 15, fontWeight: FontWeight.w600),
          ),
          onPressed: onTap,
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.montserrat(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _DifficultyDot extends StatelessWidget {
  final String difficulte;
  const _DifficultyDot({required this.difficulte});

  @override
  Widget build(BuildContext context) {
    Color c;
    switch (difficulte) {
      case 'debutant': c = AppTheme.success; break;
      case 'intermediaire': c = AppTheme.warning; break;
      case 'avance': c = AppTheme.error; break;
      default: c = AppTheme.success;
    }
    return Container(
      width: 8, height: 8,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  WIDGETS RÉUTILISABLES PAYSAGE
// ═══════════════════════════════════════════════════════════════════

class _LandscapeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LandscapeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandscapeChronoChip extends StatelessWidget {
  final int seconds;
  final bool isRepos;
  const _LandscapeChronoChip({required this.seconds, required this.isRepos});

  String _fmt(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return m > 0 ? '$m:${sec.toString().padLeft(2,'0')}' : '0:${sec.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = isRepos ? const Color(0xFF7E57C2) : AppTheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRepos ? Icons.air_rounded : Icons.timer_outlined,
            color: color, size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            _fmt(seconds),
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LandscapeRepsChip extends StatelessWidget {
  final int done;
  final int total;
  const _LandscapeRepsChip({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.secondary, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fitness_center, color: AppTheme.secondary, size: 18),
          const SizedBox(width: 8),
          Text(
            '$done / $total reps',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
