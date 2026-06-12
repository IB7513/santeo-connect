// Models

// ====== Exercise Model ======
class Exercise {
  final String id;
  final String name;
  final String description;
  final int duration;
  final String difficulty;
  final String targetZone;
  final String type;
  final String? videoUrl;
  final String? thumbnailUrl;

  // Données de séance
  final int series;
  final int reps;
  final int dureeSerieSec;
  final int reposSec;
  final String typeComptage;

  // Voix TTS
  final String voixIntro;
  final String voixPendant;
  final String voixRepos;
  final String voixFin;

  final bool actif;
  final int ordre;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.targetZone,
    required this.type,
    this.videoUrl,
    this.thumbnailUrl,
    this.series = 3,
    this.reps = 10,
    this.dureeSerieSec = 0,
    this.reposSec = 30,
    this.typeComptage = 'reps',
    this.voixIntro = '',
    this.voixPendant = '',
    this.voixRepos = '',
    this.voixFin = '',
    this.actif = true,
    this.ordre = 0,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id']?.toString() ?? '',
      name: (map['titre'] ?? map['name'])?.toString() ?? '',
      description: (map['description_courte'] ?? map['description'])?.toString() ?? '',
      duration: (map['duration'] is int) ? map['duration'] as int
          : int.tryParse(map['duration']?.toString() ?? '0') ?? 0,
      difficulty: _mapDiff(map['difficulte']?.toString() ?? map['difficulty']?.toString()),
      targetZone: _firstZone(map['zones']) ?? map['targetZone']?.toString() ?? '',
      type: (map['categorie'] ?? map['type'])?.toString() ?? 'mobilite',
      videoUrl: (map['video_url'] ?? map['videoUrl'])?.toString(),
      thumbnailUrl: map['thumbnailUrl']?.toString(),
      series: (map['series'] as num?)?.toInt() ?? 3,
      reps: (map['reps'] as num?)?.toInt() ?? 10,
      dureeSerieSec: (map['duree_serie_sec'] as num?)?.toInt() ?? 0,
      reposSec: (map['repos_sec'] as num?)?.toInt() ?? 30,
      typeComptage: map['type_comptage']?.toString() ?? 'reps',
      voixIntro: map['voix_intro']?.toString() ?? '',
      voixPendant: map['voix_pendant']?.toString() ?? '',
      voixRepos: map['voix_repos']?.toString() ?? 'Soufflez. Récupérez quelques secondes.',
      voixFin: map['voix_fin']?.toString() ?? '',
      actif: (map['actif'] as bool?) ?? true,
      ordre: (map['ordre'] as num?)?.toInt() ?? 0,
    );
  }

  static String _mapDiff(String? v) {
    switch (v) {
      case 'intermediaire': return 'moyen';
      case 'avance': return 'difficile';
      case 'moyen': return 'moyen';
      case 'difficile': return 'difficile';
      default: return 'facile';
    }
  }

  static String? _firstZone(dynamic z) {
    if (z is List && z.isNotEmpty) return z.first?.toString();
    return null;
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'description': description,
    'duration': duration, 'difficulty': difficulty,
    'targetZone': targetZone, 'type': type,
    'videoUrl': videoUrl, 'series': series, 'reps': reps,
    'dureeSerieSec': dureeSerieSec, 'reposSec': reposSec,
    'typeComptage': typeComptage,
    'voix_intro': voixIntro, 'voix_pendant': voixPendant,
    'voix_repos': voixRepos, 'voix_fin': voixFin,
  };

  String get difficultyLabel {
    switch (difficulty) {
      case 'difficile': return 'Avancé';
      case 'moyen': return 'Intermédiaire';
      default: return 'Débutant';
    }
  }

  String get typeLabel {
    switch (type) {
      case 'renforcement': return 'Renforcement';
      case 'mobilite': return 'Mobilité';
      case 'etirement': return 'Étirement';
      case 'cardio': return 'Cardio';
      default: return 'Bien-être';
    }
  }

  int get dureeTotaleSecondes {
    if (typeComptage == 'duree') return series * dureeSerieSec + (series - 1) * reposSec;
    return series * (reps * 3) + (series - 1) * reposSec;
  }

  int get dureeTotaleMinutes => (dureeTotaleSecondes / 60).ceil();
}


