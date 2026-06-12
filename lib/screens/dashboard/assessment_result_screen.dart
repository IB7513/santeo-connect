import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/motivation_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/common_widgets.dart';
import '../home_navigator.dart';

class AssessmentResultScreen extends StatefulWidget {
  final bool fromOnboarding;
  const AssessmentResultScreen({super.key, this.fromOnboarding = false});

  @override
  State<AssessmentResultScreen> createState() =>
      _AssessmentResultScreenState();
}

class _AssessmentResultScreenState extends State<AssessmentResultScreen> {
  bool _congratsShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      if (provider.aiAssessment == null) {
        provider.generateAssessment();
      } else if (!_congratsShown) {
        _showCongratsIfReady(provider);
      }
    });
  }

  void _showCongratsIfReady(AppProvider provider) {
    if (_congratsShown) return;
    _congratsShown = true;
    final prenom = provider.userProfile?.prenom ?? provider.userName ?? '';
    final msg = MotivationService.assessmentReady(prenom);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  msg,
                  style: GoogleFonts.roboto(
                      color: Colors.white, fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Header gradient
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF26C6DA), Color(0xFF00838F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.psychology,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mon Programme Personnalisé',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '100% local · Adapté au Pacifique',
                                  style: GoogleFonts.roboto(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          // Badge IA locale
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.offline_bolt,
                                    color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Offline',
                                  style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: provider.isLoadingAssessment
                      ? _LoadingAssessment()
                      : provider.assessmentError != null
                          ? _ErrorAssessment(
                              error: provider.assessmentError!,
                              onRetry: () => provider.generateAssessment(),
                            )
                          : Builder(builder: (context) {
                              // Show congrats when assessment is ready
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!_congratsShown && provider.aiAssessment != null) {
                                  _showCongratsIfReady(provider);
                                }
                              });
                              return _AssessmentContent(
                                assessment: provider.aiAssessment ?? '',
                                profile: provider.userProfile,
                              );
                            }),
                ),

                // Bottom CTA
                if (!provider.isLoadingAssessment)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 14),
                        PrimaryButton(
                          label: 'Accéder à mon tableau de bord',
                          icon: Icons.dashboard,
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeNavigator()),
                              (r) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// LOADING
// ============================================================
class _LoadingAssessment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child:
                const Icon(Icons.psychology, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            'Génération de votre bilan...',
            style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'Notre IA analyse votre profil et adapte les recommandations au contexte insulaire du Pacifique.\nAucune connexion internet requise.',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.6),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(color: AppTheme.primary),
          const SizedBox(height: 24),
          _LoadingStep('Analyse du profil fonctionnel...', true),
          _LoadingStep('Adaptation au contexte Pacifique...', true),
          _LoadingStep('Génération des recommandations...', false),
          _LoadingStep('Création du programme personnalisé...', false),
        ],
      ),
    );
  }
}

class _LoadingStep extends StatelessWidget {
  final String label;
  final bool done;
  const _LoadingStep(this.label, this.done);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? AppTheme.success : AppTheme.textLight,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: done ? AppTheme.textPrimary : AppTheme.textLight)),
        ],
      ),
    );
  }
}

// ============================================================
// ERREUR
// ============================================================
class _ErrorAssessment extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorAssessment({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.error_outline,
                color: AppTheme.error, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de génération',
            style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Réessayer',
            icon: Icons.refresh,
            onPressed: onRetry,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeNavigator()),
              (r) => false,
            ),
            icon: const Icon(Icons.dashboard_outlined),
            label: const Text('Continuer sans bilan'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CONTENU DU BILAN
// ============================================================
class _AssessmentContent extends StatelessWidget {
  final String assessment;
  final dynamic profile;

  const _AssessmentContent({required this.assessment, this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte profil
          if (profile != null) ...[
            SanteoCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF26C6DA), Color(0xFF4DD0E1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.prenom.isNotEmpty
                              ? profile.prenom[0].toUpperCase() + profile.prenom.substring(1)
                              : profile.prenom,
                          style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        if (profile.age.isNotEmpty)
                          Text(
                            '${profile.age} · ${profile.localisation}',
                            style: GoogleFonts.roboto(
                                color: Colors.white70, fontSize: 13),
                          ),
                        if (profile.objectifSante.isNotEmpty)
                          Text(
                            'Objectif : ${profile.objectifSante}',
                            style: GoogleFonts.roboto(
                                color: Colors.white70, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Badge IA locale
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppTheme.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.offline_bolt,
                    color: AppTheme.success, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Généré localement · 100% privé · Sans internet',
                  style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AppTheme.success,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Titre
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Votre Bilan Personnalisé',
                style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Contenu bilan
          SanteoCard(
            padding: const EdgeInsets.all(20),
            child: Text(
              assessment.isNotEmpty
                  ? assessment
                  : 'Bilan en cours de génération...',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Confirmation sauvegarde
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: AppTheme.success, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bilan sauvegardé sur votre appareil. Accessible hors connexion à tout moment.',
                    style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: AppTheme.success,
                        fontWeight: FontWeight.w500),
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
