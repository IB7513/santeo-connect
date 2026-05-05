import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/assets/logo_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/motivation_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/common_widgets.dart';
import '../dashboard/assessment_result_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Étape 1 — Profil
  final _prenomCtrl = TextEditingController();
  String? _age;
  String? _territoire;

  // Étape 2 — Bilan corporel kiné
  bool _douleursOuiNon = false;
  final List<String> _zonesDouleur = [];
  double _niveauMobilite = 3;
  String? _niveauActivite;
  final List<String> _problemesSante = [];

  // Étape 3 — Programme
  String? _objectif;
  String? _dureeSeance;
  String? _frequenceSemaine;
  final List<String> _preferencesExercices = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      final name = provider.userName ?? '';
      if (name.isNotEmpty && _prenomCtrl.text.isEmpty) {
        _prenomCtrl.text = name;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _prenomCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _showStepCongrats(_currentPage);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _submitOnboarding();
    }
  }

  void _showStepCongrats(int completedStep) {
    final provider = context.read<AppProvider>();
    final prenom = _prenomCtrl.text.isNotEmpty
        ? _prenomCtrl.text
        : (provider.userName ?? '');
    final message = MotivationService.stepCompleted(completedStep, prenom);

    final stepColors = [
      const Color(0xFF26C6DA),
      const Color(0xFF7E57C2),
      const Color(0xFFFF9E80),
    ];
    final stepIcons = [
      Icons.person_outline,
      Icons.health_and_safety,
      Icons.tune,
    ];
    final color = completedStep < stepColors.length
        ? stepColors[completedStep]
        : AppTheme.primary;
    final icon = completedStep < stepIcons.length
        ? stepIcons[completedStep]
        : Icons.check_circle;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Étape ${completedStep + 1} complétée !',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      message,
                      style: GoogleFonts.roboto(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitOnboarding() async {
    final provider = context.read<AppProvider>();
    final userName = provider.userName ?? '';

    provider.updateOnboardingData({
      'prenom': _prenomCtrl.text.isNotEmpty ? _prenomCtrl.text : userName,
      'age': _age ?? '',
      'genre': '',
      'localisation': _territoire ?? 'Pacifique',
      'objectifSante': _objectif ?? '',
      'douleursActuelles': _douleursOuiNon,
      'zonesDouleur': _zonesDouleur,
      'niveauMobilite': _niveauMobilite.round(),
      'niveauActivite': _niveauActivite ?? '',
      'problemesSante': _problemesSante,
      'chirurgies': '',
      'traitements': '',
      'dureeSeance': _dureeSeance ?? '20 minutes',
      'frequenceSemaine': _frequenceSemaine ?? '3 jours/semaine',
      'preferencesExercices': _preferencesExercices,
    });

    await provider.completeOnboarding();

    if (mounted) {
      await _showCelebrationDialog();
    }
  }

  Future<void> _showCelebrationDialog() async {
    final provider = context.read<AppProvider>();
    final prenom = _prenomCtrl.text.isNotEmpty
        ? _prenomCtrl.text
        : (provider.userName ?? 'vous');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF26C6DA), Color(0xFF00838F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.celebration,
                    color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),
              Text(
                '🎊 Félicitations, $prenom !',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                'Votre bilan kiné est complet !\nL\'intelligence artificielle de SANTEO Connect va maintenant générer votre programme personnalisé, adapté à votre contexte de vie dans le Pacifique.',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.6),
              ),
              const SizedBox(height: 8),
              Text(
                MotivationService.randomPacificMsg(),
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.4),
              ),
              const SizedBox(height: 24),
              // 3 cercles (au lieu de 4)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    3,
                    (i) => Container(
                          width: 28,
                          height: 28,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check,
                              color: Color(0xFF26C6DA), size: 16),
                        )),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF26C6DA),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.psychology),
                  label: Text(
                    'Voir mon programme',
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AssessmentResultScreen(
                              fromOnboarding: true)),
                      (r) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: _prevPage,
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Étape ${_currentPage + 1} sur 3',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: (_currentPage + 1) / 3,
                          backgroundColor: AppTheme.divider,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primary),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Image.memory(
                      SanteoLogoData.bytes,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            // ── Pages ────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  // ── ÉTAPE 1 : Votre profil ───────────────────
                  _KineStep1Profil(
                    prenomCtrl: _prenomCtrl,
                    age: _age,
                    territoire: _territoire,
                    onAgeChanged: (v) => setState(() => _age = v),
                    onTerritoireChanged: (v) =>
                        setState(() => _territoire = v),
                  ),

                  // ── ÉTAPE 2 : Bilan corporel kiné ────────────
                  _KineStep2Bilan(
                    douleursOuiNon: _douleursOuiNon,
                    zonesDouleur: _zonesDouleur,
                    niveauMobilite: _niveauMobilite,
                    niveauActivite: _niveauActivite,
                    problemesSante: _problemesSante,
                    onDouleursChanged: (v) =>
                        setState(() => _douleursOuiNon = v),
                    onZoneToggle: (z, checked) {
                      setState(() {
                        if (checked) {
                          _zonesDouleur.add(z);
                        } else {
                          _zonesDouleur.remove(z);
                        }
                      });
                    },
                    onMobiliteChanged: (v) =>
                        setState(() => _niveauMobilite = v),
                    onActiviteChanged: (v) =>
                        setState(() => _niveauActivite = v),
                    onProblemeToggle: (p, checked) {
                      setState(() {
                        if (checked) {
                          _problemesSante.add(p);
                        } else {
                          _problemesSante.remove(p);
                        }
                      });
                    },
                  ),

                  // ── ÉTAPE 3 : Votre programme ────────────────
                  _KineStep3Programme(
                    objectif: _objectif,
                    dureeSeance: _dureeSeance,
                    frequenceSemaine: _frequenceSemaine,
                    preferencesExercices: _preferencesExercices,
                    onObjectifChanged: (v) => setState(() => _objectif = v),
                    onDureeChanged: (v) => setState(() => _dureeSeance = v),
                    onFrequenceChanged: (v) =>
                        setState(() => _frequenceSemaine = v),
                    onPrefToggle: (p, checked) {
                      setState(() {
                        if (checked) {
                          _preferencesExercices.add(p);
                        } else {
                          _preferencesExercices.remove(p);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            // ── Bottom CTA ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: WormEffect(
                      dotColor: AppTheme.divider,
                      activeDotColor: AppTheme.primary,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: _currentPage < 2
                        ? 'Suivant'
                        : 'Générer mon programme personnalisé',
                    icon: _currentPage < 2
                        ? Icons.arrow_forward
                        : Icons.psychology,
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ÉTAPE 1 : Votre profil
// ================================================================
class _KineStep1Profil extends StatelessWidget {
  final TextEditingController prenomCtrl;
  final String? age;
  final String? territoire;
  final ValueChanged<String?> onAgeChanged;
  final ValueChanged<String?> onTerritoireChanged;

  const _KineStep1Profil({
    required this.prenomCtrl,
    required this.age,
    required this.territoire,
    required this.onAgeChanged,
    required this.onTerritoireChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            icon: Icons.person,
            title: 'Votre profil',
            subtitle:
                'Quelques informations pour personnaliser votre prise en charge.',
          ),
          const SizedBox(height: 24),

          // Prénom — pré-rempli depuis l'inscription
          if (prenomCtrl.text.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color:
                    const Color(0xFF26C6DA).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF26C6DA)
                        .withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline,
                      color: Color(0xFF26C6DA), size: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prénom',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[600])),
                      Text(prenomCtrl.text,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.check_circle,
                      color: Color(0xFF26C6DA), size: 18),
                ],
              ),
            )
          else
            TextField(
              controller: prenomCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Prénom',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
          const SizedBox(height: 14),

          _SanteoDropdown(
            label: 'Tranche d\'âge',
            value: age,
            items: AppConstants.ageGroups,
            icon: Icons.cake_outlined,
            onChanged: onAgeChanged,
          ),
          const SizedBox(height: 14),

          _SanteoDropdown(
            label: 'Territoire / Région',
            value: territoire,
            items: AppConstants.territories,
            icon: Icons.location_on_outlined,
            onChanged: onTerritoireChanged,
          ),
          const SizedBox(height: 24),

          // Encart informatif style kiné
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF26C6DA).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color:
                      const Color(0xFF26C6DA).withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFF26C6DA), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ce bilan est réalisé sur le modèle d\'une consultation kiné initiale. Vos réponses permettent de générer un programme de rééducation adapté à votre profil Pacifique.',
                    style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ÉTAPE 2 : Bilan corporel kiné (fusion fonctionnel + antécédents)
// ================================================================
class _KineStep2Bilan extends StatelessWidget {
  final bool douleursOuiNon;
  final List<String> zonesDouleur;
  final double niveauMobilite;
  final String? niveauActivite;
  final List<String> problemesSante;
  final ValueChanged<bool> onDouleursChanged;
  final Function(String, bool) onZoneToggle;
  final ValueChanged<double> onMobiliteChanged;
  final ValueChanged<String?> onActiviteChanged;
  final Function(String, bool) onProblemeToggle;

  const _KineStep2Bilan({
    required this.douleursOuiNon,
    required this.zonesDouleur,
    required this.niveauMobilite,
    required this.niveauActivite,
    required this.problemesSante,
    required this.onDouleursChanged,
    required this.onZoneToggle,
    required this.onMobiliteChanged,
    required this.onActiviteChanged,
    required this.onProblemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            icon: Icons.health_and_safety,
            title: 'Bilan corporel',
            subtitle:
                'Évaluation fonctionnelle style kiné — douleurs, mobilité et antécédents.',
          ),
          const SizedBox(height: 20),

          // ── Douleurs ────────────────────────────────────────
          _SectionLabel(label: 'DOULEURS ACTUELLES'),
          const SizedBox(height: 8),
          SanteoCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ressentez-vous des douleurs ?',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppTheme.textPrimary)),
                      Text(
                          douleursOuiNon
                              ? 'Sélectionnez les zones concernées'
                              : 'Aucune douleur signalée',
                          style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Switch(
                  value: douleursOuiNon,
                  onChanged: onDouleursChanged,
                  activeThumbColor: AppTheme.primary,
                ),
              ],
            ),
          ),

          if (douleursOuiNon) ...[
            const SizedBox(height: 12),
            Text('Zones douloureuses',
                style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.painZones.map((zone) {
                final isSelected = zonesDouleur.contains(zone);
                return FilterChip(
                  label: Text(zone,
                      style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textPrimary)),
                  selected: isSelected,
                  onSelected: (checked) => onZoneToggle(zone, checked),
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.surface,
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.divider),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 16),

          // ── Mobilité ─────────────────────────────────────────
          _SectionLabel(label: 'ÉVALUATION FONCTIONNELLE'),
          const SizedBox(height: 8),
          SanteoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mobilité globale',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppTheme.textPrimary)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _mobiliteLabel(niveauMobilite.round()),
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                    'Évaluez votre capacité à effectuer vos gestes quotidiens.',
                    style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: AppTheme.textSecondary)),
                Slider(
                  value: niveauMobilite,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  activeColor: AppTheme.primary,
                  onChanged: onMobiliteChanged,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Très limitée',
                        style: GoogleFonts.roboto(
                            fontSize: 11,
                            color: AppTheme.textLight)),
                    Text('Excellente',
                        style: GoogleFonts.roboto(
                            fontSize: 11,
                            color: AppTheme.textLight)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _SanteoDropdown(
            label: 'Niveau d\'activité physique',
            value: niveauActivite,
            items: AppConstants.activityLevels,
            icon: Icons.directions_run,
            onChanged: onActiviteChanged,
          ),
          const SizedBox(height: 16),

          // ── Antécédents (condensés) ───────────────────────────
          _SectionLabel(label: 'ANTÉCÉDENTS MÉDICAUX'),
          const SizedBox(height: 8),
          Text('Problèmes de santé (sélectionnez tout ce qui s\'applique)',
              style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.healthProblems.map((p) {
              final isSelected = problemesSante.contains(p);
              return FilterChip(
                label: Text(p,
                    style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textPrimary)),
                selected: isSelected,
                onSelected: (checked) => onProblemeToggle(p, checked),
                selectedColor: const Color(0xFF7E57C2),
                backgroundColor: AppTheme.surface,
                checkmarkColor: Colors.white,
                side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF7E57C2)
                        : AppTheme.divider),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _mobiliteLabel(int val) {
    switch (val) {
      case 1:
        return 'Très limitée';
      case 2:
        return 'Limitée';
      case 3:
        return 'Moyenne';
      case 4:
        return 'Bonne';
      case 5:
        return 'Excellente';
      default:
        return '$val/5';
    }
  }
}

// ================================================================
// ÉTAPE 3 : Votre programme
// ================================================================
class _KineStep3Programme extends StatelessWidget {
  final String? objectif;
  final String? dureeSeance;
  final String? frequenceSemaine;
  final List<String> preferencesExercices;
  final ValueChanged<String?> onObjectifChanged;
  final ValueChanged<String?> onDureeChanged;
  final ValueChanged<String?> onFrequenceChanged;
  final Function(String, bool) onPrefToggle;

  const _KineStep3Programme({
    required this.objectif,
    required this.dureeSeance,
    required this.frequenceSemaine,
    required this.preferencesExercices,
    required this.onObjectifChanged,
    required this.onDureeChanged,
    required this.onFrequenceChanged,
    required this.onPrefToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            icon: Icons.tune,
            title: 'Votre programme',
            subtitle:
                'Définissez votre objectif et organisez vos séances selon votre rythme de vie.',
          ),
          const SizedBox(height: 20),

          _SectionLabel(label: 'OBJECTIF THÉRAPEUTIQUE'),
          const SizedBox(height: 8),
          _SanteoDropdown(
            label: 'Objectif principal',
            value: objectif,
            items: AppConstants.healthGoals,
            icon: Icons.flag_outlined,
            onChanged: onObjectifChanged,
          ),
          const SizedBox(height: 16),

          _SectionLabel(label: 'ORGANISATION DES SÉANCES'),
          const SizedBox(height: 8),
          _SanteoDropdown(
            label: 'Durée des séances',
            value: dureeSeance,
            items: AppConstants.sessionDurations,
            icon: Icons.timer_outlined,
            onChanged: onDureeChanged,
          ),
          const SizedBox(height: 14),

          _SanteoDropdown(
            label: 'Fréquence hebdomadaire',
            value: frequenceSemaine,
            items: AppConstants.weeklyFrequencies,
            icon: Icons.calendar_today_outlined,
            onChanged: onFrequenceChanged,
          ),
          const SizedBox(height: 16),

          _SectionLabel(label: 'TYPES D\'EXERCICES'),
          const SizedBox(height: 8),
          Text('Vos préférences (optionnel)',
              style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.exercisePreferences.map((p) {
              final isSelected = preferencesExercices.contains(p);
              return FilterChip(
                label: Text(p,
                    style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textPrimary)),
                selected: isSelected,
                onSelected: (checked) => onPrefToggle(p, checked),
                selectedColor: AppTheme.primary,
                backgroundColor: AppTheme.surface,
                checkmarkColor: Colors.white,
                side: BorderSide(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.divider),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Encart IA final
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF26C6DA), Color(0xFF00838F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.psychology,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bilan Personnalisé SANTEO',
                          style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                          'Notre IA kiné va analyser votre bilan et générer un programme de rééducation adapté au Pacifique.',
                          style: GoogleFonts.roboto(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ================================================================
// SHARED HELPERS
// ================================================================
class _StepHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _StepHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              Text(subtitle,
                  style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _SanteoDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _SanteoDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item,
                    style: GoogleFonts.roboto(
                        fontSize: 14, color: AppTheme.textPrimary)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
