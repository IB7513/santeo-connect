import '../../models/app_models.dart';

/// ============================================================
/// SANTEO Connect — Moteur de Chat IA Embarqué
/// Répond aux questions santé, exercices, Pacifique
/// 100% offline · Gratuit · Contextuel
/// ============================================================
class ChatAIService {
  final UserProfile? userProfile;

  ChatAIService({this.userProfile});

  String get _prenom => userProfile?.prenom ?? 'vous';
  String get _territoire => userProfile?.localisation ?? 'votre territoire';
  String get _objectif => userProfile?.objectifSante ?? '';

  // ============================================================
  // POINT D'ENTRÉE PRINCIPAL
  // ============================================================
  String reply(String message) {
    final msg = message.toLowerCase().trim();

    // === SALUTATIONS ===
    if (_matches(msg, ['bonjour', 'salut', 'hello', 'coucou', 'bonsoir', 'bonne nuit'])) {
      return _greet();
    }

    // === QUI ES-TU / L'IA ===
    if (_matches(msg, ['qui es-tu', 'qui es tu', 'qui êtes', 'tu es quoi', 'c\'est quoi', 'comment tu fonctionne', 'comment fonctionne', 'tu es une ia', 'es-tu une ia'])) {
      return _whoAmI();
    }

    // === EXERCICES SPÉCIFIQUES ===
    if (_matches(msg, ['chat vache', 'chat-vache', 'chatvache'])) {
      return _explainChatVache();
    }
    if (_matches(msg, ['gainage', 'planche', 'abdos', 'abdomin'])) {
      return _explainGainage();
    }
    if (_matches(msg, ['squat', 'squats', 'jambe', 'jambes', 'cuisses', 'fessier'])) {
      return _explainSquats();
    }
    if (_matches(msg, ['étirement', 'etirement', 'stretching', 'souplesse', 'flexibilité'])) {
      return _explainEtirements();
    }
    if (_matches(msg, ['respiration', 'respirer', 'souffle', 'cohérence cardiaque', 'relaxation', 'stress'])) {
      return _explainRespiration();
    }
    if (_matches(msg, ['mobilité', 'mobilite', 'articulation', 'raideur', 'rigidité', 'souple'])) {
      return _explainMobilite();
    }
    if (_matches(msg, ['marche', 'marcher', 'walking', 'cardio', 'cardiovasculaire'])) {
      return _explainMarche();
    }
    if (_matches(msg, ['épaule', 'epaule', 'bras', 'coude', 'poignet'])) {
      return _explainEpaules();
    }
    if (_matches(msg, ['dos', 'lombalgie', 'lombaire', 'colonne', 'vertèbre', 'hernie'])) {
      return _explainDos();
    }
    if (_matches(msg, ['nuque', 'cou', 'cervical', 'cervicale', 'tête qui tourne'])) {
      return _explainNuque();
    }
    if (_matches(msg, ['hanche', 'bassin', 'hip', 'sciatique'])) {
      return _explainHanches();
    }
    if (_matches(msg, ['genou', 'genoux', 'rotule', 'ligament'])) {
      return _explainGenoux();
    }
    if (_matches(msg, ['cheville', 'pied', 'pieds', 'entorse', 'orteil'])) {
      return _explainChevilles();
    }

    // === DOULEUR ===
    if (_matches(msg, ['douleur', 'mal', 'douleurs', 'souffre', 'souffrir', 'ça fait mal', 'j\'ai mal'])) {
      return _handleDouleur(msg);
    }
    if (_matches(msg, ['douleur 7', 'douleur 8', 'douleur 9', 'douleur 10', 'très forte douleur', 'insupportable', 'urgence'])) {
      return _urgenceDouleur();
    }

    // === PROGRAMME / SÉANCE ===
    if (_matches(msg, ['programme', 'séance', 'seance', 'exercice', 'exercices', 'entraînement', 'entrainement', 'sport'])) {
      return _aboutProgram();
    }
    if (_matches(msg, ['combien', 'fréquence', 'frequence', 'fois par semaine', 'jours par semaine'])) {
      return _aboutFrequency();
    }
    if (_matches(msg, ['combien de temps', 'durée', 'duree', 'minutes', 'longtemps'])) {
      return _aboutDuration();
    }
    if (_matches(msg, ['quand faire', 'quel moment', 'matin', 'soir', 'midi', 'heure'])) {
      return _bestTime();
    }

    // === CHALEUR / CLIMAT ===
    if (_matches(msg, ['chaleur', 'chaud', 'humidité', 'humide', 'tropical', 'soleil', 'température'])) {
      return _aboutHeat();
    }
    if (_matches(msg, ['hydratation', 'eau', 'boire', 'soif'])) {
      return _aboutHydration();
    }

    // === MOTIVATION ===
    if (_matches(msg, ['motivat', 'courage', 'fatigué', 'fatigue', 'pas envie', 'difficile', 'dur', 'abandonne', 'arrêter'])) {
      return _motivation();
    }
    if (_matches(msg, ['bien dormi', 'dormir', 'sommeil', 'nuit', 'insomnie'])) {
      return _aboutSleep();
    }
    if (_matches(msg, ['poids', 'mincir', 'maigrir', 'grossir', 'ventre', 'obésité', 'régime'])) {
      return _aboutWeight();
    }

    // === TERRITOIRE PACIFIQUE ===
    if (_matches(msg, ['calédonie', 'caledonie', 'nouméa', 'noumea'])) {
      return _aboutNewCaledonia();
    }
    if (_matches(msg, ['polynésie', 'polynesie', 'tahiti', 'papeete'])) {
      return _aboutPolynesie();
    }
    if (_matches(msg, ['wallis', 'futuna'])) {
      return _aboutWallis();
    }
    if (_matches(msg, ['pacifique', 'île', 'iles', 'insulaire', 'territoire'])) {
      return _aboutPacific();
    }

    // === BILAN ===
    if (_matches(msg, ['bilan', 'évaluation', 'evaluation', 'résultat', 'resultat', 'diagnostic'])) {
      return _aboutBilan();
    }

    // === PROGRESSION / SUIVI ===
    if (_matches(msg, ['progrès', 'progres', 'progression', 'amélioration', 'amelioration', 'résultat', 'résultats'])) {
      return _aboutProgress();
    }

    // === ALIMENTATION ===
    if (_matches(msg, ['manger', 'alimentation', 'nourriture', 'régime', 'nutrition', 'fruit', 'légume'])) {
      return _aboutNutrition();
    }

    // === REMERCIEMENTS ===
    if (_matches(msg, ['merci', 'thank', 'super', 'génial', 'excellent', 'parfait', 'bravo', 'bien', 'top'])) {
      return _thanks();
    }

    // === AU REVOIR ===
    if (_matches(msg, ['au revoir', 'bye', 'à bientôt', 'a bientot', 'ciao', 'tchao'])) {
      return _goodbye();
    }

    // === AIDE ===
    if (_matches(msg, ['aide', 'help', 'comment', 'que faire', 'quoi faire', 'je ne sais pas', 'je sais pas'])) {
      return _help();
    }

    // === RÉPONSE PAR DÉFAUT ===
    return _defaultReply(msg);
  }

