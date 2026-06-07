import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/assets/logo_data.dart';
import '../../widgets/common/common_widgets.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // === HERO SECTION ===
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF26C6DA), Color(0xFF00838F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 44, 24, 40),
                  child: Column(
                    children: [
                      // Logo SANTEO — cercle blanc + couleurs originales sur fond teal
                      Image.memory(
                        SanteoLogoData.bytes,
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Votre kiné en poche,',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 26,
                          color: Colors.white,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'votre santé en main.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 26,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.3,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Commencer l\'évaluation gratuite',
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/login'),
                        child: Text(
                          'Déjà un compte ? Se connecter',
                          style: GoogleFonts.roboto(
                              color: Colors.white70, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // === FEATURES SECTION ===
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Votre santé, partout dans le Pacifique',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FeatureItem(
                      icon: Icons.psychology,
                      color: AppTheme.primary,
                      title: 'Bilan IA Personnalisé',
                      description:
                          'Évaluation intelligente adaptée à votre profil et au contexte insulaire du Pacifique.',
                    ),
                    _FeatureItem(
                      icon: Icons.fitness_center,
                      color: AppTheme.secondary,
                      title: 'Exercices Sans Équipement',
                      description:
                          'Programmes adaptés au climat tropical, faisables à domicile sans matériel.',
                    ),
                    _FeatureItem(
                      icon: Icons.trending_up,
                      color: AppTheme.success,
                      title: 'Suivi & Progression',
                      description:
                          'Analyse hebdomadaire IA de vos progrès avec recommandations personnalisées.',
                    ),
                    _FeatureItem(
                      icon: Icons.video_call,
                      color: const Color(0xFF7E57C2),
                      title: 'Télérééducation',
                      description:
                          'Détection automatique des signaux d\'alerte pour consultation professionnelle.',
                    ),

                    const SizedBox(height: 24),

                    // Territories
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.public,
                                  color: AppTheme.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Disponible sur tous les territoires',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              'Nouvelle-Calédonie',
                              'Polynésie française',
                              'Wallis-et-Futuna',
                              'Vanuatu',
                              'Fidji',
                              '& plus...',
                            ].map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                t,
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Commencer gratuitement',
                      icon: Icons.arrow_forward,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
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
