// TTS Service — Audio pré-généré ElevenLabs, joué via <audio> HTML5
// Double méthode : js.context.callMethod + postMessage (fallback)
// 66 fichiers MP3 dans web/audio/

import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class TtsService {
  static const Map<String, String> _slugMap = {
    'Abdos 2 temps':                              'abdos_2_temps',
    'Abdos 4 temps':                              'abdos_4_temps',
    'Auto-embrassade':                            'auto_embrassade',
    'Baby Stretch':                               'baby_stretch',
    'Bird Dog':                                   'bird_dog',
    'Brasse Bras':                                'brasse_bras',
    'Cat-Cow':                                    'cat_cow',
    'Child Pose & Cobra':                         'child_pose_cobra',
    'Crossed Legs Forward Fold':                  'crossed_legs_forward_fold',
    'Dead Bug':                                   'dead_bug',
    'Down Dog':                                   'down_dog',
    'Élévateur de la scapula':                    'elevateur_scapula',
    'Extension hanche plat ventre':               'extension_hanche',
    'Extension lombaire':                         'extension_lombaire',
    'Fléchisseurs des doigts et du poignet':      'flechisseurs_doigts',
    'Fort Double Stretch':                        'fort_double_stretch',
    'Gainage Crunch':                             'gainage_crunch',
    'Gainage Latéral Jambes':                     'gainage_lateral_jambes',
    'Gainage Latéral Genoux':                     'gainage_lateral_genoux',
    'Hip Hinge':                                  'hip_hinge',
    'Mountain Climber':                           'mountain_climber',
    'Paravertébraux':                             'paravertebraux',
    'Perfect Stretch':                            'perfect_stretch',
    'Planche Haute':                              'planche_haute',
    'Scorpion Stretch':                           'scorpion_stretch',
    'Seated Cat-Cow':                             'seated_cat_cow',
    'Seated Forward Fold':                        'seated_forward_fold',
    'Seated Forward Fold Split':                  'seated_forward_fold_split',
    'Seated Pigeon Stretch':                      'seated_pigeon_stretch',
    'Split Unilatéral':                           'split_unilateral',
    'Standing Posterior Pelvis Tilt':             'standing_posterior_pelvic_tilt',
    'Touch Sky Forward Fold':                     'touch_sky_forward_fold',
    'Trapèzes supérieurs':                        'trapezes_superieurs',
  };

  static Future<void> speakIntro(String exerciceName) async {
    final slug = _slugMap[exerciceName];
    if (slug == null) {
      if (kDebugMode) debugPrint('[TTS] pas de slug pour: "$exerciceName"');
      return;
    }
    _play('${slug}_intro');
  }

  static Future<void> speakFin(String exerciceName) async {
    final slug = _slugMap[exerciceName];
    if (slug == null) {
      if (kDebugMode) debugPrint('[TTS] pas de slug fin pour: "$exerciceName"');
      return;
    }
    _play('${slug}_fin');
  }

  static Future<void> speak(String text) async {}

  static Future<void> stop() async {
    if (!kIsWeb) return;
    try { js.context.callMethod('__santeoAudioStop', []); } catch (_) {}
  }

  static void _play(String slug) {
    if (!kIsWeb) return;
    if (kDebugMode) debugPrint('[TTS] _play → $slug');
    // Méthode 1 : callMethod direct sur window
    try {
      js.context.callMethod('__santeoAudioPlay', [slug]);
      if (kDebugMode) debugPrint('[TTS] callMethod OK');
      return;
    } catch (e) {
      if (kDebugMode) debugPrint('[TTS] callMethod fail: $e');
    }
    // Méthode 2 : postMessage (fallback)
    try {
      final msg = js.JsObject.jsify({'santeoPlay': slug});
      js.context.callMethod('postMessage', [msg, '*']);
      if (kDebugMode) debugPrint('[TTS] postMessage envoyé');
    } catch (e) {
      if (kDebugMode) debugPrint('[TTS] postMessage fail: $e');
    }
  }

  static void runJs(String jsCode) {}
}