  // ============================================================
  // RÉPONSES
  // ============================================================

  String _greet() {
    final hour = DateTime.now().hour;
    String moment = hour < 12 ? 'Bonjour' : hour < 18 ? 'Bon après-midi' : 'Bonsoir';
    return '$moment $_prenom ! 😊\n\nJe suis votre assistant santé SANTEO. Je peux vous aider sur :\n\n💪 Les exercices et comment les faire\n🤕 Vos douleurs et comment les gérer\n🌊 Des conseils adaptés à $_territoire\n📈 Votre progression et motivation\n\nQue souhaitez-vous savoir ?';
  }

  String _whoAmI() {
    return 'Je suis l\'assistant IA de SANTEO Connect 🤖\n\nJe fonctionne **entièrement sur votre appareil**, sans connexion internet. Mes réponses sont basées sur des connaissances en kinésithérapie et santé fonctionnelle, adaptées au contexte des territoires insulaires du Pacifique.\n\n⚠️ Je ne remplace pas un médecin ou un kinésithérapeute. En cas de douleur importante, consultez un professionnel.\n\nComment puis-je vous aider aujourd\'hui ?';
  }

  String _explainChatVache() {
    return '🐱🐄 Le "Chat-Vache" — Explication simple !\n\nC\'est un exercice de mobilité du dos, très efficace et facile.\n\n**Comment faire :**\n\n1️⃣ Mettez-vous à quatre pattes\n   • Mains sous les épaules\n   • Genoux sous les hanches\n\n2️⃣ Le Chat 🐱\n   • Expirez doucement\n   • Arrondissez le dos vers le plafond\n   • Imaginez que votre nombril remonte vers le ciel\n   • La tête descend naturellement\n\n3️⃣ La Vache 🐄\n   • Inspirez doucement\n   • Creusez le dos vers le bas\n   • La tête remonte doucement\n   • Les fesses remontent légèrement\n\n4️⃣ Répétez 10 fois lentement, en suivant votre respiration\n\n🌊 **Astuce Pacifique :** Imaginez une vague de l\'océan qui monte et descend — c\'est exactement ce mouvement !\n\n✅ Parfait le matin au réveil, ça déverrouille toute la colonne vertébrale.';
  }

  String _explainGainage() {
    return '💪 Le Gainage Abdominal\n\n**Pourquoi c\'est important ?**\nLe gainage renforce le "corset naturel" de votre corps — les muscles profonds qui protègent votre dos.\n\n**Comment faire (version facile) :**\n\n1️⃣ Allongez-vous sur le ventre\n2️⃣ Appuyez-vous sur vos avant-bras\n3️⃣ Soulevez le corps — seuls les pieds et les avant-bras touchent le sol\n4️⃣ Gardez le corps bien droit comme une planche\n5️⃣ Contractez les abdos et respirez normalement\n6️⃣ Maintenez 20 secondes, récupérez 30 secondes\n7️⃣ Répétez 3 fois\n\n⏱️ **Progression :**\n• Semaine 1-2 : 20 secondes\n• Semaine 3-4 : 30 secondes\n• Semaine 5+ : 45 secondes\n\n🌡️ **Conseil tropical :** Faites-le sur un tapis ou une serviette à l\'ombre, jamais sur du carrelage chaud !';
  }

