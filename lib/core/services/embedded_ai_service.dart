import 'dart:math';
import '../../models/app_models.dart';

/// ============================================================
/// SANTEO Connect — Moteur IA Embarquée
/// 100% offline · Gratuit · Adapté Pacifique
/// ============================================================
class EmbeddedAIService {
  final _rand = Random();

  // ============================================================
  // 1. GÉNÉRATION DU BILAN PERSONNALISÉ
  // ============================================================
  String generateAssessment(UserProfile profile) {
    final sb = StringBuffer();

    // === ANALYSE PROFIL FONCTIONNEL ===
    sb.writeln('📋 ANALYSE DE VOTRE PROFIL FONCTIONNEL\n');
    sb.writeln(_analyzeProfile(profile));
    sb.writeln();

    // === RECOMMANDATIONS PERSONNALISÉES ===
    sb.writeln('✅ RECOMMANDATIONS PERSONNALISÉES\n');
    final recs = _generateRecommendations(profile);
    for (var i = 0; i < recs.length; i++) {
      sb.writeln('${i + 1}. ${recs[i]}');
    }
    sb.writeln();

    // === PROGRAMME SUGGÉRÉ ===
    sb.writeln('🏃 PROGRAMME D\'EXERCICES SUGGÉRÉ\n');
    final exercises = _suggestExercises(profile);
    for (final ex in exercises) {
      sb.writeln('• $ex');
    }
    sb.writeln();

    // === NOTE CONTEXTUELLE PACIFIQUE ===
    sb.writeln(_pacificContextNote(profile.localisation));
    sb.writeln();

    // === DISCLAIMER ===
    sb.writeln(
        '⚕️ Approche de prévention fonctionnelle complémentaire aux parcours de soins.');

    return sb.toString();
  }

  // ============================================================
  // 2. ANALYSE DU PROFIL
  // ============================================================
  String _analyzeProfile(UserProfile profile) {
    final parts = <String>[];

    // Mobilité
    if (profile.niveauMobilite <= 2) {
      parts.add(
          'Votre mobilité actuelle est limitée (${profile.niveauMobilite}/5), ce qui nécessite une approche progressive et douce pour retrouver de l\'amplitude articulaire.');
    } else if (profile.niveauMobilite == 3) {
      parts.add(
          'Votre mobilité est modérée (${profile.niveauMobilite}/5). Avec un travail régulier et adapté, vous pouvez rapidement progresser vers une meilleure aisance fonctionnelle.');
    } else {
      parts.add(
          'Votre bonne mobilité (${profile.niveauMobilite}/5) est un atout précieux. L\'objectif est de la maintenir et de la renforcer avec des exercices ciblés.');
    }

    // Douleurs
    if (profile.douleursActuelles && profile.zonesDouleur.isNotEmpty) {
      final zones = profile.zonesDouleur.take(3).join(', ');
      parts.add(
          'Les douleurs signalées au niveau de : $zones méritent une attention particulière. Les exercices proposés évitent toute sollicitation excessive de ces zones.');
    } else if (!profile.douleursActuelles) {
      parts.add(
          'L\'absence de douleurs actuelles est un excellent point de départ pour un programme de prévention et de renforcement ciblé.');
    }

    // Activité
    if (profile.niveauActivite.contains('Sédentaire')) {
      parts.add(
          'Partir d\'un rythme sédentaire est tout à fait normal. Votre programme démarrera en douceur avec des séances courtes et progressives.');
    } else if (profile.niveauActivite.contains('Très actif') ||
        profile.niveauActivite.contains('Extrêmement')) {
      parts.add(
          'Votre niveau d\'activité élevé permet d\'envisager un programme plus intensif, tout en préservant les phases de récupération essentielles.');
    }

    return parts.join(' ');
  }

