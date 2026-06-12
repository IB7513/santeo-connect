import 'dart:math';

/// Service centralisé de messages motivationnels et félicitations
/// Adapté à tous les territoires (France, DOM-TOM, Pacifique...)
class MotivationService {
  static final _random = Random();

  // ══════════════════════════════════════════════════════
  //  MESSAGES ONBOARDING
  // ══════════════════════════════════════════════════════

  static String stepCompleted(int step, String prenom) {
    final name = prenom.isNotEmpty ? prenom : 'vous';
    switch (step) {
      case 0:
        final msgs = [
          '🌺 Excellent, $name ! Votre profil est enregistré. Vous faites un geste important pour votre santé !',
          '👏 Parfait, $name ! Première étape franchie. Chaque information nous aide à mieux vous accompagner.',
          '✅ Bravo, $name ! Votre profil est prêt. Plus que 3 étapes vers votre bilan personnalisé !',
        ];
        return msgs[_random.nextInt(msgs.length)];
      case 1:
        final msgs = [
          '💙 Super, $name ! Votre état fonctionnel est bien pris en compte. Votre honnêteté nous aide à vous proposer le bon programme.',
          '🏋️ Excellent ! Étape 2 validée. Vos informations de santé nous permettront d\'adapter chaque exercice à votre condition.',
          '🌟 Formidable ! La transparence sur votre condition physique est la clé d\'un programme vraiment personnalisé.',
        ];
        return msgs[_random.nextInt(msgs.length)];
      case 2:
        final msgs = [
          '🩺 Bravo $name ! Vos antécédents médicaux sont enregistrés. Plus qu\'une étape pour votre bilan personnalisé !',
          '💪 Très bien ! En partageant vos antécédents, vous permettez à notre IA de créer un programme 100% sécurisé pour vous.',
          '🎯 Excellent travail, $name ! Dernière étape : personnalisez vos préférences d\'entraînement.',
        ];
        return msgs[_random.nextInt(msgs.length)];
      default:
        return '✅ Étape complétée ! Continuez, vous êtes presque arrivé(e) !';
    }
  }

  static String onboardingComplete(String prenom) {
    final name = prenom.isNotEmpty ? prenom : 'vous';
    final msgs = [
      '🎊 Félicitations, $name ! Votre profil complet est enregistré. Votre programme personnalisé est en cours de génération...',
      '🌺 Ia orana, $name ! Profil terminé avec succès. L\'intelligence artificielle analyse maintenant votre profil pour vous.',
      '🏆 Bravo $name ! Vous avez complété toutes les étapes. Votre programme santé personnalisé arrive dans quelques secondes !',
    ];
    return msgs[_random.nextInt(msgs.length)];
  }

  // ══════════════════════════════════════════════════════
  //  MESSAGES PROGRAMME
  // ══════════════════════════════════════════════════════

  static String assessmentReady(String prenom) {
    final name = prenom.isNotEmpty ? prenom : 'vous';
    final msgs = [
      '🎉 $name, votre programme personnalisé est prêt ! Il a été 100% personnalisé selon votre profil unique.',
      '✨ Bilan généré pour vous, $name ! Chaque recommandation a été personnalisée pour votre profil.',
      '🌟 Votre bilan personnalisé est arrivé, $name ! Découvrez vos recommandations exclusives.',
    ];
    return msgs[_random.nextInt(msgs.length)];
  }

  // ══════════════════════════════════════════════════════
  //  MESSAGES EXERCICES
  // ══════════════════════════════════════════════════════

  static String exerciseCompleted(String exerciseName, int totalSessions) {
    if (totalSessions == 1) {
      return '🎉 Bravo ! Première séance complétée ! Vous venez de faire le pas le plus important !';
    }
    if (totalSessions == 3) {
      return '🔥 $exerciseName terminé ! 3 séances déjà — vous créez une vraie habitude santé !';
    }
    if (totalSessions == 5) {
      return '⭐ $exerciseName terminé ! 5 séances complétées — vous faites partie de nos utilisateurs les plus assidus !';
    }
    if (totalSessions % 10 == 0) {
      return '🏆 Incroyable ! $totalSessions séances au total ! Vous êtes un véritable champion de la santé !';
    }
    final msgs = [
      '💪 $exerciseName terminé ! Bravo, chaque séance renforce votre corps et votre bien-être !',
      '🌺 Excellent travail ! $exerciseName accompli avec succès. Votre santé vous remercie !',
      '🎯 $exerciseName complété ! Vous avancez vers vos objectifs santé, séance après séance !',
      '✅ Super séance ! $exerciseName terminé. Ressentez-vous déjà les bienfaits ?',
      '🌟 Bravo pour cette séance de $exerciseName ! Continuez, vous êtes sur la bonne voie !',
    ];
    return msgs[_random.nextInt(msgs.length)];
  }