  String _explainSquats() {
    return '🦵 Les Squats — Sans matériel !\n\n**Comment bien faire :**\n\n1️⃣ Pieds écartés largeur d\'épaules\n2️⃣ Orteils légèrement tournés vers l\'extérieur\n3️⃣ Descendez lentement comme pour vous asseoir sur une chaise\n4️⃣ Genoux dans l\'axe des pieds (ne pas les laisser rentrer vers l\'intérieur)\n5️⃣ Dos droit, regardez devant vous\n6️⃣ Descendez jusqu\'à ce que les cuisses soient parallèles au sol\n7️⃣ Remontez en poussant sur les talons\n\n**Programme débutant :**\n• 3 séries de 10 répétitions\n• 1 minute de repos entre chaque série\n\n⚠️ **Évitez si :** Douleur au genou, opération récente du genou\n\n🌺 **Variante douce :** Squats contre un mur — placez votre dos contre le mur, descendez doucement. Parfait pour débuter !';
  }

  String _explainEtirements() {
    return '🧘 Les Étirements — Pourquoi et comment ?\n\n**Les règles d\'or :**\n\n✅ Jamais à froid — faites 5 min de marche avant\n✅ Maintenez chaque étirement 20-30 secondes\n✅ Respirez normalement, ne bloquez pas\n✅ Sensation de "tiraillement" = normal\n✅ Douleur aiguë = STOP immédiatement\n\n**Les étirements essentiels pour vous :**\n\n🔹 Dos : Chat-vache (10 répétitions)\n🔹 Nuque : Tête vers l\'épaule (20 sec chaque côté)\n🔹 Jambes : Assis, jambe tendue, penchez-vous en avant\n🔹 Hanches : Rotation debout (10 cercles chaque sens)\n\n⏰ **Quand s\'étirer ?**\nLe soir avant de dormir est idéal — ça détend le corps et améliore le sommeil.\n\n🌡️ **Avantage tropical :** La chaleur rend les muscles plus souples. Profitez-en en douceur !';
  }

  String _explainRespiration() {
    return '🌬️ La Respiration — Votre outil anti-stress gratuit !\n\n**La Cohérence Cardiaque (5 minutes suffisent) :**\n\n1️⃣ Asseyez-vous confortablement\n2️⃣ Inspirez par le nez : **4 secondes**\n3️⃣ Retenez : **4 secondes**\n4️⃣ Expirez par la bouche : **6 secondes**\n5️⃣ Répétez pendant 5 minutes\n\n**Les bienfaits immédiats :**\n• ❤️ Calme le rythme cardiaque\n• 🧠 Réduit le cortisol (hormone du stress)\n• 💤 Améliore la qualité du sommeil\n• 🤕 Diminue la perception de la douleur\n• ⚡ Augmente l\'énergie\n\n**Quand pratiquer ?**\n🌅 Le matin : pour bien démarrer la journée\n🌆 Avant une séance : pour mieux performer\n🌙 Le soir : pour s\'endormir facilement\n\n🌊 **Visualisation Pacifique :** Imaginez les vagues de l\'océan — inspirez quand la vague monte, expirez quand elle se retire.';
  }

  String _explainMobilite() {
    return '🔄 La Mobilité Articulaire — Indispensable !\n\nLa mobilité c\'est la capacité de vos articulations à bouger librement. Avec l\'âge ou la sédentarité, elle diminue.\n\n**Exercices de mobilité quotidiens (10 min) :**\n\n🔹 **Nuque** : Demi-cercles lents gauche-droite (10x)\n🔹 **Épaules** : Rotations avant et arrière (10x chaque)\n🔹 **Dos** : Chat-vache (10 répétitions)\n🔹 **Hanches** : Grands cercles debout (10x chaque sens)\n🔹 **Chevilles** : Rotations assis (10x chaque pied)\n\n**Quand faire de la mobilité ?**\n✅ Le matin au réveil : idéal, ça "lubrifie" les articulations\n✅ Avant le sport : obligatoire pour éviter les blessures\n✅ Après le travail : pour effacer les tensions de la journée\n\n⏱️ **10 minutes par jour** suffisent pour voir des résultats en 2-3 semaines !';
  }

  String _explainMarche() {
    return '🚶 La Marche Active — L\'exercice roi du Pacifique !\n\nPas besoin de salle de sport. La marche active est l\'exercice le plus complet et le plus accessible.\n\n**La différence avec une promenade :**\n• Rythme soutenu (vous devez pouvoir parler mais pas chanter)\n• Bras qui se balancent activement\n• Abdos légèrement contractés\n• Pas cadencés\n\n**Objectif progressif :**\n• Semaine 1-2 : 15 minutes/jour\n• Semaine 3-4 : 20-25 minutes/jour\n• Semaine 5+ : 30 minutes/jour\n\n🌞 **Timing parfait pour $_territoire :**\nMarchezavant 8h du matin ou après 17h pour éviter la chaleur. La lumière matinale du Pacifique est particulièrement bénéfique.\n\n🏖️ **Bonus :** Marchez pieds nus sur le sable — c\'est excellent pour renforcer les muscles des pieds et des chevilles !';
  }

