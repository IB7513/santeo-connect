// models/exercise.dart — Modèle catalogue exercices SANTEO Connect
// Catalogue ouvert et extensible via Firestore

import 'package:cloud_firestore/cloud_firestore.dart';

/// Niveau de difficulté d'un exercice
enum ExerciseDifficulty { debutant, intermediaire, avance }

/// Catégorie d'exercice
enum ExerciseCategory {
  cardio,
  musculaire,
  mobilite,
  respiration,
  relaxation,
  equilibre,
  posture,
}

/// Profil utilisateur ciblé (multi-sélection possible)
enum ExerciseTarget {
  tous,
  sedentaire,
  actif,
  senior,
  grossesse,
  malDeDos,
  stress,
}

class Exercise {
  final String id;
  final String titre;
  final String description;
  final String instructionsBreves;    // 1-2 phrases affichées sur la card
  final List<String> etapes;          // Étapes détaillées
  final ExerciseDifficulty difficulte;
  final ExerciseCategory categorie;
  final List<ExerciseTarget> cibles;  // Profils ciblés
  final int dureeMinutes;             // Durée estimée
  final int calories;                 // Calories approximatives
  final String? imageUrl;             // Illustration (optionnelle)
  final String? videoUrl;             // Vidéo démo (optionnelle)
  final List<String> tags;            // Tags libres pour filtrage
  final bool actif;                   // Visible dans le catalogue
  final DateTime createdAt;

  Exercise({
    required this.id,
    required this.titre,
    required this.description,
    required this.instructionsBreves,
    required this.etapes,
    required this.difficulte,
    required this.categorie,
    required this.cibles,
    required this.dureeMinutes,
    required this.calories,
    this.imageUrl,
    this.videoUrl,
    this.tags = const [],
    this.actif = true,
    required this.createdAt,
  });

  // ── Firestore → Dart ──────────────────────────────────────────────────────
  factory Exercise.fromFirestore(Map<String, dynamic> data, String docId) {
    return Exercise(
      id: docId,
      titre: (data['titre'] as String?) ?? 'Exercice',
      description: (data['description'] as String?) ?? '',
      instructionsBreves: (data['instructions_breves'] as String?) ?? '',
      etapes: List<String>.from(data['etapes'] as List? ?? []),
      difficulte: _parseDifficulte(data['difficulte'] as String?),
      categorie: _parseCategorie(data['categorie'] as String?),
      cibles: _parseCibles(data['cibles'] as List?),
      dureeMinutes: (data['duree_minutes'] as num?)?.toInt() ?? 10,
      calories: (data['calories'] as num?)?.toInt() ?? 50,
      imageUrl: data['image_url'] as String?,
      videoUrl: data['video_url'] as String?,
      tags: List<String>.from(data['tags'] as List? ?? []),
      actif: (data['actif'] as bool?) ?? true,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ── Dart → Firestore ──────────────────────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'titre': titre,
      'description': description,
      'instructions_breves': instructionsBreves,
      'etapes': etapes,
      'difficulte': difficulte.name,
      'categorie': categorie.name,
      'cibles': cibles.map((c) => c.name).toList(),
      'duree_minutes': dureeMinutes,
      'calories': calories,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'tags': tags,
      'actif': actif,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  // ── Helpers de parsing ────────────────────────────────────────────────────
  static ExerciseDifficulty _parseDifficulte(String? val) {
    switch (val) {
      case 'intermediaire': return ExerciseDifficulty.intermediaire;
      case 'avance':        return ExerciseDifficulty.avance;
      default:              return ExerciseDifficulty.debutant;
    }
  }

  static ExerciseCategory _parseCategorie(String? val) {
    switch (val) {
      case 'musculaire':  return ExerciseCategory.musculaire;
      case 'mobilite':    return ExerciseCategory.mobilite;
      case 'respiration': return ExerciseCategory.respiration;
      case 'relaxation':  return ExerciseCategory.relaxation;
      case 'equilibre':   return ExerciseCategory.equilibre;
      case 'posture':     return ExerciseCategory.posture;
      default:            return ExerciseCategory.cardio;
    }
  }

  static List<ExerciseTarget> _parseCibles(List? val) {
    if (val == null || val.isEmpty) return [ExerciseTarget.tous];
    return val.map((e) {
      switch (e as String) {
        case 'sedentaire':  return ExerciseTarget.sedentaire;
        case 'actif':       return ExerciseTarget.actif;
        case 'senior':      return ExerciseTarget.senior;
        case 'grossesse':   return ExerciseTarget.grossesse;
        case 'mal_de_dos':  return ExerciseTarget.malDeDos;
        case 'stress':      return ExerciseTarget.stress;
        default:            return ExerciseTarget.tous;
      }
    }).toList();
  }

  // ── Affichage ─────────────────────────────────────────────────────────────
  String get difficulteLabel {
    switch (difficulte) {
      case ExerciseDifficulty.debutant:      return 'Débutant';
      case ExerciseDifficulty.intermediaire: return 'Intermédiaire';
      case ExerciseDifficulty.avance:        return 'Avancé';
    }
  }

  String get categorieLabel {
    switch (categorie) {
      case ExerciseCategory.cardio:       return 'Cardio';
      case ExerciseCategory.musculaire:   return 'Musculaire';
      case ExerciseCategory.mobilite:     return 'Mobilité';
      case ExerciseCategory.respiration:  return 'Respiration';
      case ExerciseCategory.relaxation:   return 'Relaxation';
      case ExerciseCategory.equilibre:    return 'Équilibre';
      case ExerciseCategory.posture:      return 'Posture';
    }
  }
}
