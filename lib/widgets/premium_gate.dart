import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/services/subscription_service.dart';
import '../screens/subscription/paywall_screen.dart';

/// Widget qui verrouille son contenu si l'utilisateur n'est pas Premium.
/// Usage :
///   PremiumGate(
///     featureName: 'Séances personnalisées',
///     child: SeancePersonnaliseeScreen(),
///   )
class PremiumGate extends StatelessWidget {
  final Widget child;
  final String featureName;
  final String? featureDescription;
  final IconData? featureIcon;

  const PremiumGate({
    super.key,
    required this.child,
    required this.featureName,
    this.featureDescription,
    this.featureIcon,
  });

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionService>();
    if (sub.isPremium) return child;
    return _LockedScreen(
      featureName: featureName,
      featureDescription: featureDescription,
      featureIcon: featureIcon,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Écran affiché quand une feature est verrouillée
// ─────────────────────────────────────────────────────────────────────────────
class _LockedScreen extends StatelessWidget {
  final String featureName;
  final String? featureDescription;
  final IconData? featureIcon;

  const _LockedScreen({
    required this.featureName,
    this.featureDescription,
    this.featureIcon,
  });

  static const _teal   = Color(0xFF00897B);
  static const _tealLt = Color(0xFF4DB6AC);
  static const _bg     = Color(0xFF0D1F2D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône cadenas animé
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (_, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _teal.withValues(alpha: 0.12),
                          border: Border.all(
                            color: _teal.withValues(alpha: 0.3), width: 2),
                        ),
                      ),
                      Icon(
                        featureIcon ?? Icons.lock_rounded,
                        color: _tealLt, size: 44,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Titre
                Text('Fonctionnalité Premium',
                    style: GoogleFonts.montserrat(
                      fontSize: 13, color: _tealLt,
                      fontWeight: FontWeight.w600, letterSpacing: 1.5,
                    )),
                const SizedBox(height: 10),
                Text(featureName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 24, color: Colors.white,
                      fontWeight: FontWeight.w800, height: 1.2,
                    )),
                const SizedBox(height: 14),
                Text(
                  featureDescription ??
                      'Accédez à $featureName et à toutes les fonctionnalités '
                      'avancées avec l\'abonnement SANTEO Premium.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 14, color: Colors.white54, height: 1.6,
                  ),
                ),
                const SizedBox(height: 36),

                // Prix / offre
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: _teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: _teal.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium,
                          color: Color(0xFFFFB300), size: 22),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SANTEO Premium',
                              style: GoogleFonts.montserrat(
                                fontSize: 13, color: Colors.white,
                                fontWeight: FontWeight.w700,
                              )),
                          Text('49,90 € / mois · Annulable à tout moment',
                              style: GoogleFonts.montserrat(
                                fontSize: 11, color: Colors.white.withValues(alpha: 0.45),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // CTA principal
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => PaywallScreen.show(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text('Passer à Premium',
                        style: GoogleFonts.montserrat(
                          fontSize: 16, fontWeight: FontWeight.w800,
                        )),
                  ),
                ),
                const SizedBox(height: 12),

                // Lien code promo
                TextButton(
                  onPressed: () => PaywallScreen.show(context),
                  child: Text('J\'ai un code promo',
                      style: GoogleFonts.montserrat(
                        fontSize: 13, color: Colors.white38,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white38,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Badge 🔒 à apposer sur un bouton/card pour signaler une feature premium
// ─────────────────────────────────────────────────────────────────────────────
class PremiumBadge extends StatelessWidget {
  final Widget child;
  final bool showIfPremium; // false = masquer le badge si déjà abonné

  const PremiumBadge({
    super.key,
    required this.child,
    this.showIfPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionService>();
    if (sub.isPremium && !showIfPremium) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -6, right: -6,
          child: Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFFFFB300),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock, color: Colors.white, size: 12),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Bannière compacte "Passez à Premium" pour le dashboard
// ─────────────────────────────────────────────────────────────────────────────
class PremiumBanner extends StatelessWidget {
  const PremiumBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionService>();
    if (sub.isPremium) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => PaywallScreen.show(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00897B), Color(0xFF00695C)],
            begin: Alignment.centerLeft, end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00897B).withValues(alpha: 0.3),
              blurRadius: 12, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium, color: Color(0xFFFFB300), size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Passez à SANTEO Premium',
                      style: GoogleFonts.montserrat(
                        fontSize: 13, color: Colors.white,
                        fontWeight: FontWeight.w700,
                      )),
                  Text('49,90 €/mois · Code promo disponible',
                      style: GoogleFonts.montserrat(
                        fontSize: 11, color: Colors.white70,
                      )),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Voir',
                  style: GoogleFonts.montserrat(
                    fontSize: 12, color: Colors.white,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Badge de statut d'abonnement (pour l'écran Profil)
// ─────────────────────────────────────────────────────────────────────────────
class SubscriptionStatusCard extends StatelessWidget {
  const SubscriptionStatusCard({super.key});

  static const _teal = Color(0xFF00897B);
  static const _bg   = Color(0xFF0D1F2D);

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionService>();

    return GestureDetector(
      onTap: sub.isPremium ? null : () => PaywallScreen.show(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: sub.isPremium
              ? _teal.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: sub.isPremium
                ? _teal.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: sub.isPremium
                    ? _teal.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                sub.isPremium
                    ? Icons.workspace_premium
                    : Icons.lock_outline,
                color: sub.isPremium
                    ? const Color(0xFFFFB300)
                    : Colors.white38,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sub.statusLabel,
                      style: GoogleFonts.montserrat(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: sub.isPremium ? Colors.white : Colors.white60,
                      )),
                  if (sub.isPremium && sub.daysRemaining != null)
                    Text(
                      sub.status == SubscriptionStatus.trial
                          ? 'Essai gratuit · expire le ${sub.endDateLabel}'
                          : 'Actif jusqu\'au ${sub.endDateLabel} · ${sub.daysRemaining} j. restants',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: sub.daysRemaining! < 7
                            ? Colors.orange
                            : Colors.white.withValues(alpha: 0.45),
                      ),
                    )
                  else if (!sub.isPremium)
                    Text('Accès limité · Passez à Premium',
                        style: GoogleFonts.montserrat(
                          fontSize: 11, color: Colors.white38,
                        )),
                ],
              ),
            ),
            if (!sub.isPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _teal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Activer',
                    style: GoogleFonts.montserrat(
                      fontSize: 11, color: Colors.white,
                      fontWeight: FontWeight.w700,
                    )),
              ),
          ],
        ),
      ),
    );
  }
}