  String _explainEpaules() {
    return '💪 Exercices pour les Épaules et Bras\n\n**Automassage rapide (2 min) :**\nMassez le trapèze (muscle entre cou et épaule) avec les doigts opposés. Faites de petits cercles pendant 1 minute de chaque côté.\n\n**Exercices de mobilité :**\n\n🔹 **Rotations d\'épaules :**\nBras le long du corps, faites de grands cercles vers l\'avant (10x) puis l\'arrière (10x)\n\n🔹 **Étirement pectoral :**\nBras en croix contre un mur, tournez doucement le corps à l\'opposé. Maintenez 20 secondes.\n\n🔹 **Renforcement simple :**\nBras tendus sur les côtés, petits cercles 30 secondes vers l\'avant, 30 secondes vers l\'arrière. 3 séries.\n\n⚠️ **Si vous avez mal à l\'épaule :**\nÉvitez de lever le bras au-dessus de la tête jusqu\'à amélioration. Consultez un kiné si la douleur dure plus de 2 semaines.';
  }

  String _explainDos() {
    return '🦴 Soulager et Renforcer le Dos\n\nLe dos est la zone la plus touchée dans les territoires insulaires (travail physique, position assise prolongée).\n\n**Les 3 exercices indispensables pour le dos :**\n\n1️⃣ **Chat-Vache** (10 répétitions)\nDéverrouille la colonne vertébrale\n\n2️⃣ **Gainage abdominal** (20-30 secondes)\nRenforce le "corset naturel" qui protège le dos\n\n3️⃣ **Étirement genoux-poitrine** :\nAllongé sur le dos, ramenez les deux genoux sur la poitrine, maintenez 30 secondes\n\n**Conseils de vie :**\n✅ Évitez de rester assis plus de 45 minutes d\'affilée\n✅ Levez-vous en roulant sur le côté, pas en vous redressant brusquement\n✅ En portant des charges, pliez les genoux, pas le dos\n\n⚠️ **Consultez un professionnel si :**\nDouleur qui irradie dans la jambe, fourmillements, perte de force.';
  }

  String _explainNuque() {
    return '🦒 Soulager la Nuque et les Cervicales\n\nLa nuque souffre souvent du téléphone et de l\'ordinateur.\n\n**Exercices de soulagement immédiat :**\n\n🔹 **Étirement latéral :**\nInclinez la tête vers l\'épaule droite, main gauche dans le dos. Maintenez 20 secondes. Changez de côté.\n\n🔹 **Rotation douce :**\nTournez la tête lentement vers la droite, maintenez 5 secondes, revenez au centre, tournez à gauche. 5x chaque côté.\n\n🔹 **Chin tuck (rentrer le menton) :**\nRentrez légèrement le menton comme pour faire un double menton. Maintenez 5 secondes. Répétez 10x. Corrige la posture de la tête.\n\n📱 **La règle du téléphone :**\nChaque 30 minutes, faites ces exercices 2 minutes. Votre nuque vous remerciera !\n\n🌡️ Une bouteille d\'eau froide posée sur la nuque après l\'effort soulage immédiatement.';
  }

  String _explainHanches() {
    return '🔄 Mobilité des Hanches\n\nLes hanches sont le centre de gravité du corps. Des hanches raides causent souvent des douleurs au dos et aux genoux.\n\n**Exercices essentiels :**\n\n🔹 **Cercles de hanches :**\nDebout, pieds écartés, mains sur les hanches. Faites de grands cercles (10x dans chaque sens). Mouvement ample et fluide.\n\n🔹 **Le "4" assis :**\nAssis, croisez la cheville droite sur le genou gauche. Penchez doucement le buste en avant. Maintenez 30 secondes. Changez.\n\n🔹 **Fente avant douce :**\nUn pied devant, l\'autre derrière. Descendez doucement le genou arrière vers le sol. Maintenez 20 secondes. Échange les côtés.\n\n⚠️ **Sciatique ?**\nSi vous avez des douleurs qui descendent dans la fesse et la jambe, évitez les étirements profonds. Consultez un kinésithérapeute.';
  }

  String _explainGenoux() {
    return '🦵 Prendre Soin de ses Genoux\n\nLes genoux supportent tout le poids du corps — ils méritent de l\'attention !\n\n**Exercices de renforcement doux :**\n\n🔹 **Extension assis :**\nAssis sur une chaise, tendez une jambe horizontalement, maintenez 5 secondes, redescendez. 3 séries de 15 par jambe.\n\n🔹 **Squats partiels :**\nDemi-squat seulement (descendre à 45°, pas jusqu\'au bout). Plus doux pour les genoux.\n\n🔹 **Renforcement des ischio-jambiers :**\nAllongé sur le ventre, pliez le genou en ramenant le talon vers les fesses. 3 séries de 15.\n\n**Ce qui aggrave les genoux :**\n❌ Rester assis jambes croisées longtemps\n❌ S\'accroupir brutalement\n❌ Escaliers en descente avec douleur\n\n✅ **Ce qui aide :**\nMarche sur terrain plat, natation, vélo sans résistance.';
  }

