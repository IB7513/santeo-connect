import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';

// ═══════════════════════════════════════════════════
//  ÉCRAN PARLER À UN KINÉ
// ═══════════════════════════════════════════════════
class ParlerKineScreen extends StatefulWidget {
  const ParlerKineScreen({super.key});

  @override
  State<ParlerKineScreen> createState() => _ParlerKineScreenState();
}

class _ParlerKineScreenState extends State<ParlerKineScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final rawKine = provider.userProfile?.prenom ?? provider.userName ?? 'Vous';
            final prenom = rawKine.isNotEmpty ? rawKine[0].toUpperCase() + rawKine.substring(1) : 'Vous';
        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(prenom),
                // Tabs
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicatorColor: AppTheme.primary,
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.montserrat(
                        fontSize: 12, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Nos Kinés'),
                      Tab(text: 'Demande'),
                      Tab(text: 'Messages'),
                    ],
                  ),
                ),
                // Contenu
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _KinesListTab(),
                      _DemandeConsultationTab(provider: provider),
                      _MessagesTab(provider: provider),
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

  Widget _buildHeader(String prenom) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF26C6DA), Color(0xFF0097A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.people_alt_outlined,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parler à un Kiné',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Bonjour $prenom • Nos kinés certifiés vous répondent',
                  style: GoogleFonts.roboto(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF69F0AE),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '3 dispo',
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
    );
  }
}

// ═══════════════════════════════════════════════════
//  ONGLET 1 — LISTE DES KINÉS
// ═══════════════════════════════════════════════════
class _KinesListTab extends StatelessWidget {
  final List<_KineData> _kines = const [
    _KineData(
      nom: 'Axel',
      specialite: 'Kinésithérapeute • Dos, Lombaires, Sport',
      localisation: 'Nouméa, Nouvelle-Calédonie',
      disponible: true,
      experience: '8 ans',
      avatarColor: Color(0xFF26A69A),
      langues: ['Français'],
      tarif: '4 000 XPF / consultation',
      note: 4.8,
    ),
    _KineData(
      nom: 'Déborah',
      specialite: 'Rééducation post-op, Cervicalgie, Arthrose',
      localisation: 'Papeete, Polynésie française',
      disponible: true,
      experience: '12 ans',
      avatarColor: Color(0xFFEC407A),
      langues: ['Français', 'Tahitien'],
      tarif: '3 500 XPF / consultation',
      note: 4.9,
    ),
    _KineData(
      nom: 'Maeva',
      specialite: 'Bien-être, Sciatique, Tendinite',
      localisation: 'Bora Bora, Polynésie française',
      disponible: false,
      experience: '6 ans',
      avatarColor: Color(0xFF7E57C2),
      langues: ['Français', 'Anglais', 'Tahitien'],
      tarif: '3 200 XPF / consultation',
      note: 4.7,
    ),
    _KineData(
      nom: 'Solenne',
      specialite: 'Hernie discale, Rééducation respiratoire',
      localisation: 'Koné, Nouvelle-Calédonie',
      disponible: true,
      experience: '+20 ans',
      avatarColor: Color(0xFF42A5F5),
      langues: ['Français', 'Kanak'],
      tarif: '3 800 XPF / consultation',
      note: 5.0,
    ),
  ];

  const _KinesListTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _kines.length,
      itemBuilder: (ctx, i) => _KineCard(
        kine: _kines[i],
        onContact: () => _contactKine(ctx, _kines[i]),
      ),
    );
  }

  void _contactKine(BuildContext context, _KineData kine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _KineProfileSheet(kine: kine),
    );
  }
}

class _KineCard extends StatelessWidget {
  final _KineData kine;
  final VoidCallback onContact;