  static String sessionMilestone(int sessionCount) {
    switch (sessionCount) {
      case 1: return '🌱 Première séance ! Le voyage de mille kilomètres commence par un premier pas.';
      case 3: return '🔥 3 séances ! Vous commencez à créer une habitude. Continuez !';
      case 5: return '⭐ 5 séances ! Vous faites partie des plus réguliers. Bravo !';
      case 7: return '🎯 7 séances ! Une semaine de défi relevé. Vous êtes fantastique !';
      case 10: return '🏅 10 séances ! Vous atteignez le niveau champion de la santé. Bravo !';
      case 20: return '🥈 20 séances ! Médaille d\'argent — vous êtes une vraie source d\'inspiration !';
      case 30: return '🥇 30 séances ! Médaille d\'or ! Vous êtes un véritable athlète de la santé !';
      case 50: return '🏆 50 séances ! Légende de la santé ! Vous êtes exceptionnel(le) !';
      default: return '';
    }
  }

  // ══════════════════════════════════════════════════════
  //  MESSAGES PROGRESSION
  // ══════════════════════════════════════════════════════

  static String adherenceMessage(double adherence) {
    if (adherence >= 90) {
      return '🌟 Adhérence de ${adherence.toStringAsFixed(0)}% — PARFAIT ! Vous êtes exceptionnel(le) cette semaine !';
    }
    if (adherence >= 80) {
      return '🏆 ${adherence.toStringAsFixed(0)}% d\'adhérence — Performance excellente ! Continuez comme ça !';
    }
    if (adherence >= 70) {
      return '💪 ${adherence.toStringAsFixed(0)}% d\'adhérence — Très bonne semaine ! Vous êtes régulier(e) !';
    }
    if (adherence >= 60) {
      return '🌺 ${adherence.toStringAsFixed(0)}% — Bonne progression ! Encore un petit effort pour atteindre 70% !';
    }
    if (adherence >= 40) {
      return '🌱 ${adherence.toStringAsFixed(0)}% — Vous progressez ! Chaque séance supplémentaire fait la différence.';
    }
    if (adherence > 0) {
      return '💙 Bon début ! Chaque séance compte. Visez 3 séances cette semaine, vous pouvez le faire !';
    }
    return '🌟 Commencez votre première séance aujourd\'hui — votre corps vous remerciera !';
  }

  static String streakMessage(int streak) {
    if (streak <= 0) return '';
    if (streak == 1) return '🌱 1 jour consécutif ! C\'est un début prometteur !';
    if (streak == 3) return '🔥 3 jours de suite ! La régularité commence ici !';
    if (streak == 5) return '⭐ 5 jours consécutifs ! Vous êtes en feu !';
    if (streak == 7) return '🏆 7 jours d\'affilée ! Une semaine parfaite — vous êtes une légende !';
    if (streak >= 14) return '🌟 $streak jours consécutifs ! Performance remarquable !';
    return '💪 $streak jours consécutifs ! Continuez, c\'est votre meilleur streak !';
  }

  // ══════════════════════════════════════════════════════
  //  MESSAGES DASHBOARD
  // ══════════════════════════════════════════════════════

