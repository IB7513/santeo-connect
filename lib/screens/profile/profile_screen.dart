import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/assets/logo_data.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/common_widgets.dart';
import '../landing/landing_screen.dart';
import '../../core/services/storage_service.dart';
import '../legal/rgpd_consent_screen.dart';
import '../dashboard/company_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final profile = provider.userProfile;
        final rawPrenom = profile?.prenom ?? provider.userName ?? 'Utilisateur';
        final prenom = rawPrenom.isNotEmpty
            ? rawPrenom[0].toUpperCase() + rawPrenom.substring(1)
            : 'Utilisateur';
        final email = provider.userEmail ?? '';

        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Header ──────────────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    child: Row(
                      children: [
                        Image.memory(
                          SanteoLogoData.bytes,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Mon Profil',
                          style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),

                  // ── Avatar & Nom ────────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              prenom.isNotEmpty
                                  ? prenom[0].toUpperCase()
                                  : 'U',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 32,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          prenom,
                          style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary),
                        ),
                        if (email.isNotEmpty)
                          Text(email,
                              style: GoogleFonts.roboto(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary)),
                        if (profile?.localisation != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on,
                                  color: AppTheme.primary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                profile!.localisation,
                                style: GoogleFonts.roboto(
                                    fontSize: 13,
                                    color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        // Badge IA locale
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppTheme.success
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.offline_bolt,
                                  color: AppTheme.success, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'IA Embarquée · Offline · Gratuit',
                                style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: AppTheme.success,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),


                  // ── Infos de santé ──────────────────────────────
                  if (profile != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SanteoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Informations de santé',
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppTheme.textPrimary)),
                            const SizedBox(height: 12),
                            const Divider(),
                            _ProfileInfoRow(
                                icon: Icons.flag_outlined,
                                label: 'Objectif',
                                value: profile.objectifSante),
                            _ProfileInfoRow(
                                icon: Icons.cake_outlined,
                                label: 'Âge',
                                value: profile.age),
                            _ProfileInfoRow(
                                icon: Icons.wc,
                                label: 'Genre',
                                value: profile.genre),
                            _ProfileInfoRow(
                                icon: Icons.directions_run,
                                label: 'Activité',
                                value: profile.niveauActivite.isNotEmpty
                                    ? profile.niveauActivite
                                        .split('(')
                                        .first
                                        .trim()
                                    : 'Non renseigné'),
                            _ProfileInfoRow(
                                icon: Icons.timer_outlined,
                                label: 'Séances',
                                value:
                                    '${profile.dureeSeance} · ${profile.frequenceSemaine}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Comment fonctionne l'IA ─────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SanteoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.psychology,
                                    color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Comment fonctionne l\'IA ?',
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppTheme.textPrimary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _AiFeatureRow(
                            icon: Icons.offline_bolt,
                            color: AppTheme.success,
                            title: '100% local sur votre appareil',
                            subtitle:
                                'Aucune donnée envoyée sur internet. Votre santé reste privée.',
                          ),
                          _AiFeatureRow(
                            icon: Icons.free_breakfast,
                            color: AppTheme.primary,
                            title: 'Entièrement gratuit',
                            subtitle:
                                'Pas d\'abonnement, pas de clé API, pas de frais cachés.',
                          ),
                          _AiFeatureRow(
                            icon: Icons.location_on,
                            color: AppTheme.secondary,
                            title: 'Adapté au Pacifique',
                            subtitle:
                                'Recommandations selon votre territoire, le climat tropical et vos contraintes locales.',
                          ),
                          _AiFeatureRow(
                            icon: Icons.person,
                            color: const Color(0xFF7E57C2),
                            title: 'Personnalisé pour vous',
                            subtitle:
                                'Chaque bilan est unique, basé sur vos réponses d\'onboarding.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Actions RGPD & Paramètres ───────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SanteoCard(
                      child: Column(
                        children: [
                          _ActionItem(
                            icon: Icons.business_center_outlined,
                            label: 'Dashboard Entreprise',
                            color: AppTheme.primaryDark,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CompanyDashboardScreen(),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          _ActionItem(
                            icon: Icons.edit_outlined,
                            label: 'Modifier mon prénom',
                            onTap: () => _editName(context, provider),
                          ),
                          const Divider(height: 1),
                          _ActionItem(
                            icon: Icons.refresh,
                            label: 'Refaire mon évaluation',
                            color: AppTheme.primary,
                            onTap: () {
                              Navigator.pushNamed(context, '/onboarding');
                            },
                          ),
                          const Divider(height: 1),
                          _ActionItem(
                            icon: Icons.download_outlined,
                            label: 'Exporter mes données (RGPD)',
                            onTap: () => _exportData(context),
                          ),
                          const Divider(height: 1),
                          _ActionItem(
                            icon: Icons.privacy_tip_outlined,
                            label: 'Politique de confidentialité',
                            onTap: () => _showLegalDoc(context, 'privacy'),
                          ),
                          const Divider(height: 1),
                          _ActionItem(
                            icon: Icons.gavel_outlined,
                            label: 'Conditions générales d\'utilisation',
                            onTap: () => _showLegalDoc(context, 'cgu'),
                          ),
                          const Divider(height: 1),
                          _ActionItem(
                            icon: Icons.tune_outlined,
                            label: 'Gérer mes consentements',
                            color: AppTheme.primary,
                            onTap: () => _showConsentSettings(context),
                          ),
                          const Divider(height: 1),
                          _ActionItem(
                            icon: Icons.delete_forever_outlined,
                            label: 'Supprimer mon compte (RGPD)',
                            color: AppTheme.error,
                            onTap: () =>
                                _confirmDeleteAccount(context, provider),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Déconnexion ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout, color: AppTheme.error),
                      label: Text(
                        'Se déconnecter',
                        style: GoogleFonts.roboto(
                            color: AppTheme.error,
                            fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppTheme.error.withValues(alpha: 0.5)),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () async {
                        await provider.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LandingScreen()),
                            (r) => false,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'SANTEO Connect v1.0.0 · IA Embarquée',
                    style: GoogleFonts.roboto(
                        fontSize: 11, color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Dialogues ─────────────────────────────────────────────

  void _editName(BuildContext context, AppProvider provider) {
    final ctrl =
        TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Modifier le prénom',
            style:
                GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          decoration:
              const InputDecoration(labelText: 'Prénom'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await provider.updateUserName(ctrl.text.trim());
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Export RGPD',
            style:
                GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
        content: Text(
          'Vos données sont stockées uniquement sur votre appareil.\n\nElles comprennent : votre profil santé, l\'historique de vos séances et votre programme personnalisé.\n\nDans une future version, un export PDF sera disponible directement.',
          style: GoogleFonts.roboto(fontSize: 14, height: 1.5),
        ),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
        ],
      ),
    );
  }

  void _showLegalDoc(BuildContext context, String type) {
    final isPrivacy = type == 'privacy';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scroll) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Poignée
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isPrivacy
                            ? Icons.privacy_tip_outlined
                            : Icons.gavel_outlined,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isPrivacy
                            ? 'Politique de confidentialité'
                            : 'Conditions Générales d\'Utilisation',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  child: Text(
                    isPrivacy
                        ? PrivacyPolicyContent.text
                        : CguContent.text,
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      height: 1.65,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConsentSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConsentSettingsSheet(),
    );
  }

  void _confirmDeleteAccount(
      BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Supprimer le compte',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                color: AppTheme.error)),
        content: Text(
          'Cette action est irréversible. Toutes vos données (profil, séances, bilans) seront définitivement supprimées de cet appareil.',
          style: GoogleFonts.roboto(fontSize: 14),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error),
            onPressed: () async {
              await StorageService.clearAllData();
              await provider.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LandingScreen()),
                  (r) => false,
                );
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// ── Widgets helpers ──────────────────────────────────────────

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textLight, size: 18),
          const SizedBox(width: 10),
          Text('$label :',
              style: GoogleFonts.roboto(
                  fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Non renseigné',
              style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiFeatureRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _AiFeatureRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                color: color ?? AppTheme.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: color ?? AppTheme.textPrimary)),
            ),
            Icon(Icons.chevron_right,
                color: AppTheme.textLight, size: 18),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  FEUILLE GESTION CONSENTEMENTS (accessible depuis profil)
// ═══════════════════════════════════════════════════
class _ConsentSettingsSheet extends StatefulWidget {
  @override
  State<_ConsentSettingsSheet> createState() => _ConsentSettingsSheetState();
}

class _ConsentSettingsSheetState extends State<_ConsentSettingsSheet> {
  bool _analytics = false;
  bool _personalization = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentConsents();
  }

  Future<void> _loadCurrentConsents() async {
    final prefs = await RgpdConsentScreen.getPrefs();
    if (mounted) {
      setState(() {
        _analytics = prefs['analytics'] as bool;
        _personalization = prefs['personalization'] as bool;
        _loading = false;
      });
    }
  }

  Future<void> _saveAndClose() async {
    await RgpdConsentScreen.saveConsent(
      analytics: _analytics,
      personalization: _personalization,
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Préférences de confidentialité mises à jour',
            style: GoogleFonts.roboto(fontSize: 13),
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Poignée
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Titre
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune_outlined,
                        color: AppTheme.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gérer mes consentements',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Contenu
            if (_loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  controller: scroll,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info obligatoire
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline,
                                color: AppTheme.primary, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Le traitement fonctionnel est obligatoire pour utiliser SANTEO Connect.',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: AppTheme.primaryDark,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Consentement fonctionnel (verrouillé ON)
                      _buildConsentRow(
                        icon: Icons.lock_outline,
                        iconColor: AppTheme.primary,
                        title: 'Fonctionnement de l\'app',
                        subtitle: 'Profil bien-être, programme, séances.',
                        badge: 'Obligatoire',
                        badgeColor: AppTheme.primary,
                        value: true,
                        onChanged: null, // verrouillé
                      ),
                      const SizedBox(height: 12),

                      // Personnalisation
                      _buildConsentRow(
                        icon: Icons.person_outline,
                        iconColor: const Color(0xFF7E57C2),
                        title: 'Personnalisation avancée',
                        subtitle:
                            'Adapter les exercices à votre profil et progrès.',
                        badge: 'Recommandé',
                        badgeColor: const Color(0xFF7E57C2),
                        value: _personalization,
                        onChanged: (v) =>
                            setState(() => _personalization = v),
                      ),
                      const SizedBox(height: 12),

                      // Analytics
                      _buildConsentRow(
                        icon: Icons.bar_chart_outlined,
                        iconColor: const Color(0xFF42A5F5),
                        title: 'Amélioration du service',
                        subtitle:
                            'Données anonymisées. Aucune donnée personnelle.',
                        badge: 'Optionnel',
                        badgeColor: const Color(0xFF42A5F5),
                        value: _analytics,
                        onChanged: (v) => setState(() => _analytics = v),
                      ),

                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveAndClose,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Enregistrer mes préférences',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? iconColor.withValues(alpha: 0.35) : const Color(0xFFE0E0E0),
          width: value ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: GoogleFonts.roboto(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            subtitle,
            style: GoogleFonts.roboto(
              fontSize: 11,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: iconColor,
      ),
    );
  }
}