  // ============================================================
  // 3. RECOMMANDATIONS PERSONNALISÉES
  // ============================================================
  List<String> _generateRecommendations(UserProfile profile) {
    final recs = <String>[];

    // Fréquence adaptée
    final freq = _parseFrequency(profile.frequenceSemaine);
    recs.add(
        'Commencez par ${freq} séances de ${profile.dureeSeance} par semaine. La régularité est plus importante que l\'intensité, surtout au départ.');

    // Selon objectif
    switch (profile.objectifSante) {
      case 'Réduire les douleurs':
        recs.add(
            'Privilégiez les exercices d\'étirement et de mobilité douce. Arrêtez immédiatement si une douleur apparaît et notez-la dans votre suivi.');
        break;
      case 'Améliorer ma mobilité':
        recs.add(
            'Intégrez des exercices de mobilité articulaire matin et soir. 5 minutes le matin avant de vous lever peuvent transformer votre journée.');
        break;
      case 'Renforcer mes muscles':
        recs.add(
            'Le gainage et les exercices au poids du corps sont parfaitement adaptés à votre contexte. Pas besoin de matériel pour des résultats solides.');
        break;
      case 'Retrouver la forme':
        recs.add(
            'Combinez cardio léger (marche active) et renforcement musculaire. La progression sur 4 semaines sera rapide et visible.');
        break;
      case 'Prévention et bien-être':
        recs.add(
            'Un programme varié mélangeant mobilité, renforcement et relaxation est idéal. Visez l\'équilibre plutôt que la performance.');
        break;
      default:
        recs.add(
            'Un programme équilibré combinant mobilité, renforcement et cardio léger sera le plus bénéfique pour votre objectif.');
    }

    // Contexte climatique
    recs.add(
        'En milieu tropical, pratiquez de préférence tôt le matin (6h-8h) ou en soirée (17h-19h) pour éviter la chaleur et l\'humidité. Hydratez-vous bien avant et après chaque séance.');

    // Selon problèmes de santé
    if (profile.problemesSante.contains('Lombalgie chronique') ||
        profile.problemesSante.contains('Hernie discale')) {
      recs.add(
          'Avec vos antécédents de dos, les exercices de gainage profond et d\'étirement du dos sont prioritaires. Évitez les flexions avant brusques.');
    } else if (profile.problemesSante.contains('Arthrose')) {
      recs.add(
          'Avec l\'arthrose, privilégiez les mouvements en amplitude réduite et sans impact. La natation ou la marche en eau sont excellentes si disponibles sur votre territoire.');
    } else if (profile.problemesSante.contains('Hypertension')) {
      recs.add(
          'Avec l\'hypertension, évitez les efforts brusques et les apnées. Respirez toujours régulièrement pendant les exercices.');
    }

    // Si pas de problèmes spécifiques, conseil général
    if (recs.length < 4) {
      recs.add(
          'Écoutez votre corps. Une légère fatigue musculaire le lendemain est normale. Une douleur aiguë ou persistante doit vous alerter à consulter un professionnel.');
    }

    return recs.take(4).toList();
  }

  // ============================================================
  // 4. PROGRAMME D'EXERCICES SUGGÉRÉS
  // ============================================================
  List<String> _suggestExercises(UserProfile profile) {
    final exercises = <String>[];
    final preferences = profile.preferencesExercices;
    final hasDouleurs = profile.douleursActuelles;
    final mobilite = profile.niveauMobilite;

    // Toujours commencer par de la mobilité si mobilité faible
    if (mobilite <= 2 || hasDouleurs) {
      exercises.add(
          'Respiration diaphragmatique (5 min) — Relaxe le système nerveux, réduit la perception de la douleur');
      exercises.add(
          'Mobilité du dos chat-vache (8 min, facile) — Déverrouille la colonne vertébrale progressivement');
      exercises.add(
          'Étirements nuque et épaules (5 min, facile) — Relâche les tensions accumulées');
    }

    // Selon préférences
    if (preferences.contains('Renforcement musculaire') || mobilite >= 3) {
      exercises.add(
          'Gainage abdominal planche (7 min, moyen) — Stabilise le dos, protège les articulations');
      exercises.add(
          'Squats au poids du corps (10 min, moyen) — Renforce jambes et fessiers sans matériel');
    }

    if (preferences.contains('Étirements / Flexibilité') || hasDouleurs) {
      exercises.add(
          'Étirement global du dos allongé (5 min, facile) — Libère les tensions lombaires');
      exercises.add(
          'Étirement des ischio-jambiers (6 min, facile) — Améliore la posture et réduit les douleurs');
    }

    if (preferences.contains('Cardio léger') ||
        profile.objectifSante.contains('forme')) {
      exercises.add(
          'Marche active 15-20 min le matin — Idéale avant la chaleur, améliore l\'endurance cardiovasculaire');
    }

    if (preferences.contains('Mobilité articulaire')) {
      exercises.add(
          'Mobilité des hanches — cercles et rotations (8 min) — Essentiel pour la marche et la posture');
    }

    if (preferences.contains('Relaxation / Respiration')) {
      exercises.add(
          'Cohérence cardiaque 5 min (matin + soir) — Réduit le stress, améliore la récupération');
    }

    // Remplir si pas assez
    if (exercises.length < 5) {
      exercises.add(
          'Renforcement des épaules (10 min, moyen) — Prévient les douleurs cervicales fréquentes au bureau');
      exercises.add(
          'Équilibre unipodal (5 min, facile) — Améliore la proprioception, prévient les chutes');
    }

    return exercises.take(7).toList();
  }

