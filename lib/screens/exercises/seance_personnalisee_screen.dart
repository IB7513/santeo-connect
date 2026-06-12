import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../core/constants/app_constants.dart';
import 'exercise_guided_screen.dart';

// ═══════════════════════════════════════════════════════════════════
//  SÉLECTION INTELLIGENTE depuis seedExercises
// ═══════════════════════════════════════════════════════════════════

List<Exercise> _selectionnerExos(UserProfile? profile, List<Exercise> allExos) {
  if (allExos.isEmpty) return [];
  if (profile == null) return allExos.take(10).toList();

  final zones = profile.zonesDouleur.map((z) => z.toLowerCase()).toList();
  final objectif = profile.objectifSante.toLowerCase();
  final niveau = profile.niveauActivite.toLowerCase();

  final scores = <Exercise, int>{};
  for (final exo in allExos) {
    int score = 0;
    final targetZone = exo.targetZone.toLowerCase();
    final type = exo.type.toLowerCase();

    for (final z in zones) {
      if (targetZone.contains(z) || z.contains(targetZone)) score += 3;
    }
    if (type.contains(objectif) || objectif.contains(type)) score += 2;
    final diff = exo.difficulty.toLowerCase();
    if (niveau.contains('débutant') || niveau.contains('sedentaire')) {
      if (diff.contains('débutant') || diff.contains('debutant')) score += 2;
    } else if (niveau.contains('actif') || niveau.contains('sportif')) {
      if (diff.contains('intermédiaire') || diff.contains('avancé')) score += 2;
    } else {
      score += 1;
    }
    scores[exo] = score;
  }

  final sorted = scores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sorted.take(10).map((e) => e.key).toList();
}

// ═══════════════════════════════════════════════════════════════════
//  ÉCRAN SÉANCE PERSONNALISÉE
// ═══════════════════════════════════════════════════════════════════
class SeancePersonnaliseeScreen extends StatefulWidget {
  const SeancePersonnaliseeScreen({super.key});

  @override
  State<SeancePersonnaliseeScreen> createState() =>
      _SeancePersonnaliseeScreenState();
}