  String _explainChevilles() {
    return '🦶 Renforcer les Chevilles et Pieds\n\nDans les îles, les terrains irréguliers et les tongs exposent souvent aux entorses !\n\n**Exercices de prévention :**\n\n🔹 **Rotations de cheville :**\nAssis, soulevez le pied et faites de grands cercles avec la cheville (10x chaque sens, chaque pied).\n\n🔹 **Équilibre unipodal :**\nTenez-vous sur un pied 30 secondes, yeux ouverts. Puis fermés pour plus de difficulté. Alternez.\n\n🔹 **Mollets :**\nDebout, montez sur la pointe des pieds, redescendez lentement. 3 séries de 15. Renforce tout le pied.\n\n🏖️ **Exercice naturel Pacifique :**\nMarcher pieds nus sur le sable est l\'exercice le plus complet pour les pieds. 15 minutes sur la plage = meilleure séance de renforcement !';
  }

  String _handleDouleur(String msg) {
    return '🤕 Vous avez mal — voici comment réagir\n\nD\'abord, évaluez votre douleur de 1 à 10 :\n\n🟢 **1-3 : Légère**\nContinuez vos exercices en réduisant l\'intensité de 30%. La douleur légère pendant l\'exercice est souvent normale.\n\n🟡 **4-6 : Modérée**\nArrêtez l\'exercice qui cause la douleur. Faites uniquement des étirements doux et de la respiration. Si ça persiste 3 jours, consultez.\n\n🔴 **7-10 : Forte**\nArrêtez tout exercice. Repos et glace (15 min) sur la zone douloureuse. Consultez un professionnel de santé.\n\n⚠️ **Consultez immédiatement si :**\n• Douleur qui irradie dans un bras ou une jambe\n• Fourmillements ou engourdissement\n• Douleur thoracique\n• Après une chute ou un choc\n\nOù avez-vous mal exactement ? Je peux vous donner des conseils plus précis.';
  }

  String _urgenceDouleur() {
    return '🚨 Douleur intense — Action immédiate !\n\n**Arrêtez tous les exercices maintenant.**\n\n✅ Ce que vous pouvez faire :\n• Reposez-vous dans une position confortable\n• Appliquez de la glace 15 minutes (jamais directement sur la peau)\n• Respirez calmement\n\n🏥 **Consultez un professionnel de santé dès que possible :**\nKiné ou professionnel de santé de votre territoire.\n\n⚠️ SANTEO Connect est un outil de bien-être et de prévention. En cas de douleur intense, consultez un professionnel de santé.';
  }

  String _aboutProgram() {
    final objectifText = _objectif.isNotEmpty ? ' pour "$_objectif"' : '';
    return '🏃 Votre Programme Personnalisé$objectifText\n\nVotre programme dans l\'app est déjà adapté à votre profil ! Voici comment en tirer le maximum :\n\n**Principes de base :**\n\n1️⃣ **Progressivité** : Augmentez l\'intensité de 10% par semaine maximum\n2️⃣ **Régularité** : 3-4 séances régulières valent mieux que 1 séance intensive\n3️⃣ **Récupération** : Un jour de repos entre les séances intenses\n4️⃣ **Écoute** : Si une douleur apparaît, réduisez ou stoppez\n\n**Structure idéale d\'une séance :**\n• 5 min échauffement (marche légère, mobilité)\n• 15-20 min exercices principaux\n• 5 min étirements et respiration\n\nVous trouvez vos exercices dans l\'onglet **Exercices** de l\'app. Avez-vous des questions sur un exercice spécifique ?';
  }

  String _aboutFrequency() {
    return '📅 Quelle Fréquence d\'Entraînement ?\n\n**La règle d\'or : la régularité avant tout !**\n\n🔰 **Débutant** : 3 fois par semaine\nLundi - Mercredi - Vendredi (ou tout autre rythme avec des jours de repos entre)\n\n💪 **Intermédiaire** : 4-5 fois par semaine\nPossibilité de faire des séances plus courtes et ciblées\n\n🏆 **Avancé** : 5-6 fois par semaine\nAlternez groupes musculaires, 1 jour de repos obligatoire\n\n**Pour $_prenom, je recommande :**\n${_getFrequencyReco()}\n\n⚠️ **Important :** Même 10 minutes par jour tous les jours est MEILLEUR que 1h une fois par semaine. La régularité crée l\'habitude !';
  }

  String _getFrequencyReco() {
    if (userProfile == null) return '3 séances par semaine pour commencer, puis augmenter progressivement selon votre ressenti.';
    final level = userProfile!.niveauActivite;
    if (level.contains('Sédentaire')) return '3 séances de 15-20 minutes pour commencer. Augmentez à 4 séances après 3 semaines.';
    if (level.contains('Légèrement')) return '3-4 séances de 20-25 minutes. Vous pouvez progresser plus vite.';
    return '4-5 séances par semaine. Votre niveau vous permet un programme plus ambitieux.';
  }

  String _aboutDuration() {
    return '⏱️ Quelle Durée pour une Séance ?\n\n**La science dit :** 20 minutes d\'exercice régulier valent mieux que 1h occasionnelle !\n\n🟢 **10-15 minutes** (mini-séance)\nParfait pour les jours chargés. Focalisez sur mobilité + respiration.\n\n🔵 **20-25 minutes** (séance standard)\nL\'idéal pour la majorité. Échauffement + exercices + étirements.\n\n🟣 **30-45 minutes** (séance complète)\nPour les jours où vous avez plus d\'énergie. Peut inclure cardio.\n\n**Conseil pour $_territoire :**\n🌡️ Par forte chaleur, préférez 2 séances courtes (matin + soir) plutôt qu\'une longue séance dans la journée.\n\nVotre programme est paramétré sur ${userProfile?.dureeSeance ?? "20 minutes"} — parfait pour commencer !';
  }

