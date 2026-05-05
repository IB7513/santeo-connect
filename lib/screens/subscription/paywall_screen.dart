import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/services/subscription_service.dart';

class PaywallScreen extends StatefulWidget {
  /// Si true → modal (retour possible), si false → écran bloquant
  final bool canDismiss;
  const PaywallScreen({super.key, this.canDismiss = true});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();

  static Future<void> show(BuildContext context, {bool canDismiss = true}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: canDismiss,
      enableDrag: canDismiss,
      builder: (_) => PaywallScreen(canDismiss: canDismiss),
    );
  }
}

class _PaywallScreenState extends State<PaywallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  final _promoCtrl = TextEditingController();
  bool _promoLoading = false;
  String? _promoError;
  bool _promoSuccess = false;
  bool _payLoading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeIn  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _promoCtrl.dispose();
    super.dispose();
  }

  // ── Couleurs ──
  static const _teal    = Color(0xFF00897B);
  static const _tealDk  = Color(0xFF00695C);
  static const _gold    = Color(0xFFFFB300);
  static const _bg      = Color(0xFF0D1F2D);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: const BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.canDismiss) _buildCloseBtn(),
                      const SizedBox(height: 8),
                      _buildHeader(),
                      const SizedBox(height: 28),
                      _buildPriceCard(),
                      const SizedBox(height: 24),
                      _buildFeaturesList(),
                      const SizedBox(height: 28),
                      _buildPromoSection(),
                      const SizedBox(height: 28),
                      _buildCTAButton(),
                      const SizedBox(height: 16),
                      _buildLegalNote(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() => Center(
        child: Container(
          margin: const EdgeInsets.only(top: 12, bottom: 4),
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _buildCloseBtn() => Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.54)),
        ),
      );

  Widget _buildHeader() => Column(
        children: [
          // Icône couronne
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB300), Color(0xFFFFF176)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.4),
                  blurRadius: 20, spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.workspace_premium, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 18),
          Text('SANTEO Connect',
              style: GoogleFonts.montserrat(
                fontSize: 13, color: _teal, fontWeight: FontWeight.w600,
                letterSpacing: 2,
              )),
          const SizedBox(height: 6),
          Text('Passez à\nPremium',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 30, color: Colors.white,
                fontWeight: FontWeight.w800, height: 1.1,
              )),
          const SizedBox(height: 12),
          Text(
            'Votre kiné en poche, disponible 24h/24.\nAccédez à tout le programme de rééducation.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 14, color: Colors.white.withValues(alpha: 0.60), height: 1.5,
            ),
          ),
        ],
      );

  Widget _buildPriceCard() => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_teal, _tealDk],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _teal.withValues(alpha: 0.35),
              blurRadius: 20, offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('19,90',
                    style: GoogleFonts.montserrat(
                      fontSize: 52, color: Colors.white,
                      fontWeight: FontWeight.w800, height: 1,
                    )),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(' €',
                      style: GoogleFonts.montserrat(
                        fontSize: 24, color: Colors.white.withValues(alpha: 0.70),
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            ),
            Text('par mois',
                style: GoogleFonts.montserrat(
                  fontSize: 15, color: Colors.white.withValues(alpha: 0.70),
                  fontWeight: FontWeight.w500,
                )),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, color: Colors.white.withValues(alpha: 0.70), size: 16),
                const SizedBox(width: 6),
                Text('Renouvellement mensuel automatique',
                    style: GoogleFonts.montserrat(
                      fontSize: 12, color: Colors.white.withValues(alpha: 0.70),
                    )),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel_outlined, color: Colors.white.withValues(alpha: 0.70), size: 16),
                const SizedBox(width: 6),
                Text('Annulable à tout moment',
                    style: GoogleFonts.montserrat(
                      fontSize: 12, color: Colors.white.withValues(alpha: 0.70),
                    )),
              ],
            ),
          ],
        ),
      );

  Widget _buildFeaturesList() {
    final features = [
      (Icons.fitness_center_rounded,    'Séances personnalisées',             'Programme adapté à vos douleurs et objectifs'),
      (Icons.people_alt_outlined,        'Accès à nos kinés',                  'Consultations télé avec Axel, Déborah, Maeva, Solenne'),
      (Icons.school_outlined,            'Académie SANI complète',             '6 pathologies + conseils personnalisés par l\'IA'),
      (Icons.psychology_outlined,        'IA Chat santé',                      'Posez vos questions à l\'assistant santé'),
      (Icons.bar_chart_rounded,          'Suivi de progression avancé',        'Graphiques détaillés et analyses hebdomadaires'),
      (Icons.video_library_outlined,     'Vidéos d\'exercices HD',             'Baby Stretch et toute la bibliothèque vidéo'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inclus dans l\'abonnement',
            style: GoogleFonts.montserrat(
              fontSize: 16, color: Colors.white,
              fontWeight: FontWeight.w700,
            )),
        const SizedBox(height: 16),
        ...features.map((f) => _FeatureRow(
              icon: f.$1, title: f.$2, subtitle: f.$3)),
      ],
    );
  }

  Widget _buildPromoSection() => Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _promoSuccess
                ? _teal.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _promoSuccess ? Icons.check_circle : Icons.local_offer_outlined,
                  color: _promoSuccess ? _teal : _gold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _promoSuccess ? 'Prise en charge entreprise activée !' : 'Code entreprise',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: _promoSuccess ? _teal : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (!_promoSuccess) ...[
              const SizedBox(height: 12),
              Text('Votre entreprise prend en charge votre abonnement — entrez votre code',
                  style: GoogleFonts.montserrat(
                    fontSize: 12, color: Colors.white.withValues(alpha: 0.54),
                  )),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.montserrat(
                        color: Colors.white, fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        hintText: 'EX : VVT26',
                        hintStyle: GoogleFonts.montserrat(
                          color: Colors.white.withValues(alpha: 0.30), letterSpacing: 1,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.07),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        errorText: _promoError,
                        errorStyle: GoogleFonts.montserrat(
                          color: Colors.redAccent, fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _promoLoading ? null : _applyPromo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _promoLoading
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black54),
                            )
                          : Text('Valider',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w700, fontSize: 13,
                              )),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: _teal, size: 16),
                    const SizedBox(width: 8),
                    Text('Vos 2 premiers mois sont offerts !',
                        style: GoogleFonts.montserrat(
                          color: _teal, fontSize: 13,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  Widget _buildCTAButton() {
    final sub = context.watch<SubscriptionService>();
    final hasPromo = _promoSuccess;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 58,
          child: ElevatedButton(
            onPressed: _payLoading ? null : _handleSubscribe,
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _payLoading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.workspace_premium, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        hasPromo
                            ? 'Activer — pris en charge par mon entreprise'
                            : 'S\'abonner — 19,90 €/mois',
                        style: GoogleFonts.montserrat(
                          fontSize: 16, fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (hasPromo) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Abonnement pris en charge par votre entreprise',
              style: GoogleFonts.montserrat(
                fontSize: 11, color: Colors.white.withValues(alpha: 0.38),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLegalNote() => Text(
        'En vous abonnant, vous acceptez les conditions générales de vente. '
        'L\'abonnement se renouvelle automatiquement chaque mois. '
        'Annulable à tout moment depuis votre profil.',
        textAlign: TextAlign.center,
        style: GoogleFonts.montserrat(
          fontSize: 10, color: Colors.white.withValues(alpha: 0.24), height: 1.5,
        ),
      );

  // ── Actions ──
  Future<void> _applyPromo() async {
    final code = _promoCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _promoError = 'Entrez votre code promo');
      return;
    }

    setState(() { _promoLoading = true; _promoError = null; });
    await Future.delayed(const Duration(milliseconds: 800)); // Simulation

    final sub = context.read<SubscriptionService>();
    final result = sub.validatePromoCode(code);

    setState(() { _promoLoading = false; });

    switch (result) {
      case PromoResult.valid:
        setState(() { _promoSuccess = true; _promoError = null; });
        break;
      case PromoResult.alreadyUsed:
        setState(() => _promoError = 'Ce code a déjà été utilisé sur cet appareil');
        break;
      case PromoResult.invalid:
        setState(() => _promoError = 'Code invalide. Vérifiez et réessayez.');
        break;
    }
  }

  Future<void> _handleSubscribe() async {
    setState(() => _payLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    final sub = context.read<SubscriptionService>();

    if (_promoSuccess) {
      await sub.activateWithPromo(_promoCtrl.text.trim().toUpperCase());
    } else {
      await sub.activatePaidSubscription();
    }

    setState(() => _payLoading = false);

    if (mounted) {
      Navigator.of(context).pop();
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1F2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFF00897B), shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 20),
            Text('Bienvenue dans\nSANTEO Premium !',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 20, color: Colors.white,
                  fontWeight: FontWeight.w800, height: 1.2,
                )),
            const SizedBox(height: 12),
            Text(
              _promoSuccess
                  ? 'Abonnement activé via votre entreprise.\nProfitez de toutes les fonctionnalités !'
                  : 'Votre abonnement est actif.\nProfitez de toutes les fonctionnalités !',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13, color: Colors.white.withValues(alpha: 0.60), height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Commencer !',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w700, color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget ligne feature ──
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF00897B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF00897B), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.montserrat(
                      fontSize: 13, color: Colors.white,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 11, color: Colors.white.withValues(alpha: 0.45), height: 1.4,
                    )),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF00897B), size: 18),
        ],
      ),
    );
  }
}