  static String dashboardGreeting(String prenom, int sessions, double adherence, bool hasAssessment) {
    if (sessions == 0 && !hasAssessment) {
      return '🌺 Bienvenue ! Générez votre programme pour démarrer votre parcours santé personnalisé.';
    }
    if (sessions == 1) {
      return '🎉 Bravo pour votre première séance ! Vous avez franchi le pas le plus important !';
    }
    if (sessions == 3) {
      return '🔥 3 séances déjà ! Vous créez une belle habitude santé, $prenom !';
    }
    if (sessions == 5) {
      return '⭐ 5 séances ! Vous faites partie des utilisateurs les plus réguliers !';
    }
    if (sessions >= 10) {
      return '🏆 $sessions séances réalisées ! Vous êtes un véritable champion de la santé !';
    }
    if (adherence >= 80) {
      return '🌟 ${adherence.toStringAsFixed(0)}% d\'adhérence cette semaine — Performance exceptionnelle, $prenom !';
    }
    if (adherence >= 60) {
      return '💪 Belle régularité ! ${adherence.toStringAsFixed(0)}% d\'adhérence — Continuez, $prenom !';
    }
    if (!hasAssessment) {
      return '✨ Profil créé ! Générez votre programme pour un parcours 100% personnalisé.';
    }
    return '💙 Bonne séance aujourd\'hui, $prenom ! Chaque effort compte.';
  }

  // ══════════════════════════════════════════════════════
  //  MESSAGES D'ENCOURAGEMENT (adaptés à tous les territoires)
  // ══════════════════════════════════════════════════════

  static List<String> universalEncouragement() {
    return [
      '🌟 Prendre soin de sa santé, c\'est prendre soin de sa famille.',
      '💙 Votre force intérieure est immense. Continuez !',
      '🌿 Chaque séance est un investissement pour votre futur.',
      '🌸 Votre engagement pour la santé inspire votre entourage.',
      '💪 Ia orana ! Maeva ! Chaque effort vous rapproche de vos objectifs.',
    ];
  }

  /// Messages Pacifique (gardés pour compatibilité)
  static List<String> pacificEncouragement() {
    return [
      '🌺 Ia orana ! Prendre soin de sa santé, c\'est prendre soin de sa famille.',
      '🌊 Comme l\'océan, votre force est immense. Continuez !',
      '🌴 Dans nos îles, la santé est un trésor collectif. Vous montrez l\'exemple !',
      '🐚 Chaque séance est un pas vers une vie plus épanouie.',
      '🌺 Maeva ! Votre engagement pour la santé inspire votre entourage.',
    ];
  }

  static String randomEncouragementMsg({String territoire = ''}) {
    final isPacifique = territoire.toLowerCase().contains('calédonie') ||
        territoire.toLowerCase().contains('polynésie') ||
        territoire.toLowerCase().contains('wallis') ||
        territoire.toLowerCase().contains('pacifique');
    final msgs = isPacifique ? pacificEncouragement() : universalEncouragement();
    return msgs[_random.nextInt(msgs.length)];
  }

  static String randomPacificMsg() {
    final msgs = pacificEncouragement();
    return msgs[_random.nextInt(msgs.length)];
  }

  // ══════════════════════════════════════════════════════
  //  COULEURS ET ICÔNES PAR NIVEAU
  // ══════════════════════════════════════════════════════

  static MotivationLevel getLevel(int sessions, double adherence) {
    if (sessions >= 30 || adherence >= 90) return MotivationLevel.champion;
    if (sessions >= 10 || adherence >= 80) return MotivationLevel.excellent;
    if (sessions >= 5 || adherence >= 60) return MotivationLevel.good;
    if (sessions >= 1 || adherence >= 20) return MotivationLevel.starting;
    return MotivationLevel.beginner;
  }
}

enum MotivationLevel { beginner, starting, good, excellent, champion }

extension MotivationLevelExt on MotivationLevel {
  String get label {
    switch (this) {
      case MotivationLevel.champion: return '🏆 Champion';
      case MotivationLevel.excellent: return '⭐ Excellent';
      case MotivationLevel.good: return '💪 Régulier';
      case MotivationLevel.starting: return '🌱 En démarrage';
      case MotivationLevel.beginner: return '🌟 Débutant';
    }
  }

  int get colorValue {
    switch (this) {
      case MotivationLevel.champion: return 0xFFFF9E80;
      case MotivationLevel.excellent: return 0xFF66BB6A;
      case MotivationLevel.good: return 0xFF26C6DA;
      case MotivationLevel.starting: return 0xFF7E57C2;
      case MotivationLevel.beginner: return 0xFF78909C;
    }
  }

  String get iconAsset {
    switch (this) {
      case MotivationLevel.champion: return '🏆';
      case MotivationLevel.excellent: return '⭐';
      case MotivationLevel.good: return '💪';
      case MotivationLevel.starting: return '🌱';
      case MotivationLevel.beginner: return '🌟';
    }
  }
}
