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

  // Step 1 - Profil
  final _prenomCtrl = TextEditingController();
  String? _age;
  String? _genre;
  final _villeCtrl = TextEditingController();
  String? _objectif;

  // Step 2 - État Fonctionnel
  bool _douleursOuiNon = false;
  final List<String> _zonesDouleur = [];
  double _niveauMobilite = 3;
  String? _niveauActivite;

  // Step 3 - Antécédents
  final List<String> _problemesSante = [];
  final _chirurgiesCtrl = TextEditingController();
  final _traitementsCtrl = TextEditingController();

  // Step 4 - Préférences
  String? _dureeSeance;
  String? _frequenceSemaine;
  final List<String> _preferencesExercices = [];

  @override
  void initState() {
    super.initState();
    // Pré-remplir le prénom depuis l'inscription pour éviter de le demander 2 fois
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
    _villeCtrl.dispose();
    _chirurgiesCtrl.dispose();
    _traitementsCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      // 🎉 Félicitations à chaque étape
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

    // Couleurs et icônes par étape
    final stepColors = [
      const Color(0xFF26C6DA),
      const Color(0xFF7E57C2),
      const Color(0xFFFF9E80),
    ];
    final stepIcons = [
      Icons.person_outline,
      Icons.health_and_safety,
      Icons.medical_information,
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
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
      'genre': _genre ?? '',
      'localisation': _villeCtrl.text.isNotEmpty ? _villeCtrl.text : 'Pacifique',
      'objectifSante': _objectif ?? '',
      'douleursActuelles': _douleursOuiNon,
      'zonesDouleur': _zonesDouleur,
      'niveauMobilite': _niveauMobilite.round(),
      'niveauActivite': _niveauActivite ?? '',
      'problemesSante': _problemesSante,
      'chirurgies': _chirurgiesCtrl.text,
      'traitements': _traitementsCtrl.text,
      'dureeSeance': _dureeSeance ?? '20 minutes',
      'frequenceSemaine': _frequenceSemaine ?? '3 jours/semaine',
      'preferencesExercices': _preferencesExercices,
    });

    await provider.completeOnboarding();

    if (mounted) {
      // 🎉 Dialog de célébration avant navigation
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                'Votre profil est 100% complet !\nL\'intelligence artificielle de SANTEO Connect va maintenant générer votre bilan personnalisé, adapté à votre contexte de vie dans le Pacifique.',
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
              // Étapes complétées
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
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
                    'Voir mon bilan IA',
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
            // Header
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
                          'Étape ${_currentPage + 1} sur 4',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: (_currentPage + 1) / 4,
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

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _Step1Profil(
                    prenomCtrl: _prenomCtrl,
                    age: _age,
                    genre: _genre,
                    villeCtrl: _villeCtrl,
                    objectif: _objectif,
                    onAgeChanged: (v) => setState(() => _age = v),
                    onGenreChanged: (v) => setState(() => _genre = v),
                    onObjectifChanged: (v) => setState(() => _objectif = v),
                  ),
                  _Step2Fonctionnel(
                    douleursOuiNon: _douleursOuiNon,
                    zonesDouleur: _zonesDouleur,
                    niveauMobilite: _niveauMobilite,
                    niveauActivite: _niveauActivite,
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
                  ),
                  _Step3Antecedents(
                    problemesSante: _problemesSante,
                    chirurgiesCtrl: _chirurgiesCtrl,
                    traitementsCtrl: _traitementsCtrl,
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
                  _Step4Preferences(
                    dureeSeance: _dureeSeance,
                    frequenceSemaine: _frequenceSemaine,
                    preferencesExercices: _preferencesExercices,
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

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 4,
                    effect: WormEffect(
                      dotColor: AppTheme.divider,
                      activeDotColor: AppTheme.primary,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: _currentPage < 3
                        ? 'Suivant'
                        : 'Générer mon bilan personnalisé avec IA',
                    icon: _currentPage < 3
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

// ============================================================
// STEP 1: Profil
// ============================================================
class _Step1Profil extends StatelessWidget {
  final TextEditingController prenomCtrl;
  final String? age;
  final String? genre;
  final TextEditingController villeCtrl;
  final String? objectif;
  final ValueChanged<String?> onAgeChanged;
  final ValueChanged<String?> onGenreChanged;
  final ValueChanged<String?> onObjectifChanged;

  const _Step1Profil({
    required this.prenomCtrl,
    required this.age,
    required this.genre,
    required this.villeCtrl,
    required this.objectif,
    required this.onAgeChanged,
    required this.onGenreChanged,
    required this.onObjectifChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.person,
            title: 'Votre profil',
            subtitle: 'Dites-nous qui vous êtes pour personnaliser votre expérience.',
          ),
          const SizedBox(height: 20),
          // Le prénom est déjà saisi à l'inscription — on l'affiche en lecture seule
          if (prenomCtrl.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF26C6DA).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF26C6DA).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: Color(0xFF26C6DA), size: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prénom', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      Text(prenomCtrl.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.check_circle, color: Color(0xFF26C6DA), size: 18),
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
            label: 'Genre',
            value: genre,
            items: const ['Femme', 'Homme', 'Autre'],
            icon: Icons.wc,
            onChanged: onGenreChanged,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: villeCtrl,
            decoration: const InputDecoration(
              labelText: 'Ville / Territoire',
              prefixIcon: Icon(Icons.location_on_outlined),
              hintText: 'Ex: Nouméa, Nouvelle-Calédonie',
            ),
          ),
          const SizedBox(height: 14),
          _SanteoDropdown(
            label: 'Objectif santé',
            value: objectif,
            items: AppConstants.healthGoals,
            icon: Icons.flag_outlined,
            onChanged: onObjectifChanged,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STEP 2: État Fonctionnel
// ============================================================
class _Step2Fonctionnel extends StatelessWidget {
  final bool douleursOuiNon;
  final List<String> zonesDouleur;
  final double niveauMobilite;
  final String? niveauActivite;
  final ValueChanged<bool> onDouleursChanged;
  final Function(String, bool) onZoneToggle;
  final ValueChanged<double> onMobiliteChanged;
  final ValueChanged<String?> onActiviteChanged;

  const _Step2Fonctionnel({
    required this.douleursOuiNon,
    required this.zonesDouleur,
    required this.niveauMobilite,
    required this.niveauActivite,
    required this.onDouleursChanged,
    required this.onZoneToggle,
    required this.onMobiliteChanged,
    required this.onActiviteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.health_and_safety,
            title: 'État fonctionnel',
            subtitle: 'Évaluez votre condition physique actuelle.',
          ),
          const SizedBox(height: 20),

          // Douleurs toggle
          SanteoCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Douleurs actuelles ?',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppTheme.textPrimary)),
                      Text('Ressentez-vous des douleurs en ce moment ?',
                          style: GoogleFonts.roboto(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Switch(
                  value: douleursOuiNon,
                  onChanged: onDouleursChanged,
                  activeColor: AppTheme.primary, activeThumbColor: AppTheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (douleursOuiNon) ...[
            Text('Zones douloureuses',
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.painZones.map((zone) {
                final isSelected = zonesDouleur.contains(zone);
                return FilterChip(
                  label: Text(zone,
                      style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: isSelected ? Colors.white : AppTheme.textPrimary)),
                  selected: isSelected,
                  onSelected: (checked) => onZoneToggle(zone, checked),
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.surface,
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                      color: isSelected ? AppTheme.primary : AppTheme.divider),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          // Mobilité slider
          SanteoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Niveau de mobilité',
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
                        '${niveauMobilite.round()}/5',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
                Text('Comment évaluez-vous votre mobilité globale ?',
                    style: GoogleFonts.roboto(
                        fontSize: 12, color: AppTheme.textSecondary)),
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
                            fontSize: 11, color: AppTheme.textLight)),
                    Text('Excellente',
                        style: GoogleFonts.roboto(
                            fontSize: 11, color: AppTheme.textLight)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          _SanteoDropdown(
            label: 'Niveau d\'activité physique',
            value: niveauActivite,
            items: AppConstants.activityLevels,
            icon: Icons.directions_run,
            onChanged: onActiviteChanged,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STEP 3: Antécédents
// ============================================================
class _Step3Antecedents extends StatelessWidget {
  final List<String> problemesSante;
  final TextEditingController chirurgiesCtrl;
  final TextEditingController traitementsCtrl;
  final Function(String, bool) onProblemeToggle;

  const _Step3Antecedents({
    required this.problemesSante,
    required this.chirurgiesCtrl,
    required this.traitementsCtrl,
    required this.onProblemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.medical_information,
            title: 'Antécédents médicaux',
            subtitle: 'Ces informations permettent d\'adapter votre programme en toute sécurité.',
          ),
          const SizedBox(height: 20),

          Text('Problèmes de santé (sélectionnez tout ce qui s\'applique)',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
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
                        color: isSelected ? Colors.white : AppTheme.textPrimary)),
                selected: isSelected,
                onSelected: (checked) => onProblemeToggle(p, checked),
                selectedColor: AppTheme.secondary,
                backgroundColor: AppTheme.surface,
                checkmarkColor: Colors.white,
                side: BorderSide(
                    color: isSelected ? AppTheme.secondary : AppTheme.divider),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: chirurgiesCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Chirurgies passées (optionnel)',
              prefixIcon: Icon(Icons.content_cut_outlined),
              hintText: 'Ex: Appendicite 2018, Ligaments croisés 2022...',
            ),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: traitementsCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Traitements en cours (optionnel)',
              prefixIcon: Icon(Icons.medication_outlined),
              hintText: 'Ex: Anti-inflammatoires, kiné hebdomadaire...',
            ),
          ),
          const SizedBox(height: 14),

        ],
      ),
    );
  }
}

// ============================================================
// STEP 4: Préférences
// ============================================================
class _Step4Preferences extends StatelessWidget {
  final String? dureeSeance;
  final String? frequenceSemaine;
  final List<String> preferencesExercices;
  final ValueChanged<String?> onDureeChanged;
  final ValueChanged<String?> onFrequenceChanged;
  final Function(String, bool) onPrefToggle;

  const _Step4Preferences({
    required this.dureeSeance,
    required this.frequenceSemaine,
    required this.preferencesExercices,
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
          _StepHeader(
            icon: Icons.tune,
            title: 'Vos préférences',
            subtitle: 'Personnalisez votre programme selon votre emploi du temps.',
          ),
          const SizedBox(height: 20),

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

          Text('Types d\'exercices préférés',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
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
                        color: isSelected ? Colors.white : AppTheme.textPrimary)),
                selected: isSelected,
                onSelected: (checked) => onPrefToggle(p, checked),
                selectedColor: AppTheme.primary,
                backgroundColor: AppTheme.surface,
                checkmarkColor: Colors.white,
                side: BorderSide(
                    color: isSelected ? AppTheme.primary : AppTheme.divider),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // AI Info Card
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
                      Text('Bilan IA Personnalisé',
                          style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                          'Notre IA va analyser votre profil et générer un bilan personnalisé adapté au contexte Pacifique.',
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
        ],
      ),
    );
  }
}

// ============================================================
// SHARED HELPERS
// ============================================================
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
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
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.3)),
            ],
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
