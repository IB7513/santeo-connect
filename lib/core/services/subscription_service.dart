// ====== Subscription Service ======
// Gestion abonnement SANTEO Connect — 49,90€/mois
// Code promo VVT26 → 2 mois offerts

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Statut de l'abonnement utilisateur
enum SubscriptionStatus {
  free,      // Gratuit — accès limité
  trial,     // Période d'essai (code promo VVT26 → 2 mois)
  active,    // Abonné actif payant
  expired,   // Abonnement expiré
}

/// Résultat de la validation d'un code promo
enum PromoResult {
  valid,
  alreadyUsed,
  invalid,
}

class SubscriptionService extends ChangeNotifier {
  // ── Clés SharedPreferences ──
  static const _kStatus         = 'sub_status';
  static const _kStartDate      = 'sub_start_date';
  static const _kEndDate        = 'sub_end_date';
  static const _kPromoUsed      = 'sub_promo_used';
  static const _kPromoCode      = 'sub_promo_code';

  // ── Code promo ──
  static const _validPromoCode  = 'VVT26';
  static const _promoMonths     = 2; // mois offerts

  // ── Prix ──
  static const double priceMonthly = 49.90;
  static const String currency     = '€';

  // ── État interne ──
  SubscriptionStatus _status = SubscriptionStatus.free;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _promoUsed = false;
  String? _promoCodeUsed;

  // ── Getters publics ──
  SubscriptionStatus get status        => _status;
  DateTime?          get startDate     => _startDate;
  DateTime?          get endDate       => _endDate;
  bool               get promoUsed     => _promoUsed;
  String?            get promoCodeUsed => _promoCodeUsed;

  /// L'utilisateur a accès aux features premium
  bool get isPremium =>
      _status == SubscriptionStatus.active ||
      _status == SubscriptionStatus.trial;

  /// Jours restants (null si pas d'abonnement actif)
  int? get daysRemaining {
    if (_endDate == null) return null;
    final diff = _endDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  /// Label affiché dans le profil
  String get statusLabel {
    switch (_status) {
      case SubscriptionStatus.free:    return 'Gratuit';
      case SubscriptionStatus.trial:   return 'Essai gratuit';
      case SubscriptionStatus.active:  return 'Premium actif';
      case SubscriptionStatus.expired: return 'Abonnement expiré';
    }
  }

  /// Label de la date de fin
  String get endDateLabel {
    if (_endDate == null) return '';
    final d = _endDate!;
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  }

  // ── Initialisation (charger depuis storage) ──
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _promoUsed     = prefs.getBool(_kPromoUsed) ?? false;
    _promoCodeUsed = prefs.getString(_kPromoCode);

    final statusStr = prefs.getString(_kStatus) ?? 'free';
    _status = _statusFromString(statusStr);

    final startStr = prefs.getString(_kStartDate);
    final endStr   = prefs.getString(_kEndDate);
    _startDate = startStr != null ? DateTime.tryParse(startStr) : null;
    _endDate   = endStr   != null ? DateTime.tryParse(endStr)   : null;

    // Vérifier expiration automatique
    if ((_status == SubscriptionStatus.active ||
         _status == SubscriptionStatus.trial) &&
        _endDate != null &&
        DateTime.now().isAfter(_endDate!)) {
      _status = SubscriptionStatus.expired;
      await prefs.setString(_kStatus, 'expired');
    }

    notifyListeners();
  }

  // ── Valider un code promo ──
  PromoResult validatePromoCode(String code) {
    if (_promoUsed) return PromoResult.alreadyUsed;
    if (code.trim().toUpperCase() == _validPromoCode) return PromoResult.valid;
    return PromoResult.invalid;
  }

  // ── Activer avec code promo (2 mois gratuits) ──
  Future<void> activateWithPromo(String code) async {
    if (validatePromoCode(code) != PromoResult.valid) return;

    final now   = DateTime.now();
    final end   = DateTime(now.year, now.month + _promoMonths, now.day);

    _status        = SubscriptionStatus.trial;
    _startDate     = now;
    _endDate       = end;
    _promoUsed     = true;
    _promoCodeUsed = code.trim().toUpperCase();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStatus,    'trial');
    await prefs.setString(_kStartDate, now.toIso8601String());
    await prefs.setString(_kEndDate,   end.toIso8601String());
    await prefs.setBool  (_kPromoUsed, true);
    await prefs.setString(_kPromoCode, _promoCodeUsed!);

    notifyListeners();
  }

  // ── Activer abonnement payant (simulation — à connecter Stripe/IAP) ──
  Future<void> activatePaidSubscription() async {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month + 1, now.day);

    _status    = SubscriptionStatus.active;
    _startDate = now;
    _endDate   = end;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStatus,    'active');
    await prefs.setString(_kStartDate, now.toIso8601String());
    await prefs.setString(_kEndDate,   end.toIso8601String());

    notifyListeners();
  }

  // ── Réinitialiser (déconnexion) ──
  Future<void> reset() async {
    _status    = SubscriptionStatus.free;
    _startDate = null;
    _endDate   = null;
    // On garde _promoUsed en mémoire même après déco (lié au device)

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStatus, 'free');
    await prefs.remove(_kStartDate);
    await prefs.remove(_kEndDate);

    notifyListeners();
  }

  // ── Helpers ──
  SubscriptionStatus _statusFromString(String s) {
    switch (s) {
      case 'trial':   return SubscriptionStatus.trial;
      case 'active':  return SubscriptionStatus.active;
      case 'expired': return SubscriptionStatus.expired;
      default:        return SubscriptionStatus.free;
    }
  }
}
