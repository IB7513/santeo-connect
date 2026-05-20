// ═══════════════════════════════════════════════════════════════════════════
//  KinePlanningScreen — Interface kiné pour gérer ses créneaux
//  Accès : onglet "Mon Planning" dans la section Kinés
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/rdv_service.dart';
import '../../core/theme/app_theme.dart';

// ─── Données des kinés (source unique — email inclus) ──────────────────────

class KineInfo {
  final String id;       // slug identifiant
  final String nom;
  final String email;
  final Color avatarColor;

  const KineInfo({
    required this.id,
    required this.nom,
    required this.email,
    required this.avatarColor,
  });
}

const List<KineInfo> kineInfoList = [
  KineInfo(
    id: 'axel',
    nom: 'Axel',
    email: 'axel@santeoconnect.com',   // ← remplacer par l'email réel
    avatarColor: Color(0xFF26A69A),
  ),
  KineInfo(
    id: 'deborah',
    nom: 'Déborah',
    email: 'deborah@santeoconnect.com', // ← remplacer par l'email réel
    avatarColor: Color(0xFFEC407A),
  ),
  KineInfo(
    id: 'maeva',
    nom: 'Maeva',
    email: 'maeva@santeoconnect.com',   // ← remplacer par l'email réel
    avatarColor: Color(0xFF7E57C2),
  ),
  KineInfo(
    id: 'solenne',
    nom: 'Solenne',
    email: 'solenne@santeoconnect.com', // ← remplacer par l'email réel
    avatarColor: Color(0xFF42A5F5),
  ),
];

// ─── Écran principal ───────────────────────────────────────────────────────

class KinePlanningScreen extends StatefulWidget {
  /// kineId : si null → vue admin (tous les kinés)
  /// si renseigné → vue kiné (seulement ses créneaux)
  final String? kineId;
  final bool isAdmin;

  const KinePlanningScreen({
    super.key,
    this.kineId,
    this.isAdmin = false,
  });

  @override
  State<KinePlanningScreen> createState() => _KinePlanningScreenState();
}

