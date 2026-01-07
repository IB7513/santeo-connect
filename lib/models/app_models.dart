// Models

// ====== Exercise Model ======
class Exercise {
  final String id;
  final String name;
  final String description;
  final int duration; // minutes
  final String difficulty; // facile / moyen / difficile
  final String targetZone;
  final String type; // etirement / renforcement / mobilite / cardio
  final String? videoUrl;
  final String? thumbnailUrl;

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
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      duration: (map['duration'] is int)
          ? map['duration'] as int
          : int.tryParse(map['duration']?.toString() ?? '0') ?? 0,
      difficulty: map['difficulty']?.toString() ?? 'facile',
      targetZone: map['targetZone']?.toString() ?? map['target_zone']?.toString() ?? '',
      type: map['type']?.toString() ?? 'etirement',
      videoUrl: map['videoUrl']?.toString() ?? map['video_url']?.toString(),
      thumbnailUrl: map['thumbnailUrl']?.toString() ?? map['thumbnail_url']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'duration': duration,
    'difficulty': difficulty,
    'targetZone': targetZone,
    'type': type,
    'videoUrl': videoUrl,
    'thumbnailUrl': thumbnailUrl,
  };
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