  // ============================================================
  // 5. NOTE CONTEXTUELLE PACIFIQUE
  // ============================================================
  String _pacificContextNote(String localisation) {
    final territory = _detectTerritory(localisation);

    switch (territory) {
      case 'nouvelle_caledonie':
        return '🌊 Contexte Nouvelle-Calédonie : Le lagon et les plages sont vos meilleures salles de sport. La marche pieds nus sur le sable travaille naturellement l\'équilibre et renforce les pieds. La natation en lagon est excellente pour toutes les pathologies articulaires.';
      case 'polynesie':
        return '🌺 Contexte Polynésie française : Les activités traditionnelles comme le va\'a (pirogue) sont d\'excellents exercices fonctionnels. La marche sur les sentiers de montagne de Moorea ou Tahiti offre un cardio naturel idéal.';
      case 'wallis':
        return '🌴 Contexte Wallis-et-Futuna : La vie quotidienne (jardinage, pêche, marché) intègre naturellement de l\'activité physique bénéfique. Valorisez ces mouvements traditionnels comme partie de votre programme.';
      default:
        return '🌏 Contexte insulaire Pacifique : Votre environnement naturel est votre meilleure ressource. Plage, nature, activités traditionnelles — intégrez ces éléments dans votre routine pour un programme durable et culturellement ancré.';
    }
  }

  String _detectTerritory(String localisation) {
    final lower = localisation.toLowerCase();
    if (lower.contains('calédonie') ||
        lower.contains('caledonie') ||
        lower.contains('nouméa') ||
        lower.contains('noumea')) {
      return 'nouvelle_caledonie';
    }
    if (lower.contains('polynésie') ||
        lower.contains('polynesie') ||
        lower.contains('tahiti') ||
        lower.contains('papeete')) {
      return 'polynesie';
    }
    if (lower.contains('wallis') || lower.contains('futuna')) {
      return 'wallis';
    }
    return 'pacifique';
  }

  // ============================================================
  // 6. ANALYSE PROGRESSION HEBDOMADAIRE
  // ============================================================
  String analyzeProgress({
    required double adherence,
    required int tempsTotal,
    required double niveauDouleur,
    required String prenom,
  }) {
    final sb = StringBuffer();

    // Encouragement selon adhérence
    if (adherence >= 80) {
      sb.writeln(
          '🌟 Bravo $prenom ! Votre adhérence de ${adherence.toStringAsFixed(0)}% cette semaine est excellente. Vous êtes dans les meilleurs 20% des utilisateurs actifs. Continuez sur cette lancée !');
    } else if (adherence >= 50) {
      sb.writeln(
          '💪 Belle semaine $prenom ! Avec ${adherence.toStringAsFixed(0)}% d\'adhérence et $tempsTotal minutes d\'activité, vous progressez bien. Chaque séance compte !');
    } else if (adherence >= 20) {
      sb.writeln(
          '🌱 Bonne semaine $prenom ! Vous avez fait ${adherence.toStringAsFixed(0)}% de vos objectifs. C\'est un début solide. La régularité s\'installe progressivement.');
    } else {
      sb.writeln(
          '☀️ $prenom, même une petite séance cette semaine est une victoire. La vie quotidienne dans les îles est déjà une forme d\'activité. Reprenez à votre rythme !');
    }

    // Recommandation douleur
    if (niveauDouleur > 6) {
      sb.writeln(
          '\n⚠️ Ajustement recommandé : Votre niveau de douleur (${niveauDouleur.toStringAsFixed(0)}/10) est élevé cette semaine. Réduisez l\'intensité de 30%, privilégiez étirements doux et respiration. Si la douleur persiste, consultez un kinésithérapeute.');
    } else if (niveauDouleur > 3) {
      sb.writeln(
          '\n📊 Ajustement : Légère douleur notée. Maintenez le programme actuel mais remplacez les exercices de renforcement par des étirements cette semaine. Votre corps récupère.');
    } else {
      sb.writeln(
          '\n📈 Programme semaine prochaine : Douleur bien contrôlée ! Vous pouvez augmenter progressivement de 10% le volume (durée ou répétitions). Votre corps est prêt à progresser.');
    }

    return sb.toString();
  }