class _KinePlanningScreenState extends State<KinePlanningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _rdv = RdvService();

  late KineInfo _currentKine;
  String _activeKineIdFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Si vue kiné → on prend le premier kiné correspondant
    if (widget.kineId != null) {
      _currentKine = kineInfoList.firstWhere(
        (k) => k.id == widget.kineId,
        orElse: () => kineInfoList.first,
      );
    } else {
      _currentKine = kineInfoList.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            // Onglets Créneaux / Réservations
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.primary,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.montserrat(
                    fontSize: 13, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(icon: Icon(Icons.calendar_month, size: 18), text: 'Créneaux'),
                  Tab(icon: Icon(Icons.list_alt, size: 18), text: 'Réservations'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _SlotsTab(
                    rdv: _rdv,
                    kineId: widget.isAdmin ? _activeKineIdFilter : _currentKine.id,
                    kineName: _currentKine.nom,
                    isAdmin: widget.isAdmin,
                    allKines: kineInfoList,
                    onKineFilterChanged: (id) =>
                        setState(() => _activeKineIdFilter = id),
                  ),
                  _BookingsTab(
                    rdv: _rdv,
                    kineId: widget.isAdmin ? _activeKineIdFilter : _currentKine.id,
                    isAdmin: widget.isAdmin,
                    allKines: kineInfoList,
                    onKineFilterChanged: (id) =>
                        setState(() => _activeKineIdFilter = id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bouton + ajouter créneau (kiné uniquement)
      floatingActionButton: !widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddSlotSheet(context),
              backgroundColor: AppTheme.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Ajouter créneau',
                style: GoogleFonts.montserrat(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader() {
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isAdmin ? '🏥 Plannings SANTEO' : '📅 Mon Planning',
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.isAdmin
                      ? 'Vue équipe — tous les kinés'
                      : _currentKine.nom,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Sélecteur kiné (vue admin)
          if (widget.isAdmin)
            _buildKineSelector(),
        ],
      ),
    );
  }

  Widget _buildKineSelector() {
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem(
        value: 'all',
        child: Text('Tous', style: GoogleFonts.roboto(fontSize: 13, color: Colors.white)),
      ),
      ...kineInfoList.map((k) => DropdownMenuItem(
            value: k.id,
            child: Text(k.nom,
                style: GoogleFonts.roboto(fontSize: 13, color: Colors.white)),
          )),
    ];
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _activeKineIdFilter,
        dropdownColor: const Color(0xFF0097A7),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        items: items,
        onChanged: (v) => setState(() => _activeKineIdFilter = v ?? 'all'),
      ),
    );
  }

  // ── Dialog ajout créneau ───────────────────────────────────────────────

  void _showAddSlotSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSlotSheet(
        kineId: _currentKine.id,
        kineName: _currentKine.nom,
        rdv: _rdv,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  Onglet Créneaux
// ═══════════════════════════════════════════════════

class _SlotsTab extends StatelessWidget {
  final RdvService rdv;
  final String kineId;
  final String kineName;
  final bool isAdmin;
  final List<KineInfo> allKines;
  final ValueChanged<String> onKineFilterChanged;

  const _SlotsTab({
    required this.rdv,
    required this.kineId,
    required this.kineName,
    required this.isAdmin,
    required this.allKines,
    required this.onKineFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final stream = (isAdmin && kineId == 'all')
        ? rdv.allSlotsStream()
        : rdv.slotsStream(kineId);

    return StreamBuilder<List<KineSlot>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final slots = snap.data ?? [];
        final future = slots.where((s) => !s.reserve).toList();
        final reserved = slots.where((s) => s.reserve).toList();
        final past = slots
            .where((s) => s.date.isBefore(DateTime.now()))
            .toList();

        if (slots.isEmpty) {
          return _buildEmpty(context, isAdmin);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (future.isNotEmpty) ...[
              _groupTitle('Disponibles (${future.length})'),
              ...future.map((s) => _SlotTile(
                    slot: s,
                    rdv: rdv,
                    isAdmin: isAdmin,
                    showKineName: isAdmin,
                  )),
            ],
            if (reserved.isNotEmpty) ...[
              _groupTitle('Réservés (${reserved.length})'),
              ...reserved.map((s) => _SlotTile(
                    slot: s,
                    rdv: rdv,
                    isAdmin: isAdmin,
                    showKineName: isAdmin,
                  )),
            ],
            if (past.isNotEmpty) ...[
              _groupTitle('Passés (${past.length})', muted: true),
              ...past.map((s) => _SlotTile(
                    slot: s,
                    rdv: rdv,
                    isAdmin: isAdmin,
                    showKineName: isAdmin,
                    muted: true,
                  )),
            ],
          ],
        );
      },
    );
  }

  Widget _groupTitle(String t, {bool muted = false}) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
        child: Text(
          t,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: muted ? AppTheme.textSecondary : AppTheme.textPrimary,
          ),
        ),
      );

  Widget _buildEmpty(BuildContext context, bool isAdmin) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 56, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              isAdmin ? 'Aucun créneau pour l\'instant' : 'Aucun créneau',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAdmin
                  ? 'Les kinés n\'ont pas encore ajouté de créneaux.'
                  : 'Appuyez sur + pour ajouter vos premières disponibilités.',
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
//  Tuile d'un créneau
// ═══════════════════════════════════════════════════

class _SlotTile extends StatelessWidget {
  final KineSlot slot;
  final RdvService rdv;
  final bool isAdmin;
  final bool showKineName;
  final bool muted;

