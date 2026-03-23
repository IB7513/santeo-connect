import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String _apiKey;
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  OpenAIService(this._apiKey);

  // =====================================================
  // 1. ÉVALUATION PERSONNALISÉE (generate_assessment)
  // =====================================================
  Future<String> generateAssessment({
    required String prenom,
    required String age,
    required String genre,
    required String localisation,
    required String objectifSante,
    required bool douleursOuiNon,
    required List<String> zonesDouleur,
    required int niveauMobilite,
    required String niveauActivite,
    required List<String> problemesSante,
    required String chirurgies,
    required String traitements,
    required String dureeSeance,
    required String frequenceSemaine,
    required List<String> preferencesExercices,
  }) async {
    final systemPrompt = '''Tu es un kinésithérapeute expert spécialisé dans la santé fonctionnelle des territoires insulaires du Pacifique. Tu dois générer un bilan personnalisé en français adapté au contexte culturel et géographique. 
Format: 
1. Analyse profil fonctionnel (2-3 phrases)
2. Recommandations personnalisées (3-4 points)
3. Programme exercices suggéré (5-7 exercices adaptés au contexte insulaire)

Ton professionnel, rassurant, culturellement sensible. IMPORTANT: Préciser "Approche de prévention fonctionnelle complémentaire aux parcours de soins."''';

    final userPrompt = '''Profil: $prenom, $age, $genre, $localisation.
Objectif: $objectifSante.
Douleurs actuelles: ${douleursOuiNon ? 'Oui' : 'Non'} - Localisation: ${zonesDouleur.join(', ')}.
Niveau mobilité: $niveauMobilite/5.
Niveau activité: $niveauActivite.
Antécédents: ${problemesSante.join(', ')}.
Chirurgies: $chirurgies.
Traitements: $traitements.
Préférences: $dureeSeance min, ${frequenceSemaine}x/semaine, Types exercices: ${preferencesExercices.join(', ')}.
Contexte territorial: $localisation.

Contexte: L'utilisateur vit en territoire du Pacifique. Adapte recommandations selon:
- Climat tropical (chaleur, humidité)
- Accès limité infrastructures sportives
- Culture insulaire Pacifique (rythme de vie, activités traditionnelles)
- Contraintes déplacements entre îles
- Pas de matériel fitness spécialisé disponible

Suggère exercices faisables à domicile sans équipement, adaptés aux conditions climatiques.''';

    return await _callOpenAI(systemPrompt, userPrompt);
  }

  // =====================================================
  // 2. PROGRAMME PERSONNALISÉ (generate_program)
  // =====================================================
  Future<String> generateProgram({
    required String prenom,
    required String objectif,
    required String localisation,
    required String dureeSeance,
    required List<String> preferences,
    required List<String> problemes,
  }) async {
    final systemPrompt = '''Génère un programme d'exercices de 7 jours adapté aux contraintes des territoires insulaires (pas de matériel spécialisé, exercices faisables chez soi, chaleur/humidité Pacifique). 
Liste 5-7 exercices avec: nom, description courte, durée en minutes (chiffre seul), niveau difficulté (facile/moyen/difficile), zone ciblée, type (renforcement/etirement/mobilite/cardio).
Format JSON uniquement, sans markdown, sans explication. Structure: {"exercises": [{"name": "...", "description": "...", "duration": 10, "difficulty": "facile", "targetZone": "...", "type": "etirement"}]}''';

    final userPrompt = '''Profil: $prenom, objectif: $objectif, territoire: $localisation.
Durée préférée: $dureeSeance.
Préférences: ${preferences.join(', ')}.
Problèmes de santé: ${problemes.join(', ')}.
Génère un programme adapté sans matériel, en climat tropical.''';

    return await _callOpenAI(systemPrompt, userPrompt, maxTokens: 1500);
  }

  // =====================================================
  // 3. ANALYSE PROGRESSION (analyze_progress)
  // =====================================================
  Future<String> analyzeProgress({
    required double adherence,
    required int tempsTotal,
    required double niveauDouleur,
    required String prenom,
  }) async {
    final systemPrompt = '''Tu es un coach de santé bienveillant. Analyse la progression de la semaine et génère des recommandations encourageantes pour la semaine prochaine (augmenter intensité? maintenir? réduire?). 
Format: 2-3 phrases d\'encouragement + 1-2 ajustements programme concrets. Ton chaleureux et motivant.''';

    final userPrompt = '''Analyse la progression de $prenom cette semaine.
Données: Adhérence ${adherence.toStringAsFixed(0)}%, Temps total $tempsTotal min, Niveau douleur ${niveauDouleur.toStringAsFixed(1)}/10.
Génère recommandations pour la semaine prochaine.''';

    return await _callOpenAI(systemPrompt, userPrompt, maxTokens: 400);
  }

  // =====================================================
  // 4. DÉTECTION ESCALADE (detect_escalation)
  // =====================================================
  Future<Map<String, String>> detectEscalation({
    required double douleur,
    required double adherence,
    required int dureeEnSemaines,
    required String prenom,
  }) async {
    final systemPrompt = '''Analyse ces indicateurs de santé et détermine si une escalade vers un professionnel est nécessaire.
Réponds UNIQUEMENT avec ce format JSON: {"status": "ESCALADE|ENCOURAGEMENT|CONTINUE", "message": "message personnalisé en français"}
- ESCALADE: si douleur critique ou absence de progrès nécessite consultation professionnelle
- ENCOURAGEMENT: si démotivation détectée, besoin de soutien moral
- CONTINUE: progression normale, continuer le programme''';

    final userPrompt = '''Indicateurs pour $prenom:
Douleur: ${douleur.toStringAsFixed(1)}/10
Adhérence: ${adherence.toStringAsFixed(0)}%
Durée du programme: $dureeEnSemaines semaines
Réponds en JSON uniquement.''';

    final response = await _callOpenAI(systemPrompt, userPrompt, maxTokens: 300);
    
    try {
      final cleanJson = response.replaceAll(RegExp(r'```json\n?|\n?```'), '').trim();
      final Map<String, dynamic> parsed = jsonDecode(cleanJson);
      return {
        'status': parsed['status']?.toString() ?? 'CONTINUE',
        'message': parsed['message']?.toString() ?? response,
      };
    } catch (_) {
      return {'status': 'CONTINUE', 'message': response};
    }
  }

  // =====================================================
  // APPEL API OPENAI (privé)
  // =====================================================
  Future<String> _callOpenAI(
    String systemPrompt,
    String userPrompt, {
    int maxTokens = 1000,
    double temperature = 0.7,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': temperature,
          'max_tokens': maxTokens,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'].toString().trim();
      } else if (response.statusCode == 401) {
        throw Exception('Clé API OpenAI invalide. Veuillez la configurer dans votre profil.');
      } else if (response.statusCode == 429) {
        throw Exception('Limite de requêtes OpenAI atteinte. Réessayez dans quelques instants.');
      } else {
        throw Exception('Erreur OpenAI (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OpenAI Error: $e');
      }
      rethrow;
    }
  }
}
