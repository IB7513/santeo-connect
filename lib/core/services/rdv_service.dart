// ═══════════════════════════════════════════════════════════════════════════
//  RdvService — Gestion des créneaux et réservations via Firebase Firestore
//  + Notifications email via EmailJS (sans backend)
// ═══════════════════════════════════════════════════════════════════════════
//
//  STRUCTURE FIRESTORE :
//  ┌─ kine_slots/{slotId}
//  │     • kineId    : String   — identifiant du kiné (nom slug ex: "axel")
//  │     • kineName  : String   — nom affiché
//  │     • date      : Timestamp
//  │     • duree     : int      — minutes (30, 45, 60)
//  │     • label     : String   — ex: "Séance kiné 45 min"
//  │     • reserve   : bool
//  │     • patientId : String?
//  │
//  └─ kine_bookings/{bookingId}
//        • kineId, kineName, slotId, date, patientNom, patientMail,
//          motif, createdAt, status

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:http/http.dart' as http;

// ─── Modèle KineSlot ───────────────────────────────────────────────────────

class KineSlot {
  final String id;
  final String kineId;
  final String kineName;
  final DateTime date;
  final int duree;
  final String label;
  final bool reserve;
  final String? patientId;

  const KineSlot({
    required this.id,
    required this.kineId,
    required this.kineName,
    required this.date,
    required this.duree,
    required this.label,
    required this.reserve,
    this.patientId,
  });