  String _bestTime() {
    return '⏰ Quel est le Meilleur Moment pour s\'Exercer ?\n\n🌅 **Tôt le matin (6h-8h) — ⭐ RECOMMANDÉ pour le Pacifique**\n• Température fraîche et agréable\n• Corps reposé après la nuit\n• Donne de l\'énergie pour la journée\n• Belle lumière matinale\n\n🌆 **En soirée (17h-19h) — ✅ Bonne option**\n• Température qui redescend\n• Corps bien échauffé par la journée\n• Relâche le stress de la journée\n\n☀️ **Évitez 10h-15h**\nLa chaleur tropicale est trop intense et dangereuse pour l\'effort physique.\n\n🌙 **Le soir (après 20h)**\nBon pour les étirements et la respiration, mais évitez les efforts intenses qui peuvent perturber le sommeil.\n\n**Conseil personnalisé :** Le meilleur moment est celui que vous tiendrez dans la durée. Choisissez un créneau fixe et respectez-le !';
  }

  String _aboutHeat() {
    return '🌡️ S\'Entraîner par Chaleur Tropicale — Nos Conseils\n\nLe climat du Pacifique demande des précautions spéciales !\n\n**Les règles absolues :**\n\n⏰ **Horaires** : Avant 8h ou après 17h uniquement\n💧 **Hydratation** : 500ml d\'eau avant, pendant et après\n👕 **Vêtements** : Légers, clairs, respirants\n🌳 **Lieu** : À l\'ombre ou ventilé, jamais en plein soleil\n⏱️ **Durée** : Réduisez de 20-30% par forte chaleur\n\n**Signes d\'alerte — STOPPEZ si :**\n🔴 Vertiges ou maux de tête\n🔴 Nausées\n🔴 Transpiration excessive puis arrêt\n🔴 Confusion\n\nEn cas de coup de chaleur : ombre, eau fraîche sur la nuque et les poignets, reposez-vous.\n\n✅ La chaleur a aussi un avantage : vos muscles sont naturellement plus souples !';
  }

  String _aboutHydration() {
    return '💧 Hydratation — Essentielle sous le Soleil du Pacifique !\n\n**Objectif quotidien :**\n• 1.5 à 2 litres d\'eau par jour normalement\n• 2.5 à 3 litres les jours d\'exercice\n• Encore plus par forte chaleur\n\n**Avant la séance :**\nBuvez 500ml d\'eau fraîche 30 minutes avant\n\n**Pendant la séance :**\nPetites gorgées toutes les 15 minutes\n\n**Après la séance :**\nBuvez jusqu\'à ce que votre urine redevienne claire\n\n🍉 **Bonus Pacifique :**\nL\'eau de coco est naturellement riche en électrolytes — parfaite pour la récupération après l\'effort !\n\n🥭 Les fruits tropicaux (mangue, papaye, pastèque) sont aussi très hydratants.\n\n⚠️ **Signe de déshydratation :** Urine foncée, maux de tête, fatigue inhabituelle, crampes.';
  }