  // ============================================================
  // 7. DÉTECTION ESCALADE
  // ============================================================
  Map<String, String> detectEscalation({
    required double douleur,
    required double adherence,
    required int dureeEnSemaines,
    required String prenom,
  }) {
    // Cas critique — escalade vers professionnel
    if (douleur >= 7) {
      return {
        'status': 'ESCALADE',
        'message':
            '⚠️ $prenom, votre niveau de douleur (${douleur.toStringAsFixed(0)}/10) nécessite l\'attention d\'un professionnel de santé. Nous vous recommandons de consulter un kinésithérapeute ou médecin. Suspendez les exercices intensifs jusqu\'à consultation.',
      };
    }

    // Cas démotivation — encouragement
    if (adherence < 30 && dureeEnSemaines >= 2) {
      return {
        'status': 'ENCOURAGEMENT',
        'message':
            '💙 $prenom, nous remarquons que les séances sont difficiles à maintenir en ce moment. C\'est tout à fait normal ! Essayez de réduire à 10 minutes par jour — même une courte marche compte. Votre santé mérite cette attention, même les jours chargés.',
      };
    }

    // Pas de progrès après 4 semaines
    if (dureeEnSemaines >= 4 && adherence < 50) {
      return {
        'status': 'ENCOURAGEMENT',
        'message':
            '🔄 $prenom, après ${dureeEnSemaines} semaines, c\'est peut-être le bon moment de revoir votre programme. Souhaitez-vous refaire une évaluation pour adapter les exercices à votre évolution ? Un nouveau départ peut relancer la motivation !',
      };
    }

    // Tout va bien
    return {
      'status': 'CONTINUE',
      'message':
          '✅ $prenom, tout va dans le bon sens ! Adherence: ${adherence.toStringAsFixed(0)}%, douleur maîtrisée. Continuez votre programme actuel. Vous êtes sur la bonne voie !',
    };
  }

  // ============================================================
  // 8. GÉNÉRATION PROGRAMME 7 JOURS
  // ============================================================
  List<Exercise> generateWeekProgram(UserProfile profile) {
    final allExercises = _getExercisePool(profile);
    allExercises.shuffle(_rand);
    return allExercises.take(7).toList();
  }

