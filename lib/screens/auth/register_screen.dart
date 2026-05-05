import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/common_widgets.dart';
import '../onboarding/onboarding_screen.dart';
import '../legal/rgpd_consent_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prenomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _rgpdConsent = false;

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Ouvre l'écran RGPD complet — le consentement est enregistré là-bas
  Future<void> _openRgpdScreen() async {
    final accepted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RgpdConsentScreen(
          onAccepted: () => Navigator.pop(context, true),
          onRefused: () => Navigator.pop(context, false),
        ),
      ),
    );
    if (accepted == true && mounted) {
      setState(() => _rgpdConsent = true);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_rgpdConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez accepter la politique de confidentialité'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Voir',
            textColor: Colors.white,
            onPressed: _openRgpdScreen,
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    // Identifiant unique basé sur le prénom + timestamp
    final prenom = _prenomCtrl.text.trim();
    final uid = 'user_${prenom.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}';
    final email = _emailCtrl.text.trim();

    if (mounted) {
      await context.read<AppProvider>().login(uid, prenom, email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.celebration, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '🎉 Bienvenue $prenom ! Votre compte est créé. Complétez votre profil pour commencer !',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF26C6DA),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (r) => false,
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Center(child: SanteoLogo(size: 72)),
                const SizedBox(height: 24),
                Text('Créer un compte',
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 6),
                Text(
                  'Rejoignez SANTEO Connect et commencez votre parcours santé.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),

                // ── Prénom ────────────────────────────────────────
                TextFormField(
                  controller: _prenomCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    hintText: 'Ex : Marie, Jean…',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Prénom requis';
                    if (v.trim().length < 2) return 'Au moins 2 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── Email ─────────────────────────────────────────
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Adresse e-mail',
                    hintText: 'vous@exemple.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email requis';
                    if (!v.contains('@') || !v.contains('.')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── Mot de passe ──────────────────────────────────
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    helperText: 'Minimum 8 caractères',
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePass ? Icons.visibility_off : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Mot de passe requis';
                    if (v.length < 8) return 'Minimum 8 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Bloc RGPD — ouverture écran complet ──────────
                GestureDetector(
                  onTap: _openRgpdScreen,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _rgpdConsent
                          ? const Color(0xFFE0F7FA)
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _rgpdConsent
                            ? AppTheme.primary
                            : AppTheme.divider,
                        width: _rgpdConsent ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _rgpdConsent
                              ? const Icon(Icons.check_circle,
                                  key: ValueKey('checked'),
                                  color: AppTheme.primary,
                                  size: 26)
                              : const Icon(Icons.shield_outlined,
                                  key: ValueKey('unchecked'),
                                  color: AppTheme.textSecondary,
                                  size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _rgpdConsent
                                    ? 'Politique de confidentialité acceptée ✓'
                                    : 'Politique de confidentialité (RGPD)',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _rgpdConsent
                                      ? AppTheme.primaryDark
                                      : AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _rgpdConsent
                                    ? 'Appuyez pour modifier vos préférences'
                                    : 'Appuyez pour lire et accepter vos droits RGPD',
                                style: GoogleFonts.roboto(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: _rgpdConsent
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                PrimaryButton(
                  label: 'Créer mon compte',
                  isLoading: _isLoading,
                  onPressed: _register,
                  icon: Icons.person_add,
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Déjà un compte ? ',
                        style: GoogleFonts.roboto(
                            color: AppTheme.textSecondary, fontSize: 14)),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('Se connecter'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