  factory KineSlot.fromFirestore(Map<String, dynamic> data, String id) {
    return KineSlot(
      id: id,
      kineId: data['kineId'] as String? ?? '',
      kineName: data['kineName'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duree: data['duree'] as int? ?? 45,
      label: data['label'] as String? ?? 'Séance kiné',
      reserve: data['reserve'] as bool? ?? false,
      patientId: data['patientId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'kineId': kineId,
        'kineName': kineName,
        'date': Timestamp.fromDate(date),
        'duree': duree,
        'label': label,
        'reserve': reserve,
        'patientId': patientId,
      };
}

// ─── Modèle KineBooking ────────────────────────────────────────────────────

class KineBooking {
  final String id;
  final String kineId;
  final String kineName;
  final String slotId;
  final DateTime date;
  final String patientNom;
  final String patientMail;
  final String motif;
  final DateTime createdAt;
  final String status; // 'en attente' | 'confirmé' | 'annulé'

  const KineBooking({
    required this.id,
    required this.kineId,
    required this.kineName,
    required this.slotId,
    required this.date,
    required this.patientNom,
    required this.patientMail,
    required this.motif,
    required this.createdAt,
    required this.status,
  });

  factory KineBooking.fromFirestore(Map<String, dynamic> data, String id) {
    return KineBooking(
      id: id,
      kineId: data['kineId'] as String? ?? '',
      kineName: data['kineName'] as String? ?? '',
      slotId: data['slotId'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      patientNom: data['patientNom'] as String? ?? '',
      patientMail: data['patientMail'] as String? ?? '',
      motif: data['motif'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'en attente',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'kineId': kineId,
        'kineName': kineName,
        'slotId': slotId,
        'date': Timestamp.fromDate(date),
        'patientNom': patientNom,
        'patientMail': patientMail,
        'motif': motif,
        'createdAt': Timestamp.fromDate(createdAt),
        'status': status,
      };
}

// ─── Service RDV ──────────────────────────────────────────────────────────

class RdvService {
  static final RdvService _instance = RdvService._internal();
  factory RdvService() => _instance;
  RdvService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ══ Configuration EmailJS ════════════════════════════════════════════════
  // Créez un compte sur https://www.emailjs.com (gratuit, 200 emails/mois)
  // Puis remplacez ces 3 valeurs par les vôtres :
  static const _emailjsServiceId  = 'YOUR_SERVICE_ID';   // ← à remplacer
  static const _emailjsTemplateId = 'YOUR_TEMPLATE_ID';  // ← à remplacer
  static const _emailjsPublicKey  = 'YOUR_PUBLIC_KEY';   // ← à remplacer
  // ════════════════════════════════════════════════════════════════════════

  // ── CRÉNEAUX ──────────────────────────────────────────────────────────

  /// Tous les créneaux d'un kiné (kiné + admin)
  Stream<List<KineSlot>> slotsStream(String kineId) {
    return _db
        .collection('kine_slots')
        .where('kineId', isEqualTo: kineId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => KineSlot.fromFirestore(d.data(), d.id))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  /// Créneaux disponibles d'un kiné (patient)
  Stream<List<KineSlot>> availableSlotsStream(String kineId) {
    final now = DateTime.now();
    return _db
        .collection('kine_slots')
        .where('kineId', isEqualTo: kineId)
        .where('reserve', isEqualTo: false)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => KineSlot.fromFirestore(d.data(), d.id))
          .where((s) => s.date.isAfter(now))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  /// Tous les créneaux — TOUS kinés (vue admin SANTEO)
  Stream<List<KineSlot>> allSlotsStream() {
    return _db.collection('kine_slots').snapshots().map((snap) {
      final list = snap.docs
          .map((d) => KineSlot.fromFirestore(d.data(), d.id))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  /// Ajouter un créneau (kiné)
  Future<void> addSlot(KineSlot slot) async {
    await _db.collection('kine_slots').add(slot.toFirestore());
  }

  /// Supprimer un créneau (kiné)
  Future<void> deleteSlot(String slotId) async {
    await _db.collection('kine_slots').doc(slotId).delete();
  }

  // ── RÉSERVATIONS ──────────────────────────────────────────────────────

  /// Réserver un créneau + créer booking + envoyer email
  Future<String> bookSlot({
    required KineSlot slot,
    required String patientNom,
    required String patientMail,
    required String motif,
    required String kineEmail,
  }) async {
    // 1. Marquer le créneau réservé
    await _db.collection('kine_slots').doc(slot.id).update({
      'reserve': true,
      'patientId': patientMail,
    });

    // 2. Créer le document réservation
    final ref = await _db.collection('kine_bookings').add(
          KineBooking(
            id: '',
            kineId: slot.kineId,
            kineName: slot.kineName,
            slotId: slot.id,
            date: slot.date,
            patientNom: patientNom,
            patientMail: patientMail,
            motif: motif,
            createdAt: DateTime.now(),
            status: 'en attente',
          ).toFirestore(),
        );

    // 3. Envoyer email au kiné
    await _sendBookingEmail(
      kineNom: slot.kineName,
      kineEmail: kineEmail,
      patientNom: patientNom,
      patientMail: patientMail,
      date: slot.date,
      motif: motif,
    );

    return ref.id;
  }

  /// Réservations d'un kiné (vue kiné & admin)
  Stream<List<KineBooking>> bookingsForKineStream(String kineId) {
    return _db
        .collection('kine_bookings')
        .where('kineId', isEqualTo: kineId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => KineBooking.fromFirestore(d.data(), d.id))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  /// Toutes les réservations — TOUS kinés (admin SANTEO)
  Stream<List<KineBooking>> allBookingsStream() {
    return _db.collection('kine_bookings').snapshots().map((snap) {
      final list = snap.docs
          .map((d) => KineBooking.fromFirestore(d.data(), d.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // ── EMAIL EmailJS ──────────────────────────────────────────────────────

  Future<void> _sendBookingEmail({
    required String kineNom,
    required String kineEmail,
    required String patientNom,
    required String patientMail,
    required DateTime date,
    required String motif,
  }) async {
    // Mode démo : EmailJS non configuré → log seulement
    if (_emailjsServiceId == 'YOUR_SERVICE_ID') {
      if (kDebugMode) {
        debugPrint(
          '📧 [EmailJS — mode démo] Nouvelle réservation\n'
          '   Pour    : $kineNom ($kineEmail)\n'
          '   Patient : $patientNom ($patientMail)\n'
          '   Date    : ${_formatDate(date)}\n'
          '   Motif   : $motif',
        );
      }
      return;
    }

    // Envoi réel via EmailJS REST API
    try {
      final response = await http
          .post(
            Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'service_id': _emailjsServiceId,
              'template_id': _emailjsTemplateId,
              'user_id': _emailjsPublicKey,
              'template_params': {
                'to_email': kineEmail,
                'kine_nom': kineNom,
                'patient_nom': patientNom,
                'patient_mail': patientMail,
                'date_rdv': _formatDate(date),
                'motif': motif,
              },
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('📧 EmailJS réponse : ${response.statusCode}');
      }
    } catch (e) {
      // Email non critique — on n'interrompt pas la réservation
      if (kDebugMode) {
        debugPrint('⚠️ EmailJS erreur : $e');
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  static String formatSlotDate(DateTime d) {
    const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const mois = [
      'jan.', 'fév.', 'mar.', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sep.', 'oct.', 'nov.', 'déc.'
    ];
    final j = jours[d.weekday - 1];
    final m = mois[d.month - 1];
    final h = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$j ${d.day} $m — ${h}h$min';
  }

  static String formatSlotDateFull(DateTime d) {
    const jours = [
      'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'
    ];
    const mois = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${jours[d.weekday - 1]} ${d.day} ${mois[d.month - 1]} ${d.year}'
        ' à ${d.hour.toString().padLeft(2, '0')}h'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime d) => RdvService.formatSlotDateFull(d);

  static String statusLabel(String status) {
    switch (status) {
      case 'confirmé':
        return '✅ Confirmé';
      case 'annulé':
        return '❌ Annulé';
      default:
        return '⏳ En attente';
    }
  }

  static Color statusColor(String status) {
    switch (status) {
      case 'confirmé':
        return const Color(0xFF2E7D32);
      case 'annulé':
        return const Color(0xFFB71C1C);
      default:
        return const Color(0xFFE65100);
    }
  }
}
