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
                            'Commencer mon programme',
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
                      'Conçu pour les zones éloignées, utile partout',
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
                      title: 'Programme personnalisé',
                      description:
                          'Répondez à quelques questions et recevez un programme de mouvements adapté à votre profil.',
                    ),
                    _FeatureItem(
                      icon: Icons.fitness_center,
                      color: AppTheme.secondary,
                      title: 'Exercices guidés, sans matériel',
                      description:
                          'Des séances simples et efficaces, réalisables à domicile, avec vidéo et coaching vocal.',
                    ),
                    _FeatureItem(
                      icon: Icons.trending_up,
                      color: AppTheme.success,
                      title: 'Suivi & progression',
                      description:
                          'Visualisez vos progrès semaine après semaine et recevez des conseils adaptés.',
                    ),
                    _FeatureItem(
                      icon: Icons.support_agent,
                      color: const Color(0xFF7E57C2),
                      title: 'Accompagnement professionnel',
                      description:
                          'Accédez à des conseils de professionnels du mouvement, où que vous soyez.',
                    ),

                    const SizedBox(height: 24),

                    // Chiffres clés
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatChip(
                            value: '19,90€',
                            label: 'Par mois\nseulement',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppTheme.divider,
                          ),
                          _StatChip(
                            value: '5 min',
                            label: 'Pour démarrer\nvotre programme',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppTheme.divider,
                          ),
                          _StatChip(
                            value: '',
                            label: 'Exercices\nguidés',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Démarrer mon programme',
                      icon: Icons.arrow_forward,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                    ),
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

// ── Widget feature ─────────────────────────────────────────────────────────
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

// ── Widget stat ─────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String value;
  final String label;

  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (value.isNotEmpty) ...[
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: 11,
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