class _SeancePersonnaliseeScreenState
    extends State<SeancePersonnaliseeScreen> {
  final Set<int> _exosTermines = {};

  /// Lance l'exercice à l'index [idx] dans ExerciseGuidedScreen.
  /// À la fin, enchaîne sur le suivant ou affiche le dialogue de fin.
  void _lancerExercice(
      BuildContext context, List<Exercise> exos, int idx, AppProvider provider) {
    if (idx >= exos.length) {
      _showSeanceComplete(context, provider, exos);
      return;
    }
    final exo = exos[idx];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseGuidedScreen(
          exerciseData: {
            'id': exo.id,
            'titre': exo.name,
            'titre_court': exo.name,
            'categorie': exo.type,
            'difficulte': exo.difficulty,
            'video_url': exo.videoUrl ?? '',
            'series': exo.series,
            'reps': exo.reps,
            'duree_serie_sec': exo.dureeSerieSec,
            'repos_sec': exo.reposSec,
            'type_comptage': exo.typeComptage,
            'zones': [exo.targetZone],
            'voix_intro': exo.voixIntro,
            'voix_pendant': exo.voixPendant,
            'voix_repos': exo.voixRepos,
            'voix_fin': exo.voixFin,
          },
          onCompleted: () {
            setState(() => _exosTermines.add(idx));
            // Enchaîner sur le suivant
            final nextIdx = idx + 1;
            if (nextIdx < exos.length) {
              _lancerExercice(context, exos, nextIdx, provider);
            } else {
              _showSeanceComplete(context, provider, exos);
            }
          },
        ),
      ),
    );
  }

  void _showSeanceComplete(
      BuildContext context, AppProvider provider, List<Exercise> exos) {
    // S'assurer qu'on est bien revenu à cet écran avant d'afficher le dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF26C6DA), Color(0xFF00838F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text('Séance terminée !',
                    style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(
                  'Vous avez réalisé ${exos.length} exercices.\nExcellent travail !',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF26C6DA),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text('Retour au tableau de bord',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, provider, _) {
      final profile = provider.userProfile;
      // Utiliser UNIQUEMENT les seedExercises — ils ont des vidéos et voix réelles
      // provider.exercises peut être pollué par des exercices IA sans vidéo
      final allExos = AppConstants.seedExercises;
      final exos = _selectionnerExos(profile, allExos);

      final rawPrenom = profile?.prenom ?? 'vous';
      final prenom = rawPrenom.isNotEmpty
          ? rawPrenom[0].toUpperCase() + rawPrenom.substring(1)
          : 'vous';

      return Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          backgroundColor: const Color(0xFF26C6DA),
          elevation: 0,
          title: Text(
            'Ma séance personnalisée',
            style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_exosTermines.length}/${exos.length}',
                  style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Barre de progression globale
            LinearProgressIndicator(
              value: exos.isEmpty ? 0 : _exosTermines.length / exos.length,
              backgroundColor: Colors.grey[200],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF26C6DA)),
              minHeight: 6,
            ),
            Expanded(
              child: _IntroSeance(
                prenom: prenom,
                profile: profile,
                exos: exos,
                exosTermines: _exosTermines,
                onCommencer: () =>
                    _lancerExercice(context, exos, 0, provider),
                onLancerExo: (idx) =>
                    _lancerExercice(context, exos, idx, provider),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════
//  INTRO + LISTE SÉANCE (vue unique)
// ═══════════════════════════════════════════════════════════════════
class _IntroSeance extends StatelessWidget {
  final String prenom;
  final UserProfile? profile;
  final List<Exercise> exos;
  final Set<int> exosTermines;
  final VoidCallback onCommencer;
  final void Function(int idx) onLancerExo;

  const _IntroSeance({
    required this.prenom,
    required this.profile,
    required this.exos,
    required this.exosTermines,
    required this.onCommencer,
    required this.onLancerExo,
  });

  @override
  Widget build(BuildContext context) {
    final zones = profile?.zonesDouleur ?? [];
    final nbRestants = exos.length - exosTermines.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Bannière personnalisée ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF26C6DA), Color(0xFF0097A7)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('👩‍⚕️', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Séance pour $prenom',
                          style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      const SizedBox(height: 6),
                      Text(
                        zones.isNotEmpty
                            ? 'Exercices adaptés à vos zones : ${zones.join(', ')}. Voix guidée et sous-titres inclus !'
                            : '${exos.length} exercices adaptés à votre profil avec voix guidée et sous-titres.',
                        style: GoogleFonts.roboto(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Badges info ──────────────────────────────────────────
          Row(children: [
            _StatBadge(emoji: '🎙️', label: 'Voix guidée', sublabel: 'fr-FR'),
            const SizedBox(width: 12),
            _StatBadge(
                emoji: '🏋️',
                label: '${exos.length}',
                sublabel: 'exercices'),
            const SizedBox(width: 12),
            _StatBadge(
                emoji: '📺',
                label: 'Vidéos',
                sublabel: 'Google Drive'),
          ]),
          const SizedBox(height: 20),

          // ── Bouton principal : lancer directement ───────────────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              icon: Icon(
                exosTermines.isEmpty
                    ? Icons.play_arrow_rounded
                    : Icons.replay_rounded,
                size: 26,
              ),
              label: Text(
                exosTermines.isEmpty
                    ? 'Commencer la séance avec voix & vidéo'
                    : 'Continuer ($nbRestants restants)',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
              onPressed: onCommencer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26C6DA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 3,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Indication voix ──────────────────────────────────────
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.record_voice_over_rounded,
                    size: 14, color: Color(0xFF26C6DA)),
                const SizedBox(width: 6),
                Text(
                  'Voix guidée et sous-titres activés automatiquement',
                  style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Liste des exercices ──────────────────────────────────
          Text('Vos exercices du jour',
              style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 12),

          ...exos.asMap().entries.map((e) {
            final idx = e.key;
            final exo = e.value;
            final done = exosTermines.contains(idx);
            return _ExoListTile(
              exo: exo,
              index: idx,
              isDone: done,
              onTap: () => onLancerExo(idx),
            );
          }),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TUILE EXERCICE (ligne cliquable)
// ═══════════════════════════════════════════════════════════════════
class _ExoListTile extends StatelessWidget {
  final Exercise exo;
  final int index;
  final bool isDone;
  final VoidCallback onTap;

  const _ExoListTile({
    required this.exo,
    required this.index,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDone
              ? const Color(0xFFE8F5E9)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone
                ? const Color(0xFF4CAF50)
                : Colors.grey.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Numéro / check
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDone
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                    : const Color(0xFF26C6DA).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check,
                        color: Color(0xFF4CAF50), size: 18)
                    : Text('${index + 1}',
                        style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF26C6DA))),
              ),
            ),
            const SizedBox(width: 12),

            // Nom + zone
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exo.name,
                      style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDone
                              ? const Color(0xFF388E3C)
                              : AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    '${exo.targetZone} • ${exo.difficulty}'
                    '${exo.voixIntro.isNotEmpty ? ' • 🎙️ Voix guidée' : ''}',
                    style: GoogleFonts.roboto(
                        fontSize: 11,
                        color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),

            // Icône lecture / fait
            if (isDone)
              const Icon(Icons.check_circle,
                  color: Color(0xFF4CAF50), size: 22)
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF26C6DA).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow_rounded,
                        size: 14, color: Color(0xFF26C6DA)),
                    const SizedBox(width: 3),
                    Text('Lancer',
                        style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF26C6DA))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  BADGE STAT
// ═══════════════════════════════════════════════════════════════════
class _StatBadge extends StatelessWidget {
  final String emoji;
  final String label;
  final String sublabel;
  const _StatBadge(
      {required this.emoji, required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)
          ],
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary),
              textAlign: TextAlign.center),
          Text(sublabel,
              style: GoogleFonts.roboto(
                  fontSize: 10, color: AppTheme.textSecondary),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