  const _SlotTile({
    required this.slot,
    required this.rdv,
    required this.isAdmin,
    this.showKineName = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = slot.date.isBefore(DateTime.now());
    final statusColor = slot.reserve
        ? const Color(0xFFF57C00)
        : isPast
            ? AppTheme.textSecondary
            : const Color(0xFF2E7D32);
    final statusLabel = slot.reserve
        ? 'Réservé'
        : isPast
            ? 'Passé'
            : 'Disponible';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: muted
            ? const Color(0xFFF5F5F5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: muted
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            slot.reserve ? Icons.event_busy : Icons.event_available,
            color: statusColor,
            size: 22,
          ),
        ),
        title: Text(
          RdvService.formatSlotDate(slot.date),
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: muted ? AppTheme.textSecondary : AppTheme.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${slot.label} • ${slot.duree} min'
              '${showKineName ? ' • ${slot.kineName}' : ''}',
              style: GoogleFonts.roboto(
                  fontSize: 12, color: AppTheme.textSecondary),
            ),
            if (slot.reserve && slot.patientId != null)
              Text(
                '👤 ${slot.patientId}',
                style: GoogleFonts.roboto(
                    fontSize: 11,
                    color: const Color(0xFFF57C00),
                    fontWeight: FontWeight.w500),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Bouton supprimer (kiné ou admin)
            if (!slot.reserve && !isAdmin)
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
                onPressed: () => _confirmDelete(context),
                tooltip: 'Supprimer',
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Supprimer ce créneau ?',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
        content: Text(
          RdvService.formatSlotDateFull(slot.date),
          style: GoogleFonts.roboto(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await rdv.deleteSlot(slot.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  Onglet Réservations
// ═══════════════════════════════════════════════════

class _BookingsTab extends StatelessWidget {
  final RdvService rdv;
  final String kineId;
  final bool isAdmin;
  final List<KineInfo> allKines;
  final ValueChanged<String> onKineFilterChanged;

  const _BookingsTab({
    required this.rdv,
    required this.kineId,
    required this.isAdmin,
    required this.allKines,
    required this.onKineFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final stream = (isAdmin && kineId == 'all')
        ? rdv.allBookingsStream()
        : rdv.bookingsForKineStream(kineId);

    return StreamBuilder<List<KineBooking>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookings = snap.data ?? [];

        if (bookings.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_note_outlined,
                      size: 56,
                      color:
                          AppTheme.textSecondary.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune réservation',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Les réservations apparaîtront ici\nlorsque des patients prendront RDV.',
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, i) => _BookingTile(
            booking: bookings[i],
            showKineName: isAdmin,
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════
//  Tuile d'une réservation
// ═══════════════════════════════════════════════════

class _BookingTile extends StatelessWidget {
  final KineBooking booking;
  final bool showKineName;

  const _BookingTile({required this.booking, this.showKineName = false});

  @override
  Widget build(BuildContext context) {
    final statusColor = RdvService.statusColor(booking.status);
    final statusLabel = RdvService.statusLabel(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date + status
            Row(
              children: [
                const Icon(Icons.calendar_month,
                    color: AppTheme.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    RdvService.formatSlotDate(booking.date),
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Patient info
            _infoRow(Icons.person_outline, booking.patientNom),
            _infoRow(Icons.email_outlined, booking.patientMail),
            if (showKineName)
              _infoRow(Icons.medical_services_outlined,
                  'Kiné : ${booking.kineName}'),
            _infoRow(Icons.notes_outlined, booking.motif,
                maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String value, {int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                    fontSize: 12, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════
//  Bottom Sheet — Ajouter un créneau
// ═══════════════════════════════════════════════════

class _AddSlotSheet extends StatefulWidget {
  final String kineId;
  final String kineName;
  final RdvService rdv;

  const _AddSlotSheet({
    required this.kineId,
    required this.kineName,
    required this.rdv,
  });

  @override
  State<_AddSlotSheet> createState() => _AddSlotSheetState();
}

class _AddSlotSheetState extends State<_AddSlotSheet> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int _duree = 45;
  bool _saving = false;

  static const _durees = [30, 45, 60];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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
          Text(
            'Ajouter un créneau',
            style: GoogleFonts.montserrat(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            widget.kineName,
            style: GoogleFonts.roboto(
                fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          // Date
          _fieldLabel('📅 Date'),
          GestureDetector(
            onTap: _pickDate,
            child: _displayBox(
                '${_selectedDate.day.toString().padLeft(2, '0')}/'
                '${_selectedDate.month.toString().padLeft(2, '0')}/'
                '${_selectedDate.year}',
                Icons.calendar_today_outlined),
          ),
          const SizedBox(height: 16),

          // Heure
          _fieldLabel('🕐 Heure'),
          GestureDetector(
            onTap: _pickTime,
            child: _displayBox(
                '${_selectedTime.hour.toString().padLeft(2, '0')}h'
                '${_selectedTime.minute.toString().padLeft(2, '0')}',
                Icons.schedule_outlined),
          ),
          const SizedBox(height: 16),

          // Durée
          _fieldLabel('⏱ Durée'),
          Row(
            children: _durees
                .map(
                  (d) => Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _duree = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _duree == d
                              ? AppTheme.primary.withValues(alpha: 0.1)
                              : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _duree == d
                                ? AppTheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '$d min',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: _duree == d
                                ? AppTheme.primary
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.add_circle_outline),
              label: Text(_saving ? 'Enregistrement...' : 'Ajouter ce créneau'),
              onPressed: _saving ? null : _saveSlot,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _saveSlot() async {
    setState(() => _saving = true);
    final dt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final slot = KineSlot(
      id: '',
      kineId: widget.kineId,
      kineName: widget.kineName,
      date: dt,
      duree: _duree,
      label: 'Séance kiné $_duree min',
      reserve: false,
    );
    try {
      await widget.rdv.addSlot(slot);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
    }
  }

  Widget _fieldLabel(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          t,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      );

  Widget _displayBox(String value, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primary),
            const SizedBox(width: 12),
            Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.edit_outlined,
                size: 16, color: AppTheme.textSecondary),
          ],
        ),
      );
}
