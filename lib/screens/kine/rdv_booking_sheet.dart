// ═══════════════════════════════════════════════════════════════════════════
//  RdvBookingSheet — Prise de RDV intégrée (bottom sheet patient)
//  Affiche les créneaux disponibles du kiné + formulaire de réservation
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/services/rdv_service.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';

class RdvBookingSheet extends StatefulWidget {
  final String kineId;
  final String kineName;
  final String kineEmail;

  const RdvBookingSheet({
    super.key,
    required this.kineId,
    required this.kineName,
    required this.kineEmail,
  });

  @override
  State<RdvBookingSheet> createState() => _RdvBookingSheetState();
}

class _RdvBookingSheetState extends State<RdvBookingSheet> {
  final _rdv = RdvService();
  final _nomCtrl = TextEditingController();
  final _mailCtrl = TextEditingController();
  final _motifCtrl = TextEditingController();

  KineSlot? _selectedSlot;
  bool _sending = false;
  bool _success = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec les infos du profil
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<AppProvider>();
      final prenom = prov.userProfile?.prenom ?? prov.userName ?? '';
      _nomCtrl.text = prenom;
    });
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _mailCtrl.dispose();
    _motifCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _success ? _buildSuccess(scroll) : _buildForm(scroll),
      ),
    );
  }

  // ── Vue succès ─────────────────────────────────────────────────────────

  Widget _buildSuccess(ScrollController scroll) {
    return SingleChildScrollView(
      controller: scroll,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          _buildHandle(),
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF2E7D32),
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Réservation envoyée !',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.kineName} a été notifié(e) par email.\n'
            'Vous recevrez une confirmation sous 24h.',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          if (_selectedSlot != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F8FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          RdvService.formatSlotDateFull(_selectedSlot!.date),
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${_selectedSlot!.duree} min avec ${widget.kineName}',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Fermer'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Formulaire principal ───────────────────────────────────────────────

  Widget _buildForm(ScrollController scroll) {
    return SingleChildScrollView(
      controller: scroll,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHandle(),
          const SizedBox(height: 20),

          // Titre
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calendar_month,
                    color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prendre rendez-vous',
                      style: GoogleFonts.montserrat(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'avec ${widget.kineName}',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _sectionTitle('1. Choisissez un créneau'),
          _buildSlotPicker(),

          const SizedBox(height: 20),
          _sectionTitle('2. Vos informations'),
          _buildTextField(
            controller: _nomCtrl,
            label: 'Votre prénom / nom',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _mailCtrl,
            label: 'Votre email (pour confirmation)',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 20),
          _sectionTitle('3. Motif de consultation'),
          _buildTextField(
            controller: _motifCtrl,
            label: 'Décrivez votre problème (douleur, zone...)',
            icon: Icons.medical_services_outlined,
            maxLines: 3,
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: GoogleFonts.roboto(
                          fontSize: 13, color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(_sending ? 'Envoi en cours...' : 'Confirmer le RDV'),
              onPressed: _sending ? null : _submitBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Sélecteur de créneaux ─────────────────────────────────────────────

  Widget _buildSlotPicker() {
    return StreamBuilder<List<KineSlot>>(
      stream: _rdv.availableSlotsStream(widget.kineId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final slots = snap.data ?? [];

        if (slots.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFCC02).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Color(0xFFE65100), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Aucun créneau disponible pour l\'instant.\n'
                    '${widget.kineName} mettra à jour ses disponibilités prochainement.',
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      color: const Color(0xFFE65100),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: slots.map((slot) {
            final selected = _selectedSlot?.id == slot.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedSlot = slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppTheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color:
                          selected ? AppTheme.primary : AppTheme.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            RdvService.formatSlotDate(slot.date),
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            slot.label,
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${slot.duree} min',
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ── Validation + soumission ────────────────────────────────────────────

  Future<void> _submitBooking() async {
    setState(() => _error = null);

    if (_selectedSlot == null) {
      setState(() => _error = 'Veuillez choisir un créneau.');
      return;
    }
    if (_nomCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Veuillez entrer votre prénom / nom.');
      return;
    }
    if (_mailCtrl.text.trim().isEmpty ||
        !_mailCtrl.text.contains('@')) {
      setState(() => _error = 'Veuillez entrer un email valide.');
      return;
    }
    if (_motifCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Veuillez décrire le motif de consultation.');
      return;
    }

    setState(() => _sending = true);

    try {
      await _rdv.bookSlot(
        slot: _selectedSlot!,
        patientNom: _nomCtrl.text.trim(),
        patientMail: _mailCtrl.text.trim(),
        motif: _motifCtrl.text.trim(),
        kineEmail: widget.kineEmail,
      );
      setState(() {
        _success = true;
        _sending = false;
      });
    } catch (e) {
      setState(() {
        _sending = false;
        _error = 'Erreur lors de la réservation. Veuillez réessayer.';
      });
    }
  }

  // ── Widgets helpers ────────────────────────────────────────────────────

  Widget _buildHandle() => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.divider,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          t,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.roboto(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.roboto(
              fontSize: 13, color: AppTheme.textSecondary),
          prefixIcon: Icon(icon, size: 18, color: AppTheme.primary),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
        ),
      );
}
