// ignore_for_file: constant_identifier_names

import '../../models/app_models.dart';

class AppConstants {
  // App Info
  static const String appName = 'SANTEO Connect';
  static const String appTagline = 'Votre kiné en poche, votre santé en main.';
  static const String appVersion = '1.0.0';

  // OpenAI
  static const String openAIBaseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String openAIModel = 'gpt-4';

  // Disclaimer
  static const String disclaimer =
      'SANTEO Connect propose une approche de bien-être et de prévention complémentaire à votre parcours de santé. '
      'Cette plateforme ne remplace pas l\'avis d\'un professionnel de santé. '
      'En cas de douleur persistante ou aiguë, consultez un professionnel de santé.';

  // Territories
  static const List<String> territories = [
    'Nouvelle-Calédonie',
    'Polynésie française',
    'Wallis-et-Futuna',
    'Vanuatu',
    'Fidji',
    'Samoa',
    'Tonga',
    'Îles Cook',
    'Kiribati',
    'Autre territoire insulaire',
  ];

  // Health Goals
  static const List<String> healthGoals = [
    'Réduire les douleurs',
    'Améliorer ma mobilité',
    'Renforcer mes muscles',
    'Retrouver la forme',
    'Prévention et bien-être',
    'Récupération post-opératoire',
    'Gérer le stress',
  ];

  // Age Groups
  static const List<String> ageGroups = [
    '18-25 ans',
    '26-35 ans',
    '36-45 ans',
    '46-55 ans',
    '56-65 ans',
    '65+ ans',
  ];

  // Activity Levels
  static const List<String> activityLevels = [
    'Sédentaire (peu ou pas d\'exercice)',
    'Légèrement actif (1-2 jours/sem)',
    'Modérément actif (3-4 jours/sem)',
    'Très actif (5-6 jours/sem)',
    'Extrêmement actif (tous les jours)',
  ];

  // Pain Zones
  static const List<String> painZones = [
    'Cou / Nuque',
    'Épaules',
    'Bras / Coudes',
    'Mains / Poignets',
    'Haut du dos',
    'Bas du dos',
    'Hanches',
    'Genoux',
    'Chevilles / Pieds',
    'Abdominaux',
  ];

  // Health Problems
  static const List<String> healthProblems = [
    'Lombalgie chronique',
    'Arthrose',
    'Hernie discale',
    'Tendinite',
    'Hypertension',
    'Diabète',
    'Obésité',
    'Dépression / Anxiété',
    'Fibromyalgie',
    'Aucun problème particulier',
  ];

  // Exercise Preferences
  static const List<String> exercisePreferences = [
    'Étirements / Flexibilité',
    'Renforcement musculaire',
    'Mobilité articulaire',
    'Cardio léger',
    'Relaxation / Respiration',
    'Équilibre / Proprioception',
  ];

  // Session Durations
  static const List<String> sessionDurations = [
    '10 minutes',
    '20 minutes',
    '30 minutes',
  ];

  // Weekly Frequencies
  static const List<String> weeklyFrequencies = [
    '3 jours/semaine',
    '4 jours/semaine',
    '5 jours/semaine',
    '6 jours/semaine',
    '7 jours/semaine',
  ];

  // Difficulty Levels
  static const Map<String, String> difficultyLabels = {
    'facile': 'Facile',
    'moyen': 'Moyen',
    'difficile': 'Difficile',
  };

  // Exercise Types
  static const Map<String, String> exerciseTypeLabels = {
    'etirement': 'Étirement',
    'renforcement': 'Renforcement',
    'mobilite': 'Mobilité',
    'cardio': 'Cardio',
  };

  // ====== SEED EXERCISES (10) ======
  static final List<Exercise> seedExercises = [
    const Exercise(
      id: 'ex_001',
      name: 'Étirement du dos',
      description: 'Allongez-vous sur le dos, ramenez les genoux vers la poitrine. Maintenez 30 secondes. Relâchez doucement. Répétez 3 fois.',
      duration: 5,
      difficulty: 'facile',
      targetZone: 'Dos',
      type: 'etirement',
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    ),
    const Exercise(
      id: 'ex_002',
      name: 'Renforcement des épaules',
      description: 'Debout ou assis, levez les bras tendus latéralement à hauteur d\'épaules. Maintenez 3 secondes, redescendez. 3 séries de 10 répétitions.',
      duration: 10,
      difficulty: 'moyen',
      targetZone: 'Épaules',
      type: 'renforcement',
    ),
    const Exercise(
      id: 'ex_003',
      name: 'Mobilité des hanches',
      description: 'Debout, effectuez des cercles de hanches lents dans les deux sens. 10 cercles par direction. Mouvement fluide et contrôlé.',
      duration: 8,
      difficulty: 'facile',
      targetZone: 'Hanches',
      type: 'mobilite',
    ),
    const Exercise(
      id: 'ex_004',
      name: 'Gainage abdominal',
      description: 'Position planche sur les avant-bras. Corps droit comme une planche. Maintenez 30 secondes. Récupération 30 secondes. 3 répétitions.',
      duration: 7,
      difficulty: 'moyen',
      targetZone: 'Abdominaux',
      type: 'renforcement',
    ),
    const Exercise(
      id: 'ex_005',
      name: 'Étirement des jambes',
      description: 'Assis au sol, jambes tendues. Penchez-vous doucement vers l\'avant, mains vers les pieds. Maintenez 30 secondes. Remontez lentement.',
      duration: 6,
      difficulty: 'facile',
      targetZone: 'Jambes',
      type: 'etirement',
    ),
    const Exercise(
      id: 'ex_006',
      name: 'Marche active',
      description: 'Marchez à un rythme soutenu, bras qui se balancent. Idéal tôt le matin avant la chaleur. Adaptez à votre rythme en milieu tropical.',
      duration: 15,
      difficulty: 'facile',
      targetZone: 'Cardio général',
      type: 'cardio',
    ),
    const Exercise(
      id: 'ex_007',
      name: 'Squats',
      description: 'Pieds écartés largeur épaules. Descendez comme pour vous asseoir. Dos droit, genoux dans l\'axe des pieds. 3 séries de 12 répétitions.',
      duration: 12,
      difficulty: 'difficile',
      targetZone: 'Jambes / Fessiers',
      type: 'renforcement',
    ),
    const Exercise(
      id: 'ex_008',
      name: 'Étirement nuque',
      description: 'Assis ou debout. Inclinez lentement la tête vers l\'épaule droite. Maintenez 20 secondes. Répétez de l\'autre côté. 3 fois par côté.',
      duration: 5,
      difficulty: 'facile',
      targetZone: 'Cou / Nuque',
      type: 'etirement',
    ),
    const Exercise(
      id: 'ex_009',
      name: 'Mobilité dos',
      description: 'À quatre pattes, alternez dos rond (chat) et dos creux (vache). Mouvement lent et synchronisé avec la respiration. 10 répétitions.',
      duration: 10,
      difficulty: 'moyen',
      targetZone: 'Dos',
      type: 'mobilite',
    ),
    const Exercise(
      id: 'ex_010',
      name: 'Respiration relaxation',
      description: 'Allongé confortablement. Inspirez 4 secondes, retenez 4 secondes, expirez 6 secondes. Excellent pour le stress et la récupération.',
      duration: 8,
      difficulty: 'facile',
      targetZone: 'Bien-être général',
      type: 'mobilite',
    ),
  ];
}
