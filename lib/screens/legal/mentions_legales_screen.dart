// ═══════════════════════════════════════════════════════════════════════════
//  SANTEO Connect — Mentions Légales
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class MentionsLegalesScreen extends StatelessWidget {
  const MentionsLegalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mentions légales',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          // ── En-tête ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.08),
                  AppTheme.primary.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.balance_outlined,
                      color: AppTheme.primary, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  'SANTEO Connect',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mentions légales & informations éditeur',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Éditeur ─────────────────────────────────────────────────────
          _Section(
            icon: Icons.apartment_outlined,
            title: 'Éditeur de l\'application',
            children: const [
              _Row(label: 'Application', value: 'SANTEO Connect'),
              _Row(label: 'Activité', value: 'Application de bien-être et de prévention'),
              _Row(label: 'Territoires', value: 'France métropolitaine, DOM-TOM,\nNouvelle-Calédonie, Polynésie française,\nWallis-et-Futuna'),
              _Row(label: 'Contact', value: 'contact@santeo-connect.com'),
            ],
          ),

          // ── Hébergement ─────────────────────────────────────────────────
          _Section(
            icon: Icons.cloud_outlined,
            title: 'Hébergement',
            children: const [
              _Row(label: 'Prestataire', value: 'Google LLC\nFirebase / Google Cloud Platform'),
              _Row(label: 'Adresse', value: '1600 Amphitheatre Parkway\nMountain View, CA 94043, USA'),
              _Row(label: 'Données UE', value: 'Serveurs hébergés en Union Européenne\nConformes RGPD — Art. 46'),
            ],
          ),

          // ── Propriété intellectuelle ─────────────────────────────────────
          _Section(
            icon: Icons.copyright_outlined,
            title: 'Propriété intellectuelle',
            children: const [
              _TextBlock(
                'L\'intégralité du contenu de SANTEO Connect — incluant sans limitation : '
                'le concept, la conception graphique, le logo, les textes, les programmes '
                'd\'exercices, les contenus audio et vidéo, les algorithmes d\'intelligence '
                'artificielle, le code source et l\'architecture applicative — est protégée '
                'par le droit d\'auteur.\n\n'
                'Toute reproduction, représentation, modification, publication, adaptation '
                'ou exploitation de tout ou partie de ces éléments, sans autorisation écrite '
                'préalable, est interdite et constitue une contrefaçon sanctionnée par les '
                'articles L.335-2 et suivants du Code de la Propriété Intellectuelle.',
              ),
            ],
          ),

          // ── Données personnelles ─────────────────────────────────────────
          _Section(
            icon: Icons.shield_outlined,
            title: 'Données personnelles & RGPD',
            children: const [
              _Row(label: 'Responsable', value: 'SANTEO Connect'),
              _Row(label: 'Contact', value: 'contact@santeo-connect.com'),
              _TextBlock(
                'Conformément au Règlement Général sur la Protection des Données '
                '(RGPD — Règlement UE 2016/679) et à la loi Informatique et Libertés, '
                'vous disposez d\'un droit d\'accès, de rectification, d\'effacement, '
                'de portabilité et d\'opposition concernant vos données personnelles.\n\n'
                'Pour exercer ces droits :\n'
                '• Profil → Exporter / Supprimer mes données\n'
                '• Ou par email : contact@santeo-connect.com\n\n'
                'En cas de réclamation, vous pouvez saisir la CNIL : www.cnil.fr',
              ),
            ],
          ),

          // ── Avertissement médical ────────────────────────────────────────
          _Section(
            icon: Icons.medical_services_outlined,
            title: 'Avertissement médical',
            children: const [
              _TextBlock(
                '⚠️ SANTEO Connect est une application de bien-être et de prévention. '
                'Elle ne constitue en aucun cas un acte médical et ne remplace pas '
                'l\'avis d\'un professionnel de santé qualifié.\n\n'
                'En cas de douleur persistante, de pathologie diagnostiquée ou de '
                'doute sur votre état de santé, consultez un médecin ou un '
                'kinésithérapeute avant toute utilisation.',
              ),
            ],
          ),

          // ── Droit applicable ─────────────────────────────────────────────
          _Section(
            icon: Icons.gavel_outlined,
            title: 'Droit applicable & juridiction',
            children: const [
              _TextBlock(
                'Les présentes mentions légales sont soumises au droit français.\n\n'
                'En cas de litige, et à défaut de résolution amiable, les tribunaux '
                'français seront seuls compétents.',
              ),
            ],
          ),

          // ── Contact ──────────────────────────────────────────────────────
          _Section(
            icon: Icons.mail_outline,
            title: 'Contact',
            children: const [
              _Row(label: 'Email', value: 'contact@santeo-connect.com'),
            ],
          ),

          // ── Pied de page ─────────────────────────────────────────────────
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: AppTheme.textPrimary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'SANTEO Connect — Dernière mise à jour : Juin 2026',
              style: GoogleFonts.roboto(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets internes ──────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[100]),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final String text;
  const _TextBlock(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.roboto(
        fontSize: 12,
        color: AppTheme.textPrimary,
        height: 1.65,
      ),
    );
  }
}
