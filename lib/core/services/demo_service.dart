// Demo Service — données réalistes pour les 5 profils de démonstration
import '../../models/app_models.dart';
import '../constants/app_constants.dart';

class DemoProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String territory;
  final String roleLabel;
  final String condition;
  final int age;
  final String avatarInitials;
  final UserProfile profile;
  final String aiAssessment;
  final List<WorkoutSession> sessions;
  final String weeklyAnalysis;
  final List<Exercise> exercises;

  const DemoProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.territory,
    required this.roleLabel,
    required this.condition,
    required this.age,
    required this.avatarInitials,
    required this.profile,
    required this.aiAssessment,
    required this.sessions,
    required this.weeklyAnalysis,
    required this.exercises,
  });
}

class DemoService {
  static List<DemoProfile> getDemoProfiles() {
    final now = DateTime.now();

    // ──────────────── MARIE DUPONT (Patient - Lombalgie) ────────────────
    final marieSessions = [
      WorkoutSession(
        id: 'demo_s1',
        userId: 'demo_marie',
        date: now.subtract(const Duration(days: 1)),
        exercicesCompletes: ['ex_1', 'ex_3'],
        dureeMinutes: 25,
        niveauDouleur: 3.0,
      ),
      WorkoutSession(
        id: 'demo_s2',
        userId: 'demo_marie',
        date: now.subtract(const Duration(days: 3)),
        exercicesCompletes: ['ex_2', 'ex_5'],
        dureeMinutes: 30,
        niveauDouleur: 4.0,
      ),
      WorkoutSession(
        id: 'demo_s3',
        userId: 'demo_marie',
        date: now.subtract(const Duration(days: 5)),
        exercicesCompletes: ['ex_1'],
        dureeMinutes: 20,
        niveauDouleur: 5.0,
      ),
      WorkoutSession(
        id: 'demo_s4',
        userId: 'demo_marie',
        date: now.subtract(const Duration(days: 8)),
        exercicesCompletes: ['ex_3', 'ex_4'],
        dureeMinutes: 35,
        niveauDouleur: 4.0,
      ),
      WorkoutSession(
        id: 'demo_s5',
        userId: 'demo_marie',
        date: now.subtract(const Duration(days: 10)),
        exercicesCompletes: ['ex_2'],
        dureeMinutes: 20,
        niveauDouleur: 5.5,
      ),
    ];

    // ──────────────── JEAN TAOFIFENUA (Professionnel) ────────────────
    final jeanSessions = [
      WorkoutSession(
        id: 'demo_j1',
        userId: 'demo_jean',
        date: now.subtract(const Duration(days: 1)),
        exercicesCompletes: ['ex_2', 'ex_4', 'ex_6'],
        dureeMinutes: 45,
        niveauDouleur: 2.0,
      ),
      WorkoutSession(
        id: 'demo_j2',
        userId: 'demo_jean',
        date: now.subtract(const Duration(days: 2)),
        exercicesCompletes: ['ex_1', 'ex_3'],
        dureeMinutes: 40,
        niveauDouleur: 1.5,
      ),
      WorkoutSession(
        id: 'demo_j3',
        userId: 'demo_jean',
        date: now.subtract(const Duration(days: 4)),
        exercicesCompletes: ['ex_5', 'ex_7'],
        dureeMinutes: 50,
        niveauDouleur: 2.0,
      ),
      WorkoutSession(
        id: 'demo_j4',
        userId: 'demo_jean',
        date: now.subtract(const Duration(days: 5)),
        exercicesCompletes: ['ex_2', 'ex_8'],
        dureeMinutes: 35,
        niveauDouleur: 1.0,
      ),
      WorkoutSession(
        id: 'demo_j5',
        userId: 'demo_jean',
        date: now.subtract(const Duration(days: 7)),
        exercicesCompletes: ['ex_3', 'ex_6'],
        dureeMinutes: 55,
        niveauDouleur: 2.0,
      ),
    ];

    // ──────────────── SARAH TERIITEHAU (Admin) ────────────────
    final sarahSessions = [
      WorkoutSession(
        id: 'demo_sa1',
        userId: 'demo_sarah',
        date: now.subtract(const Duration(days: 1)),
        exercicesCompletes: ['ex_1', 'ex_2', 'ex_3'],
        dureeMinutes: 30,
        niveauDouleur: 1.0,
      ),
      WorkoutSession(
        id: 'demo_sa2',
        userId: 'demo_sarah',
        date: now.subtract(const Duration(days: 3)),
        exercicesCompletes: ['ex_4', 'ex_5'],
        dureeMinutes: 25,
        niveauDouleur: 2.0,
      ),
      WorkoutSession(
        id: 'demo_sa3',
        userId: 'demo_sarah',
        date: now.subtract(const Duration(days: 5)),
        exercicesCompletes: ['ex_6'],
        dureeMinutes: 20,
        niveauDouleur: 1.5,
      ),
      WorkoutSession(
        id: 'demo_sa4',
        userId: 'demo_sarah',
        date: now.subtract(const Duration(days: 9)),
        exercicesCompletes: ['ex_7', 'ex_8'],
        dureeMinutes: 40,
        niveauDouleur: 1.0,
      ),
    ];

    // ──────────────── LÉA FAARUIA (Jeune 16 ans) ────────────────
    final leaSessions = [
      WorkoutSession(
        id: 'demo_l1',
        userId: 'demo_lea',
        date: now.subtract(const Duration(days: 2)),
        exercicesCompletes: ['ex_9', 'ex_10'],
        dureeMinutes: 20,
        niveauDouleur: 1.0,
      ),
      WorkoutSession(
        id: 'demo_l2',
        userId: 'demo_lea',
        date: now.subtract(const Duration(days: 5)),
        exercicesCompletes: ['ex_1'],
        dureeMinutes: 15,
        niveauDouleur: 0.5,
      ),
    ];

    // ──────────────── PIERRE WALLES (Senior 68 ans) ────────────────
    final pierreSessions = [
      WorkoutSession(
        id: 'demo_p1',
        userId: 'demo_pierre',
        date: now.subtract(const Duration(days: 1)),
        exercicesCompletes: ['ex_1', 'ex_3'],
        dureeMinutes: 20,
        niveauDouleur: 4.0,
      ),
      WorkoutSession(
        id: 'demo_p2',
        userId: 'demo_pierre',
        date: now.subtract(const Duration(days: 4)),
        exercicesCompletes: ['ex_5'],
        dureeMinutes: 15,
        niveauDouleur: 5.0,
      ),
      WorkoutSession(
        id: 'demo_p3',
        userId: 'demo_pierre',
        date: now.subtract(const Duration(days: 8)),
        exercicesCompletes: ['ex_3'],
        dureeMinutes: 15,
        niveauDouleur: 4.5,
      ),
    ];

    return [
      // ────────────── MARIE DUPONT ──────────────
      DemoProfile(
        id: 'demo_marie',
        name: 'Marie Dupont',
        email: 'marie.dupont@demo.nc',
        role: 'patient',
        territory: 'Wallis-et-Futuna',
        roleLabel: 'Patiente',
        condition: 'Lombalgie chronique',
        age: 34,
        avatarInitials: 'MD',
        profile: UserProfile(
          userId: 'demo_marie',
          prenom: 'Marie',
          age: '34',
          genre: 'Féminin',
          localisation: 'Wallis-et-Futuna',
          objectifSante: 'Réduire les douleurs lombaires et reprendre une activité physique régulière',
          douleursActuelles: true,
          zonesDouleur: ['Bas du dos', 'Hanches'],
          niveauMobilite: 2,
          niveauActivite: 'Sédentaire',
          problemesSante: ['Lombalgie chronique', 'Légère sciatique'],
          chirurgies: 'Aucune',
          traitements: 'Ibuprofène occasionnel',
          dureeSeance: '20-30 minutes',
          frequenceSemaine: '3 jours/semaine',
          preferencesExercices: ['Étirement', 'Mobilité douce'],
          createdAt: DateTime(2024, 9, 1),
        ),
        aiAssessment: '''🌺 Bonjour Marie, voici votre bilan personnalisé SANTEO Connect.

ANALYSE DE VOTRE SITUATION :
À 34 ans, avec une lombalgie chronique et une légère sciatique, votre corps vous envoie des signaux importants. En tant que résidente de Wallis-et-Futuna, le mode de vie insulaire peut à la fois favoriser et contraindre vos activités physiques.

POINTS POSITIFS :
• Vous avez pris l'initiative de consulter — c'est la première étape vers la guérison
• Votre âge est favorable à une récupération complète
• Le climat tropical favorise les mouvements doux en extérieur

RECOMMANDATIONS PRIORITAIRES :
1. Démarrez par des étirements doux du bas du dos, 10 minutes matin et soir
2. La marche en bord de lagon est excellente pour votre condition
3. Évitez les positions assises prolongées — levez-vous toutes les 45 minutes
4. Renforcez progressivement les muscles abdominaux (gainage léger)

PROGRAMME SUGGÉRÉ (3 séances/semaine) :
Semaine 1-2 : Mobilité et étirements uniquement
Semaine 3-4 : Ajout de renforcement doux
Semaine 5+ : Programme complet adapté

⚠️ ATTENTION : Si la douleur dépasse 7/10, consultez un professionnel de santé disponible à Wallis.

Courage Marie ! Chaque petit pas compte vers une meilleure qualité de vie. 💪''',
        sessions: marieSessions,
        weeklyAnalysis: '''📊 ANALYSE HEBDOMADAIRE — Marie Dupont

Cette semaine, vous avez réalisé 3 séances sur 3 prévues. Félicitations pour cette régularité ! 

Évolution de la douleur : de 5,5/10 → 3/10 — une amélioration significative de 45% ! 
Temps total d'exercice : 75 minutes cette semaine.

RECOMMANDATIONS POUR LA SEMAINE PROCHAINE :
✅ Maintenez cette régularité, c'est la clé du succès
✅ Augmentez la durée de 5 minutes par séance
✅ Essayez les étirements en position couchée le matin
⚠️ Continuez à noter votre niveau de douleur après chaque séance

Vous êtes sur la bonne voie, Marie ! 🌟''',
        exercises: AppConstants.seedExercises.take(5).toList(),
      ),

      // ────────────── JEAN TAOFIFENUA ──────────────
      DemoProfile(
        id: 'demo_jean',
        name: 'Jean Taofifenua',
        email: 'jean.taofifenua@demo.nc',
        role: 'pro',
        territory: 'Nouvelle-Calédonie',
        roleLabel: 'Kinésithérapeute',
        condition: 'Prévention & Performance',
        age: 42,
        avatarInitials: 'JT',
        profile: UserProfile(
          userId: 'demo_jean',
          prenom: 'Jean',
          age: '42',
          genre: 'Masculin',
          localisation: 'Nouvelle-Calédonie',
          objectifSante: 'Maintenir la forme physique et prévenir les blessures professionnelles',
          douleursActuelles: false,
          zonesDouleur: [],
          niveauMobilite: 5,
          niveauActivite: 'Très actif',
          problemesSante: [],
          chirurgies: 'Aucune',
          traitements: 'Aucun',
          dureeSeance: '45-60 minutes',
          frequenceSemaine: '5 jours/semaine',
          preferencesExercices: ['Renforcement', 'Cardio', 'Mobilité'],
          createdAt: DateTime(2024, 8, 15),
        ),
        aiAssessment: '''💪 Bonjour Jean, voici votre bilan professionnel SANTEO Connect.

PROFIL ATHLÉTIQUE CONFIRMÉ :
À 42 ans, avec un niveau d'activité très élevé, vous êtes un excellent ambassadeur de la santé active en Nouvelle-Calédonie. Votre expérience de kinésithérapeute vous donne une compréhension précieuse de votre corps.

ANALYSE DE PERFORMANCE :
• Mobilité globale : Excellente (5/5)
• Endurance : Très bonne pour votre tranche d'âge
• Points d'attention : Prévention des blessures de sur-usage

PROGRAMME PERFORMANCE CALÉDONIE :
1. Séances de renforcement fonctionnel 3x/semaine
2. Cardio interval training en bord de mer (1x/semaine)
3. Stretching profond post-exercice (obligatoire à votre âge)
4. Yoga flow adapté — excellent pour la mobilité articulaire

CONSEILS SPÉCIFIQUES NOUVELLE-CALÉDONIE :
• Profitez des températures matinales (6h-8h) pour les séances intenses
• La natation en lagon est idéale pour la récupération active
• Adaptez l'intensité pendant la saison chaude (novembre-avril)

Continuez à être un modèle de santé active pour vos patients ! 🏄‍♂️''',
        sessions: jeanSessions,
        weeklyAnalysis: '''📊 ANALYSE HEBDOMADAIRE — Jean Taofifenua

Performance exceptionnelle cette semaine : 5 séances réalisées, 225 minutes d'exercice total.

Niveau de douleur moyen : 1.7/10 — excellent, vous gérez parfaitement la charge d'entraînement.

INSIGHTS PROFESSIONNELS :
✅ Votre récupération entre séances est optimale
✅ La progression des charges est cohérente
⚡ Suggestion : Intégrez une séance de mobilité pure pour optimiser les performances
🏆 Adhérence cette semaine : 100% — Bravo !

Vous êtes dans le top 5% des utilisateurs SANTEO. Continuez ! 🥇''',
        exercises: AppConstants.seedExercises,
      ),

      // ────────────── SARAH TERIITEHAU ──────────────
      DemoProfile(
        id: 'demo_sarah',
        name: 'Sarah Teriitehau',
        email: 'sarah.teriitehau@demo.pf',
        role: 'admin',
        territory: 'Polynésie Française',
        roleLabel: 'Administratrice',
        condition: 'Stress & Posture',
        age: 38,
        avatarInitials: 'ST',
        profile: UserProfile(
          userId: 'demo_sarah',
          prenom: 'Sarah',
          age: '38',
          genre: 'Féminin',
          localisation: 'Polynésie Française',
          objectifSante: 'Réduire le stress, améliorer la posture et la vitalité',
          douleursActuelles: true,
          zonesDouleur: ['Nuque', 'Épaules'],
          niveauMobilite: 3,
          niveauActivite: 'Légèrement actif',
          problemesSante: ['Tensions cervicales', 'Stress chronique'],
          chirurgies: 'Aucune',
          traitements: 'Magnésium, Relaxation',
          dureeSeance: '25-30 minutes',
          frequenceSemaine: '4 jours/semaine',
          preferencesExercices: ['Yoga', 'Étirement', 'Respiration'],
          createdAt: DateTime(2024, 10, 1),
        ),
        aiAssessment: '''🌺 Bonjour Sarah, voici votre bilan bien-être SANTEO Connect.

PORTRAIT DE VOTRE SANTÉ :
En Polynésie Française, la sagesse ancestrale dit "Ia ora na" — que la vie soit belle. Votre corps vous demande de ralentir et d'écouter ses signaux. Les tensions cervicales et le stress chronique sont des signaux importants.

ANALYSE POSTURALE :
• Tensions nuque/épaules : caractéristiques du travail administratif
• Stress chronique : impact direct sur les tensions musculaires
• Mobilité : bonne base pour progresser

VOTRE PROGRAMME TAHITI WELLNESS :
1. Réveil musculaire doux (10 min) : Cercles d'épaules, rotations cou
2. Yoga flow polynésien (20 min) : Inspiré des mouvements traditionnels
3. Techniques de respiration (5 min) : Méthode 4-7-8 pour le stress
4. Auto-massage cervical (5 min) : Points de pression traditionnels

RITUELS QUOTIDIENS :
🌅 Matin : 5 minutes d'étirements cervicaux
☀️ Pause déjeuner : Marche 15 minutes à l'ombre
🌙 Soir : Relaxation progressive avec musique polynésienne

Prenez soin de vous, Sarah — vous le méritez ! 💆‍♀️''',
        sessions: sarahSessions,
        weeklyAnalysis: '''📊 ANALYSE HEBDOMADAIRE — Sarah Teriitehau

Bonne semaine Sarah ! 4 séances complétées, 115 minutes d'activité physique.

Évolution des tensions : amélioration notable au niveau des épaules.
Stress perçu : légèrement en baisse après les séances de respiration.

RECOMMANDATIONS :
✅ Les exercices de respiration ont un impact positif — continuez !
✅ Votre régularité s'améliore semaine après semaine
💡 Conseil : Ajoutez des pauses micro-étirements au bureau (2 min toutes les heures)
🧘 Prochaine étape : Introduire la méditation de pleine conscience (5 min/jour)

Ia ora na, Sarah ! Votre parcours bien-être est en bonne voie 🌺''',
        exercises: AppConstants.seedExercises.take(6).toList(),
      ),

      // ────────────── LÉA FAARUIA ──────────────
      DemoProfile(
        id: 'demo_lea',
        name: 'Léa Faaruia',
        email: 'lea.faaruia@demo.pf',
        role: 'youth',
        territory: 'Polynésie Française',
        roleLabel: 'Adolescente',
        condition: 'Scoliose légère',
        age: 16,
        avatarInitials: 'LF',
        profile: UserProfile(
          userId: 'demo_lea',
          prenom: 'Léa',
          age: '16',
          genre: 'Féminin',
          localisation: 'Polynésie Française',
          objectifSante: 'Corriger la scoliose légère et renforcer le dos pour le sport scolaire',
          douleursActuelles: true,
          zonesDouleur: ['Dos (milieu)', 'Épaule droite'],
          niveauMobilite: 4,
          niveauActivite: 'Actif',
          problemesSante: ['Scoliose légère (12°)'],
          chirurgies: 'Aucune',
          traitements: 'Corset la nuit (prescrire)',
          dureeSeance: '20 minutes',
          frequenceSemaine: '3 jours/semaine',
          preferencesExercices: ['Natation', 'Étirement', 'Renforcement symétrique'],
          createdAt: DateTime(2024, 9, 15),
        ),
        aiAssessment: '''⭐ Bonjour Léa, voici ton bilan santé personnalisé SANTEO Connect !

TU ES AU BON ENDROIT :
À 16 ans, une scoliose légère de 12° est tout à fait gérable avec les bons exercices. Tu as pris la bonne décision de commencer tôt — c'est quand on est jeune qu'on obtient les meilleurs résultats !

TON PROGRAMME SPÉCIAL ADOS :
1. Natation — LE sport numéro 1 pour la scoliose ! Si tu habites en Polynésie, tu as une chance incroyable d'avoir le lagon à portée.
2. Renforcement symétrique : exercices qui travaillent les deux côtés du dos de façon équilibrée
3. Étirements de la chaîne postérieure : 10 min matin + soir

EXERCICES PRIORITAIRES :
• Chat-vache (mobilité vertébrale) : 2 séries de 10 rép.
• Gainage latéral symétrique : 3 x 20 secondes chaque côté
• Étirement du pigeon (ouverture hanches) : 30 sec x 2

POUR LE SPORT SCOLAIRE :
✅ Natation : Autorisé et recommandé
✅ Volley-ball : Avec précautions
⚠️ Évite les sauts répétitifs et la charge axiale lourde

Tu peux vivre normalement avec ta scoliose si tu fais tes exercices ! 💪 Allez Léa !''',
        sessions: leaSessions,
        weeklyAnalysis: '''📊 ANALYSE HEBDOMADAIRE — Léa Faaruia

Super Léa ! Tu as fait 2 séances cette semaine. C'est bien, mais on peut faire encore mieux !

Douleur moyenne : 0.75/10 — quasiment aucune douleur, c'est excellent !
Temps d'exercice : 35 minutes au total.

POUR LA SEMAINE PROCHAINE :
🌊 Essaie d'ajouter une séance de natation en plus
✅ Continue les étirements du matin — ils aident vraiment !
📱 Mets un rappel sur ton téléphone pour tes séances
🎯 Objectif : 3 séances cette semaine

Tu fais du super travail pour ton dos ! Continue comme ça ⭐''',
        exercises: AppConstants.seedExercises.take(4).toList(),
      ),

      // ────────────── PIERRE WALLES ──────────────
      DemoProfile(
        id: 'demo_pierre',
        name: 'Pierre Walles',
        email: 'pierre.walles@demo.wf',
        role: 'senior',
        territory: 'Wallis-et-Futuna',
        roleLabel: 'Senior',
        condition: 'Arthrose genou + Équilibre',
        age: 68,
        avatarInitials: 'PW',
        profile: UserProfile(
          userId: 'demo_pierre',
          prenom: 'Pierre',
          age: '68',
          genre: 'Masculin',
          localisation: 'Wallis-et-Futuna',
          objectifSante: 'Maintenir l\'autonomie, réduire les douleurs articulaires et prévenir les chutes',
          douleursActuelles: true,
          zonesDouleur: ['Genou droit', 'Cheville gauche'],
          niveauMobilite: 2,
          niveauActivite: 'Légèrement actif',
          problemesSante: ['Gonarthrose droite (grade 2)', 'Hypertension traitée'],
          chirurgies: 'PTH gauche (2019)',
          traitements: 'Amlodipine, Glucosamine',
          dureeSeance: '15-20 minutes',
          frequenceSemaine: '2 jours/semaine',
          preferencesExercices: ['Marche douce', 'Mobilité douce', 'Équilibre'],
          createdAt: DateTime(2024, 7, 1),
        ),
        aiAssessment: '''🌴 Bonjour Pierre, voici votre bilan senior adapté SANTEO Connect.

BILAN ADAPTÉ À VOTRE PROFIL :
À 68 ans, avec une gonarthrose droite grade 2 et une prothèse de hanche gauche posée en 2019, chaque exercice doit être choisi avec soin. Mais ne vous inquiétez pas : il existe énormément d'exercices bénéfiques et sans risque pour vous !

L'ESSENTIEL : MAINTENIR L'AUTONOMIE
• Prévention des chutes : priorité numéro 1
• Entretien de la musculature protectrice du genou
• Mobilité articulaire pour conserver l'indépendance

VOTRE PROGRAMME DOUX PACIFIQUE :
1. Marche aquatique ou en bord de mer (20 min/jour si possible)
2. Renforcement quadriceps en position assise (10 rép x 2)
3. Exercices d'équilibre debout (appui unipodal 10 sec)
4. Mobilisation douce genou en décubitus

PRÉCAUTIONS IMPORTANTES :
⚠️ Jamais de flexion complète du genou droit
⚠️ Évitez les surfaces irrégulières sans aide
✅ Chaussures à semelles antidérapantes recommandées
✅ Canne en cas de longues marches

ENCOURAGEMENT :
Votre engagement est admirable, Pierre. À Wallis-et-Futuna, la tradition du "fa'a Uvea" valorise la sagesse et la persévérance. Vous en êtes le bel exemple ! 🌺''',
        sessions: pierreSessions,
        weeklyAnalysis: '''📊 ANALYSE HEBDOMADAIRE — Pierre Walles

Bravo Pierre ! Vous avez réalisé 1 séance sur 2 prévues cette semaine.

Douleur moyenne : 4.5/10 — légèrement élevée. Continuons à travailler sur cela.
Temps d'exercice : 20 minutes.

ANALYSE SENIOR :
⚠️ Le niveau de douleur est à surveiller — restez dans vos limites
✅ Votre régularité est remarquable pour votre condition
💡 Conseil : Appliquez de la chaleur locale 10 min avant vos exercices
🚶 Objectif semaine prochaine : 2 séances + marche quotidienne de 10 min

Votre santé, c'est votre plus grand trésor, Pierre. Continuez doucement mais sûrement ! 💪''',
        exercises: AppConstants.seedExercises.take(3).toList(),
      ),
    ];
  }
}