// ====== User Profile Model ======
class UserProfile {
  final String userId;
  final String prenom;
  final String age;
  final String genre;
  final String localisation;
  final String objectifSante;
  final bool douleursActuelles;
  final List<String> zonesDouleur;
  final int niveauMobilite;
  final String niveauActivite;
  final List<String> problemesSante;
  final String chirurgies;
  final String traitements;
  final String dureeSeance;
  final String frequenceSemaine;
  final List<String> preferencesExercices;
  final DateTime? createdAt;

  const UserProfile({
    required this.userId,
    required this.prenom,
    required this.age,
    required this.genre,
    required this.localisation,
    required this.objectifSante,
    required this.douleursActuelles,
    required this.zonesDouleur,
    required this.niveauMobilite,
    required this.niveauActivite,
    required this.problemesSante,
    required this.chirurgies,
    required this.traitements,
    required this.dureeSeance,
    required this.frequenceSemaine,
    required this.preferencesExercices,
    this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId']?.toString() ?? '',
      prenom: map['prenom']?.toString() ?? '',
      age: map['age']?.toString() ?? '',
      genre: map['genre']?.toString() ?? '',
      localisation: map['localisation']?.toString() ?? '',
      objectifSante: map['objectifSante']?.toString() ?? '',
      douleursActuelles: map['douleursActuelles'] == true,
      zonesDouleur: List<String>.from(map['zonesDouleur'] as List? ?? []),
      niveauMobilite: (map['niveauMobilite'] as num?)?.toInt() ?? 3,
      niveauActivite: map['niveauActivite']?.toString() ?? '',
      problemesSante: List<String>.from(map['problemesSante'] as List? ?? []),
      chirurgies: map['chirurgies']?.toString() ?? '',
      traitements: map['traitements']?.toString() ?? '',
      dureeSeance: map['dureeSeance']?.toString() ?? '20 minutes',
      frequenceSemaine: map['frequenceSemaine']?.toString() ?? '3 jours/semaine',
      preferencesExercices:
          List<String>.from(map['preferencesExercices'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'prenom': prenom,
    'age': age,
    'genre': genre,
    'localisation': localisation,
    'objectifSante': objectifSante,
    'douleursActuelles': douleursActuelles,
    'zonesDouleur': zonesDouleur,
    'niveauMobilite': niveauMobilite,
    'niveauActivite': niveauActivite,
    'problemesSante': problemesSante,
    'chirurgies': chirurgies,
    'traitements': traitements,
    'dureeSeance': dureeSeance,
    'frequenceSemaine': frequenceSemaine,
    'preferencesExercices': preferencesExercices,
    'createdAt': createdAt?.toIso8601String(),
  };
}

// ====== Session Model ======
class WorkoutSession {
  final String id;
  final String userId;
  final DateTime date;
  final List<String> exercicesCompletes;
  final int dureeMinutes;
  final double niveauDouleur;

  const WorkoutSession({
    required this.id,
    required this.userId,
    required this.date,
    required this.exercicesCompletes,
    required this.dureeMinutes,
    required this.niveauDouleur,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'date': date.toIso8601String(),
    'exercicesCompletes': exercicesCompletes,
    'dureeMinutes': dureeMinutes,
    'niveauDouleur': niveauDouleur,
  };
}

// ====== Weekly Progress Model ======
class WeeklyProgress {
  final String userId;
  final DateTime weekStartDate;
  final double adherence;
  final int totalTime;
  final double avgPainLevel;
  final String? aiAnalysis;
  final String? aiRecommendations;

  const WeeklyProgress({
    required this.userId,
    required this.weekStartDate,
    required this.adherence,
    required this.totalTime,
    required this.avgPainLevel,
    this.aiAnalysis,
    this.aiRecommendations,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'weekStartDate': weekStartDate.toIso8601String(),
    'adherence': adherence,
    'totalTime': totalTime,
    'avgPainLevel': avgPainLevel,
    'aiAnalysis': aiAnalysis,
    'aiRecommendations': aiRecommendations,
  };
}