  List<Exercise> _getExercisePool(UserProfile profile) {
    final pool = <Exercise>[];
    final prefs = profile.preferencesExercices;
    final hasDouleurs = profile.douleursActuelles;
    final mobilite = profile.niveauMobilite;

    // Toujours inclus
    pool.addAll([
      Exercise(
        id: 'ai_resp',
        name: 'Respiration relaxation',
        description:
            'Installez-vous confortablement. Inspirez 4 secondes par le nez, retenez 4 secondes, expirez lentement 6 secondes par la bouche. Idéal pour démarrer ou finir une séance.',
        duration: 8,
        difficulty: 'facile',
        targetZone: 'Bien-être général',
        type: 'mobilite',
      ),
      Exercise(
        id: 'ai_dos',
        name: 'Étirement du dos (chat-vache)',
        description:
            'À quatre pattes, alternez dos rond en expirant (chat) et dos creux en inspirant (vache). Mouvement lent et fluide. 10 répétitions. Parfait pour déverrouiller la colonne.',
        duration: 8,
        difficulty: 'facile',
        targetZone: 'Dos',
        type: 'mobilite',
      ),
    ]);

    // Selon mobilité
    if (mobilite >= 3 || !hasDouleurs) {
      pool.addAll([
        Exercise(
          id: 'ai_gainage',
          name: 'Gainage abdominal',
          description:
              'Position planche sur les avant-bras. Corps droit, abdos contractés. Maintenez 20-30 secondes. Récupération 30 secondes. 3 séries. Renforce toute la ceinture abdominale.',
          duration: 7,
          difficulty: 'moyen',
          targetZone: 'Abdominaux',
          type: 'renforcement',
        ),
        Exercise(
          id: 'ai_squat',
          name: 'Squats au poids du corps',
          description:
              'Pieds écartés largeur d\'épaules. Descendez lentement en gardant le dos droit et les genoux dans l\'axe des pieds. 3 séries de 10-12. Sans matériel, très efficace.',
          duration: 12,
          difficulty: mobilite >= 4 ? 'moyen' : 'difficile',
          targetZone: 'Jambes / Fessiers',
          type: 'renforcement',
        ),
      ]);
    }

    // Étirements si douleurs ou préférence
    if (hasDouleurs ||
        prefs.contains('Étirements / Flexibilité')) {
      pool.addAll([
        Exercise(
          id: 'ai_nuque',
          name: 'Étirement nuque et épaules',
          description:
              'Assis ou debout. Inclinez doucement la tête vers l\'épaule droite, main gauche dans le dos. Maintenez 20 secondes. Répétez de l\'autre côté. 3 fois par côté. Libère les tensions du bureau.',
          duration: 6,
          difficulty: 'facile',
          targetZone: 'Cou / Épaules',
          type: 'etirement',
        ),
        Exercise(
          id: 'ai_jambes',
          name: 'Étirement des ischio-jambiers',
          description:
              'Assis au sol, jambe tendue devant vous. Penchez-vous doucement vers l\'avant en gardant le dos droit. Maintenez 30 secondes. Essentiel pour la posture et les lombaires.',
          duration: 6,
          difficulty: 'facile',
          targetZone: 'Jambes / Dos',
          type: 'etirement',
        ),
      ]);
    }

    // Cardio si préférence ou objectif forme
    if (prefs.contains('Cardio léger') ||
        profile.objectifSante.contains('forme') ||
        profile.objectifSante.contains('Prévention')) {
      pool.add(Exercise(
        id: 'ai_marche',
        name: 'Marche active matinale',
        description:
            'Marchez 15-20 minutes à un rythme soutenu, bras actifs. Idéalement tôt le matin avant la chaleur. En bord de mer si possible — le sable renforce naturellement les chevilles. Cœur et humeur garantis !',
        duration: 20,
        difficulty: 'facile',
        targetZone: 'Cardio général',
        type: 'cardio',
      ));
    }

    // Mobilité hanches
    if (prefs.contains('Mobilité articulaire') || mobilite < 4) {
      pool.add(Exercise(
        id: 'ai_hanches',
        name: 'Mobilité des hanches',
        description:
            'Debout, pieds écartés. Effectuez de grands cercles de hanches dans les deux sens. 10 cercles par direction. Mouvement fluide. Libère les tensions du bassin et améliore la marche.',
        duration: 8,
        difficulty: 'facile',
        targetZone: 'Hanches',
        type: 'mobilite',
      ));
    }

    // Épaules
    pool.add(Exercise(
      id: 'ai_epaules',
      name: 'Renforcement des épaules',
      description:
          'Debout ou assis. Bras tendus sur les côtés à hauteur d\'épaules. Petits cercles vers l\'avant (15x) puis vers l\'arrière (15x). Augmentez progressivement les cercles. Prévient les douleurs cervicales.',
      duration: 8,
      difficulty: 'facile',
      targetZone: 'Épaules',
      type: 'renforcement',
    ));

    // Équilibre
    pool.add(Exercise(
      id: 'ai_equilibre',
      name: 'Équilibre unipodal',
      description:
          'Tenez-vous sur un pied, l\'autre légèrement relevé. Maintenez 30 secondes les yeux ouverts, puis fermés. Alternez. Excellent pour la proprioception et la prévention des entorses.',
      duration: 5,
      difficulty: 'moyen',
      targetZone: 'Chevilles / Équilibre',
      type: 'mobilite',
    ));

    return pool;
  }

  // ============================================================
  // UTILITAIRES
  // ============================================================
  int _parseFrequency(String freq) {
    final match = RegExp(r'\d+').firstMatch(freq);
    return int.tryParse(match?.group(0) ?? '3') ?? 3;
  }
}