  const _KineCard({required this.kine, required this.onContact});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar style Apple — cercle coloré + initiale
                _KineAvatar(kine: kine),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              kine.nom,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          // Badge disponibilité
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: kine.disponible
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: kine.disponible
                                        ? AppTheme.success
                                        : AppTheme.warning,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  kine.disponible
                                      ? 'Disponible'
                                      : 'Occupé',
                                  style: GoogleFonts.roboto(
                                    fontSize: 10,
                                    color: kine.disponible
                                        ? AppTheme.success
                                        : AppTheme.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        kine.specialite,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 12, color: AppTheme.textLight),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              kine.localisation,
                              style: GoogleFonts.roboto(
                                  fontSize: 11,
                                  color: AppTheme.textLight),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoChip(Icons.star, '${kine.note}',
                    const Color(0xFFFFC107)),
                const SizedBox(width: 8),
                _infoChip(Icons.work_outline,
                    kine.experience, AppTheme.primary),
                const SizedBox(width: 8),
                _infoChip(Icons.translate,
                    kine.langues.first, const Color(0xFF7E57C2)),
                const Spacer(),
                ElevatedButton(
                  onPressed: onContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kine.disponible
                        ? AppTheme.primary
                        : Colors.grey[300],
                    foregroundColor:
                        kine.disponible ? Colors.white : Colors.grey[600],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text(
                    kine.disponible ? 'Contacter' : 'Voir profil',
                    style: GoogleFonts.roboto(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  PROFIL KINÉ — BOTTOM SHEET
// ═══════════════════════════════════════════════════
class _KineProfileSheet extends StatelessWidget {
  final _KineData kine;
  const _KineProfileSheet({required this.kine});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          controller: scroll,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barre
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Avatar + nom
                Row(
                  children: [
                    _KineAvatarLarge(kine: kine),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kine.nom,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            kine.specialite,
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              ...List.generate(5, (i) => Icon(
                                    i < kine.note.floor()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: const Color(0xFFFFC107),
                                    size: 14,
                                  )),
                              const SizedBox(width: 5),
                              Text('${kine.note}',
                                  style: GoogleFonts.roboto(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Infos
                _sectionTitle('Informations'),
                _infoRow(Icons.location_on, 'Localisation', kine.localisation),
                _infoRow(Icons.work_outline, 'Expérience', kine.experience),
                _infoRow(
                    Icons.attach_money, 'Tarif', kine.tarif),
                _infoRow(Icons.translate, 'Langues', kine.langues.join(', ')),
                const SizedBox(height: 16),
                _sectionTitle('Disponibilité'),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kine.disponible
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        kine.disponible
                            ? Icons.check_circle
                            : Icons.watch_later,
                        color: kine.disponible
                            ? AppTheme.success
                            : AppTheme.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        kine.disponible
                            ? 'Disponible dès aujourd\'hui pour une séance kiné'
                            : 'Prochain créneau disponible dans 2-3 jours',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: kine.disponible
                              ? AppTheme.success
                              : AppTheme.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Boutons d'action
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.video_call),
                    label: const Text('Réserver une séance kiné'),
                    onPressed: kine.disponible
                        ? () {
                            Navigator.pop(context);
                            _showReservationDialog(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.message_outlined),
                    label: const Text('Envoyer un message'),
                    onPressed: () {
                      Navigator.pop(context);
                      _showMessageDialog(context, kine.nom);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppTheme.primary),
            const SizedBox(width: 10),
            Text(
              '$label : ',
              style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.roboto(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      );

  void _showReservationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Réservation confirmée ✅',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
        content: Text(
          'Votre demande de séance avec ${kine.nom} a été envoyée.\n\nVous recevrez une confirmation sous 24h.',
          style: GoogleFonts.roboto(height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(BuildContext context, String kineName) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Message à $kineName',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700, fontSize: 15)),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Décrivez votre problème, vos douleurs...',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Message envoyé à $kineName ✅'),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  ONGLET 2 — DEMANDE DE CONSULTATION
// ═══════════════════════════════════════════════════
class _DemandeConsultationTab extends StatefulWidget {
  final AppProvider provider;
  const _DemandeConsultationTab({required this.provider});

  @override
  State<_DemandeConsultationTab> createState() =>
      _DemandeConsultationTabState();
}

class _DemandeConsultationTabState extends State<_DemandeConsultationTab> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  String _typeConsult = 'video';
  String _urgence = 'normale';
  String _zoneDouleureuse = 'Dos / Lombaires';
  bool _submitted = false;

  final List<String> _zones = [
    'Dos / Lombaires',
    'Cervicales / Cou',
    'Épaules',
    'Genoux',
    'Hanches',
    'Cheville / Pied',
    'Autre',
  ];

  @override
  void dispose() {
    _descCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _buildSuccessView();

    final profile = widget.provider.userProfile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppTheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Un kiné certifié répondra sous 24h. Vos données sont protégées et confidentielles.',
                      style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: AppTheme.primaryDark,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nom affiché (pré-rempli depuis profil)
            if (profile != null) ...[
              _sectionTitle('Vos informations'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: AppTheme.primary, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      '${profile.prenom.isNotEmpty ? profile.prenom[0].toUpperCase() + profile.prenom.substring(1) : profile.prenom} • ${profile.age} ans • ${profile.localisation}',
                      style: GoogleFonts.roboto(
                          fontSize: 13, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Type de consultation
            _sectionTitle('Type de consultation'),
            Row(
              children: [
                _typeBtn('video', Icons.video_call, 'Vidéo'),
                const SizedBox(width: 10),
                _typeBtn('message', Icons.message, 'Message'),
                const SizedBox(width: 10),
                _typeBtn('phone', Icons.phone, 'Téléphone'),
              ],
            ),
            const SizedBox(height: 16),

            // Zone douloureuse
            _sectionTitle('Zone douloureuse principale'),
            DropdownButtonFormField<String>(
              value: _zoneDouleureuse,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              items: _zones
                  .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                  .toList(),
              onChanged: (v) => setState(() => _zoneDouleureuse = v!),
            ),
            const SizedBox(height: 16),

            // Urgence
            _sectionTitle('Niveau d\'urgence'),
            Row(
              children: [
                _urgenceBtn('normale', '🟢', 'Normale'),
                const SizedBox(width: 10),
                _urgenceBtn('modere', '🟡', 'Modéré'),
                const SizedBox(width: 10),
                _urgenceBtn('urgent', '🔴', 'Urgent'),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            _sectionTitle('Décrivez votre problème'),
            TextFormField(
              controller: _descCtrl,
              maxLines: 5,
              validator: (v) =>
                  v == null || v.trim().length < 20
                      ? 'Minimum 20 caractères requis'
                      : null,
              decoration: InputDecoration(
                hintText:
                    'Décrivez vos douleurs, depuis quand, intensité, ce qui aggrave ou soulage...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),

            // Téléphone (optionnel)
            _sectionTitle('Téléphone (optionnel)'),
            TextFormField(
              controller: _telCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '+687 ou +689 ...',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton envoi
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Envoyer ma demande'),
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  textStyle: GoogleFonts.montserrat(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          t,
          style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary),
        ),
      );

  Widget _typeBtn(String val, IconData icon, String label) => Expanded(
        child: InkWell(
          onTap: () => setState(() => _typeConsult = val),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _typeConsult == val
                  ? AppTheme.primary
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _typeConsult == val
                    ? AppTheme.primary
                    : AppTheme.divider,
              ),
            ),
            child: Column(
              children: [
                Icon(icon,
                    color: _typeConsult == val
                        ? Colors.white
                        : AppTheme.textSecondary,
                    size: 22),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _typeConsult == val
                        ? Colors.white
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _urgenceBtn(String val, String emoji, String label) => Expanded(
        child: InkWell(
          onTap: () => setState(() => _urgence = val),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _urgence == val
                  ? AppTheme.primary.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _urgence == val ? AppTheme.primary : AppTheme.divider,
                width: _urgence == val ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    color: _urgence == val
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                    fontWeight: _urgence == val
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _submitted = true);
    }
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: AppTheme.success, size: 50),
            ),
            const SizedBox(height: 24),
            Text(
              'Demande envoyée ! ✅',
              style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              'Un kiné de notre réseau vous répondra dans les 24 heures.\n\nVous recevrez une notification dès qu\'il est disponible.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.6),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => setState(() => _submitted = false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Nouvelle demande'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  ONGLET 3 — MESSAGES
// ═══════════════════════════════════════════════════
class _MessagesTab extends StatelessWidget {
  final AppProvider provider;
  const _MessagesTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_outlined,
                  color: AppTheme.primary, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun message',
              style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos échanges avec les kinés apparaîtront ici.\nEnvoyez votre première demande dans l\'onglet "Demande".',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  AVATAR KINÉ — Style Apple (cercle coloré + initiale)
// ═══════════════════════════════════════════════════
class _KineAvatar extends StatelessWidget {
  final _KineData kine;
  const _KineAvatar({required this.kine});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: kine.avatarColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: kine.avatarColor.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          kine.nom[0].toUpperCase(),
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _KineAvatarLarge extends StatelessWidget {
  final _KineData kine;
  const _KineAvatarLarge({required this.kine});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: kine.avatarColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: kine.avatarColor.withValues(alpha: 0.40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          kine.nom[0].toUpperCase(),
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  DATA MODEL KINÉ
// ═══════════════════════════════════════════════════
class _KineData {
  final String nom;
  final String specialite;
  final String localisation;
  final bool disponible;
  final String experience;
  final Color avatarColor;
  final List<String> langues;
  final String tarif;
  final double note;

  const _KineData({
    required this.nom,
    required this.specialite,
    required this.localisation,
    required this.disponible,
    required this.experience,
    required this.avatarColor,
    required this.langues,
    required this.tarif,
    required this.note,
  });
}