  String _motivation() {
    return '💙 Vous avez besoin de motivation — c\'est normal !\n\nTout le monde traverse des moments de découragement. Voici ce qui aide vraiment :\n\n**Petits pas = Grands résultats**\n\"Je vais faire 5 minutes\" — commencez petit, une fois lancé, vous continuerez souvent plus longtemps !\n\n**Rappel de votre "pourquoi" :**\n${_objectif.isNotEmpty ? 'Votre objectif était : "$_objectif". Pourquoi c\'était important pour vous ?' : 'Rappellez-vous pourquoi vous avez commencé. Cette raison est toujours là.'}\n\n**Ce qui fonctionne :**\n✅ Heure fixe chaque jour (comme une réunion)\n✅ Préparez votre tenue la veille\n✅ Trouvez un(e) ami(e) pour vous motiver mutuellement\n✅ Célébrez chaque petite victoire\n✅ Notez comment vous vous sentez APRÈS la séance\n\n🌊 **Sagesse du Pacifique :** \"Fa\'a Samoa\" — faire les choses à son propre rythme. Votre rythme est le bon rythme.\n\n💪 Vous avez déjà fait le plus difficile : vous êtes là !';
  }

  String _aboutSleep() {
    return '😴 Sommeil et Récupération\n\nLe sommeil est aussi important que l\'exercice pour votre santé !\n\n**Le sommeil aide à :**\n• Réparer les muscles après l\'effort\n• Consolider les nouvelles habitudes\n• Réguler les hormones (dont celles du stress)\n• Réduire la douleur\n\n**Pour mieux dormir :**\n🌙 Même heure de coucher tous les soirs\n📵 Pas d\'écran 30 min avant de dormir\n🌡️ Chambre fraîche (difficile sous les tropiques — un ventilateur aide)\n🧘 5 minutes de respiration avant de dormir\n\n**Exercice et sommeil :**\n✅ Exercice le matin ou l\'après-midi = meilleur sommeil\n⚠️ Exercice intense après 20h = peut perturber le sommeil\n\n**Si vous avez mal dormi :**\nFaites une séance plus légère (étirements, respiration) plutôt que de vous forcer sur des exercices intenses.';
  }

  String _aboutWeight() {
    return '⚖️ Exercice et Gestion du Poids\n\n**Ce que l\'exercice fait vraiment :**\n\n✅ Améliore le métabolisme\n✅ Renforce les muscles (les muscles brûlent plus de calories au repos)\n✅ Régule l\'appétit et les envies sucrées\n✅ Améliore l\'humeur (moins de manger émotionnel)\n\n**La réalité :**\nL\'alimentation représente 70% de la gestion du poids. L\'exercice seul ne suffit pas, mais il est indispensable.\n\n**Ce qui fonctionne vraiment :**\n🥗 Manger plus de légumes et fruits tropicaux locaux\n🚶 Marche active quotidienne (30 min)\n💧 Boire de l\'eau plutôt que des sodas\n😴 Bien dormir (le manque de sommeil fait grossir)\n🍽️ Manger lentement, écouter sa faim\n\n⚠️ **Je ne peux pas vous prescrire de régime** — consultez un médecin ou nutritionniste pour un suivi personnalisé.\n\nQue souhaitez-vous travailler en priorité ?';
  }

  String _aboutNewCaledonia() {
    return '🌊 SANTEO Connect en Nouvelle-Calédonie\n\n**Votre territoire, vos avantages :**\n\n🏖️ **Le lagon** — La meilleure salle de sport gratuite !\n• Natation : parfaite pour toutes les pathologies articulaires\n• Marche en eau : cardio sans impact sur les articulations\n• Sand walking sur le sable\n\n🌺 **Randonnée** — Les sentiers de NC sont exceptionnels\n• Mont Dore, La Foa, Bourail...\n• Cardio naturel et mental\n\n🌡️ **Climat** :\n• Saison fraîche (mai-sept) : idéale pour s\'exercer\n• Saison chaude (oct-avril) : matins avant 8h obligatoires\n\n🏥 **Kinésithérapeutes** :\nNouméa dispose de nombreux professionnels. En brousse ou dans les îles, SANTEO peut compléter le suivi à distance.\n\n🌿 **Culture Kanak** :\nLes activités traditionnelles (jardinage, pêche, danse kanak) sont d\'excellentes formes d\'activité physique !';
  }

  String _aboutPolynesie() {
    return '🌺 SANTEO Connect en Polynésie française\n\n**Votre territoire, vos ressources :**\n\n🛶 **Va\'a (pirogue) ** — Sport traditionnel extraordinaire !\nLe pagayage sollicite dos, épaules, abdos et cardio. C\'est l\'exercice fonctionnel idéal.\n\n🏔️ **Randonnée** — Tahiti, Moorea, Huahine...\nLes sentiers de montagne offrent un cardio exceptionnel et une connexion à la nature.\n\n🌊 **Surf et sports nautiques**\nExcellents pour l\'équilibre, la proprioception et le renforcement général.\n\n🌡️ **Conseil Polynésie** :\nL\'humidité est plus forte qu\'en Calédonie. Hydratation encore plus importante !\n\n🌺 **Tamure** — La danse traditionnelle polynésienne est un excellent exercice cardiovasculaire et de coordination !';
  }

  String _aboutWallis() {
    return '🌴 SANTEO Connect à Wallis-et-Futuna\n\n**Votre territoire, votre force :**\n\nWallis-et-Futuna a une particularité précieuse : le mode de vie traditionnel intègre naturellement l\'activité physique !\n\n🌱 **Jardinage traditionnel** :\nCreuser, planter, porter — c\'est du renforcement musculaire naturel et complet.\n\n🎣 **Pêche** :\nRamer, porter, se lever/s\'asseoir — excellente mobilité naturelle.\n\n💃 **Danses traditionnelles** :\nLes danses de Wallis et Futuna sollicitent tout le corps — c\'est du cardio et de la coordination !\n\n🏥 **Accès aux soins** :\nLes infrastructures médicales sont limitées. SANTEO Connect est particulièrement utile pour la prévention et le suivi autonome à domicile.\n\n🌡️ **Conseil** : La chaleur et l\'humidité sont élevées. Activités physiques tôt le matin uniquement.';
  }

  String _aboutPacific() {
    return '🌏 Exercer dans les Territoires du Pacifique\n\n**Les avantages uniques de votre environnement :**\n\n🌊 **L\'océan** — Votre meilleure salle de sport\nNatation, marche en eau, sports nautiques\n\n🏖️ **La plage** — Naturellement thérapeutique\nMarche sur sable = renforcement pied/cheville\nEau de mer = anti-inflammatoire naturel\n\n🌳 **La nature** — Randonnée, jardinage\nActivités fonctionnelles complètes\n\n☀️ **Le soleil** — Vitamine D naturelle\nEssentielle pour les muscles et les os\n\n**Les défis à surmonter :**\n🌡️ Chaleur et humidité → exercices tôt le matin\n🏋️ Manque d\'équipements → exercices au poids du corps\n🏝️ Isolement → programmes offline comme SANTEO\n\nVotre environnement naturel est votre plus grand atout santé. Utilisez-le ! 🌺';
  }

  String _aboutBilan() {
    return '📋 Votre Programme Personnalisé\n\nVotre bilan est généré localement sur votre appareil, basé sur vos réponses d\'évaluation.\n\n**Il comprend :**\n✅ Analyse de votre profil fonctionnel\n✅ Recommandations personnalisées\n✅ Programme d\'exercices suggéré\n✅ Conseils adaptés à votre territoire\n\n**Pour voir votre bilan :**\nAllez dans l\'onglet **Accueil** → carte "Mon Programme Personnalisé"\n\n**Pour refaire votre bilan :**\nAllez dans **Profil** → "Refaire mon évaluation"\n\n**Important :**\nPlus vos réponses d\'évaluation sont précises, plus votre bilan sera pertinent. N\'hésitez pas à le refaire si votre situation a changé.';
  }

  String _aboutProgress() {
    return '📈 Suivre sa Progression\n\n**Quand voir des résultats ?**\n\n🗓️ **Semaine 1-2** : Votre corps s\'adapte. Possible légère fatigue, c\'est normal.\n🗓️ **Semaine 3-4** : Premiers effets visibles — meilleure énergie, sommeil amélioré\n🗓️ **Mois 2** : Renforcement musculaire visible, mobilité améliorée\n🗓️ **Mois 3** : Changements durables installés\n\n**Comment mesurer vos progrès :**\n✅ Adhérence (% de séances faites) — visible dans l\'app\n✅ Niveau d\'énergie quotidien (notez /10)\n✅ Qualité du sommeil\n✅ Niveau de douleur (devrait diminuer)\n✅ Facilité à faire les exercices (ils deviennent plus faciles)\n\n**La vérité sur la progression :**\nLes progrès ne sont pas linéaires. Il y a des semaines difficiles — c\'est normal. Ce qui compte c\'est la tendance sur le long terme.\n\nVoulez-vous voir votre suivi ? Allez dans l\'onglet **Progression** de l\'app.';
  }

  String _aboutNutrition() {
    return '🥗 Alimentation et Santé dans le Pacifique\n\n⚠️ Je suis assistant en kinésithérapie, pas nutritionniste. Voici des conseils généraux :\n\n**Les aliments locaux sont vos meilleurs alliés :**\n\n🐟 **Poisson frais** — Protéines + oméga-3 anti-inflammatoires\n🥭 **Fruits tropicaux** — Vitamines, antioxydants, hydratation\n🌿 **Légumes locaux** — Fibres et minéraux\n🥥 **Eau de coco** — Électrolytes naturels post-effort\n🍠 **Igname, taro** — Énergie durable\n\n**À limiter pour la santé articulaire :**\n🔴 Sodas et boissons sucrées\n🔴 Aliments ultra-transformés\n🔴 Excès de sel (favorise l\'inflammation)\n\n**Timing nutrition et sport :**\n• Avant séance : léger, 1-2h avant\n• Après séance : protéines dans les 30 min\n• Évitez de faire du sport le ventre plein\n\nPour un suivi nutritionnel personnalisé, consultez un professionnel de santé.';
  }

  String _thanks() {
    return 'Avec plaisir $_prenom ! 😊\n\nC\'est pour ça que je suis là — pour vous accompagner dans votre parcours santé.\n\nN\'hésitez pas à me poser d\'autres questions sur :\n💪 Les exercices\n🤕 Les douleurs\n🌊 Votre territoire\n📈 Votre progression\n\nBonne séance ! 🌺';
  }

  String _goodbye() {
    return 'À bientôt $_prenom ! 🌊\n\nPrenez soin de vous. Chaque petite séance compte !\n\n🌺 Ia orana — Bonne santé en polynésien\n🌿 Kia ora — Bonne santé en maori\n💙 Prenez soin de votre corps, il est votre seul chez-vous permanent.';
  }

  String _help() {
    return '🆘 Comment puis-je vous aider ?\n\nVoici tout ce que je peux faire :\n\n**Exercices :**\n• "Comment faire le chat-vache ?"\n• "Explique-moi les squats"\n• "Exercices pour le dos"\n• "Comment faire du gainage ?"\n\n**Douleurs :**\n• "J\'ai mal au dos"\n• "Douleur à l\'épaule"\n• "J\'ai mal aux genoux"\n\n**Conseils pratiques :**\n• "Quand s\'entraîner ?"\n• "Combien de fois par semaine ?"\n• "Comment s\'entraîner par chaleur ?"\n\n**Motivation :**\n• "Je n\'ai pas envie"\n• "Comment rester motivé ?"\n\n**Territoire :**\n• "Conseils pour la Nouvelle-Calédonie"\n• "Exercices pour la Polynésie"\n\nPosez-moi votre question librement ! 😊';
  }

  String _defaultReply(String msg) {
    final suggestions = [
      'les exercices pour le dos',
      'comment bien s\'hydrater',
      'le meilleur moment pour s\'entraîner',
      'comment rester motivé',
    ];
    suggestions.shuffle();
    return 'Je n\'ai pas bien compris votre question 🤔\n\nJe suis spécialisé en santé fonctionnelle et exercices. Essayez de me demander par exemple :\n\n• "${suggestions[0]}"\n• "${suggestions[1]}"\n• "${suggestions[2]}"\n\nOu tapez **"aide"** pour voir tout ce que je peux faire ! 😊';
  }

  // ============================================================
  // UTILITAIRE
  // ============================================================
  bool _matches(String message, List<String> keywords) {
    return keywords.any((k) => message.contains(k));
  }
}
