import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';

// ═══════════════════════════════════════════════════
//  DONNÉES EXERCICES PAR ZONE / OBJECTIF
// ═══════════════════════════════════════════════════
class _ExoData {
  final String nom;
  final String zone;
  final String niveau;
  final String duree;
  final String description;
  final List<String> etapes;
  final String emoji;
  final List<String> zones;
  final List<String> objectifs;

  const _ExoData({
    required this.nom,
    required this.zone,
    required this.niveau,
    required this.duree,
    required this.description,
    required this.etapes,
    required this.emoji,
    required this.zones,
    required this.objectifs,
  });
}

const List<_ExoData> _tousLesExos = [
  _ExoData(
    nom: 'Baby Stretch',
    zone: 'Dos complet',
    niveau: 'Débutant',
    duree: '2 min',
    emoji: '🌱',
    description: 'Étirement doux de toute la colonne vertébrale.',
    etapes: ['Allongez-vous sur le dos', 'Ramenez les genoux sur la poitrine', 'Tenez 30 secondes', 'Relâchez doucement', 'Répétez 5 fois'],
    zones: ['dos', 'lombaires', 'colonne'],
    objectifs: ['mobilite', 'douleur', 'souplesse'],
  ),
  _ExoData(
    nom: 'Chat-Vache',
    zone: 'Colonne vertébrale',
    niveau: 'Débutant',
    duree: '3 min',
    emoji: '🐱',
    description: 'Mobilisation douce de la colonne en flexion/extension.',
    etapes: ['À 4 pattes, dos plat', 'Expirez et arrondissez le dos (chat)', 'Inspirez et creusez le dos (vache)', 'Mouvements lents et fluides', 'Répétez 10 fois'],
    zones: ['dos', 'lombaires', 'cervicales'],
    objectifs: ['mobilite', 'douleur', 'souplesse'],
  ),
  _ExoData(
    nom: 'Étirement cervical latéral',
    zone: 'Cou et nuque',
    niveau: 'Débutant',
    duree: '2 min',
    emoji: '🤸',
    description: 'Relâche les tensions du cou et des épaules.',
    etapes: ['Assis ou debout, dos droit', 'Inclinez la tête vers l\'épaule droite', 'Maintenez 20 secondes', 'Retournez au centre', 'Répétez à gauche — 3 fois chaque côté'],
    zones: ['cervicales', 'cou', 'nuque', 'epaules'],
    objectifs: ['douleur', 'souplesse', 'mobilite'],
  ),
  _ExoData(
    nom: 'Gainage abdominal',
    zone: 'Abdominaux / Dos',
    niveau: 'Intermédiaire',
    duree: '3 min',
    emoji: '💪',
    description: 'Renforce la sangle abdominale pour protéger le dos.',
    etapes: ['Allongé sur le ventre, appuis sur les coudes', 'Soulevez le bassin pour former une ligne droite', 'Contractez abdos et fessiers', 'Tenez 20-30 secondes', 'Répétez 5 fois'],
    zones: ['dos', 'lombaires', 'abdominaux'],
    objectifs: ['renforcement', 'prevention', 'stabilite'],
  ),
  _ExoData(
    nom: 'Pont fessier',
    zone: 'Fessiers / Lombaires',
    niveau: 'Débutant',
    duree: '3 min',
    emoji: '🌉',
    description: 'Renforce les fessiers et soulage les lombaires.',
    etapes: ['Allongé sur le dos, genoux fléchis', 'Pieds à plat sur le sol', 'Poussez sur les pieds et soulevez les hanches', 'Contractez les fessiers en haut', 'Tenez 5 sec, redescendez — 15 répétitions'],
    zones: ['dos', 'lombaires', 'fessiers', 'hanches'],
    objectifs: ['renforcement', 'douleur', 'stabilite'],
  ),
  _ExoData(
    nom: 'Rotation thoracique',
    zone: 'Thorax / Dos',
    niveau: 'Débutant',
    duree: '2 min',
    emoji: '🔄',
    description: 'Améliore la mobilité du haut du dos.',
    etapes: ['Assis sur une chaise, bras croisés', 'Tournez lentement le buste à droite', 'Maintenez 10 secondes', 'Revenez au centre', 'Alternez droite-gauche — 8 fois'],
    zones: ['dos', 'thorax', 'epaules'],
    objectifs: ['mobilite', 'souplesse', 'douleur'],
  ),
  _ExoData(
    nom: 'Squat partiel',
    zone: 'Genoux / Cuisses',
    niveau: 'Intermédiaire',
    duree: '4 min',
    emoji: '🦵',
    description: 'Renforce les quadriceps pour protéger les genoux.',
    etapes: ['Debout, pieds écartés largeur épaules', 'Fléchissez les genoux à 45°', 'Dos droit, regardez devant', 'Remontez en poussant sur les talons', 'Répétez 15 fois'],
    zones: ['genoux', 'cuisses', 'jambes'],
    objectifs: ['renforcement', 'arthrose', 'stabilite'],
  ),
  _ExoData(
    nom: 'Étirement du piriforme',
    zone: 'Fessier / Sciatique',
    niveau: 'Débutant',
    duree: '3 min',
    emoji: '⚡',
    description: 'Soulage la sciatique et les tensions du fessier.',
    etapes: ['Allongé sur le dos', 'Croisez la cheville droite sur le genou gauche', 'Soulevez la jambe gauche vers vous', 'Sentez l\'étirement dans la fesse droite', 'Tenez 30 sec — répétez 3 fois'],
    zones: ['fessiers', 'sciatique', 'hanches'],
    objectifs: ['douleur', 'sciatique', 'souplesse'],
  ),
  _ExoData(
    nom: 'Renforcement épaules',
    zone: 'Épaules / Bras',
    niveau: 'Intermédiaire',
    duree: '4 min',
    emoji: '🏋️',
    description: 'Renforce la coiffe des rotateurs pour l\'épaule.',
    etapes: ['Debout, bras le long du corps', 'Montez les bras à l\'horizontale', 'Tournez les pouces vers le bas', 'Revenez lentement', 'Répétez 12 fois'],
    zones: ['epaules', 'bras', 'nuque'],
    objectifs: ['renforcement', 'tendinite', 'stabilite'],
  ),
  _ExoData(
    nom: 'Marche sur place',
    zone: 'Corps entier',
    niveau: 'Débutant',
    duree: '5 min',
    emoji: '🚶',
    description: 'Réchauffement doux pour activer la circulation.',
    etapes: ['Debout, espace libre autour de vous', 'Levez alternativement les genoux', 'Balancez les bras naturellement', 'Respirez profondément', 'Continuez 5 minutes à rythme confortable'],
    zones: ['tout', 'jambes', 'cardiovasculaire'],
    objectifs: ['cardio', 'hypertension', 'mobilite', 'prevention'],
  ),
  _ExoData(
    nom: 'Respiration abdominale',
    zone: 'Abdomen / Stress',
    niveau: 'Débutant',
    duree: '3 min',
    emoji: '🧘',
    description: 'Réduit le stress et améliore la gestion de la douleur.',
    etapes: ['Allongé ou assis confortablement', 'Posez une main sur le ventre', 'Inspirez par le nez en gonflant le ventre', 'Expirez lentement par la bouche', 'Répétez 10 cycles'],
    zones: ['tout', 'stress', 'douleur'],
    objectifs: ['relaxation', 'douleur', 'stress', 'prevention'],
  ),
  _ExoData(
    nom: 'Flexion latérale du tronc',
    zone: 'Flancs / Dos',
    niveau: 'Débutant',
    duree: '2 min',
    emoji: '🌿',
    description: 'Étire les muscles latéraux du tronc.',
    etapes: ['Debout, pieds écartés', 'Bras droit levé au plafond', 'Penchez-vous lentement à gauche', 'Tenez 20 secondes', 'Alternez 5 fois chaque côté'],
    zones: ['dos', 'flancs', 'lombaires'],
    objectifs: ['souplesse', 'mobilite', 'douleur'],
  ),
  _ExoData(
    nom: 'Relevé de mollets',
    zone: 'Mollets / Circulation',
    niveau: 'Débutant',
    duree: '3 min',
    emoji: '🦶',
    description: 'Active la circulation veineuse des jambes.',
    etapes: ['Debout, appui sur une chaise si besoin', 'Montez sur la pointe des pieds', 'Tenez 2 secondes en haut', 'Redescendez lentement', 'Répétez 20 fois'],
    zones: ['jambes', 'mollets', 'pieds'],
    objectifs: ['circulation', 'prevention', 'renforcement'],
  ),
  _ExoData(
    nom: 'Étirement quadriceps',
    zone: 'Cuisses avant',
    niveau: 'Débutant',
    duree: '2 min',
    emoji: '🏃',
    description: 'Étire le quadriceps, bénéfique pour les genoux.',
    etapes: ['Debout, appui sur un mur', 'Fléchissez le genou droit derrière vous', 'Attrapez la cheville droite', 'Tenez 30 secondes', 'Répétez 3 fois chaque jambe'],
    zones: ['genoux', 'cuisses', 'jambes'],
    objectifs: ['souplesse', 'arthrose', 'douleur'],
  ),
  _ExoData(
    nom: 'Rétraction cervicale',
    zone: 'Nuque / Cou',
    niveau: 'Débutant',
    duree: '2 min',
    emoji: '↩️',
    description: 'Corrige la posture de la tête vers l\'avant.',
    etapes: ['Assis ou debout, dos droit', 'Rentrez le menton vers la gorge', 'Comme pour faire un double menton', 'Tenez 5 secondes', 'Répétez 10 fois'],
    zones: ['cervicales', 'cou', 'nuque'],
    objectifs: ['posture', 'douleur', 'prevention'],
  ),
];

// ═══════════════════════════════════════════════════
//  ALGORITHME DE SÉLECTION
// ═══════════════════════════════════════════════════
List<_ExoData> _selectionnerExos(UserProfile? profile) {
  if (profile == null) return _tousLesExos.take(10).toList();

  final zones = profile.zonesDouleur.map((z) => z.toLowerCase()).toList();
  final objectif = profile.objectifSante.toLowerCase();
  final niveau = profile.niveauActivite.toLowerCase();
  final problemes = profile.problemesSante.map((p) => p.toLowerCase()).toList();

  // Score par exercice
  final scores = <_ExoData, int>{};
  for (final exo in _tousLesExos) {
    int score = 0;
    // Correspondance zones douloureuses
    for (final z in zones) {
      if (exo.zones.any((ez) => z.contains(ez) || ez.contains(z))) score += 3;
    }
    // Correspondance objectif
    if (exo.objectifs.any((o) => objectif.contains(o) || o.contains(objectif))) score += 2;
    // Correspondance problèmes santé
    for (final p in problemes) {
      if (exo.objectifs.any((o) => p.contains(o) || o.contains(p))) score += 2;
    }
    // Niveau activité
    if (niveau.contains('débutant') || niveau.contains('sedentaire')) {
      if (exo.niveau == 'Débutant') score += 1;
    } else {
      if (exo.niveau == 'Intermédiaire') score += 1;
    }
    // Toujours inclure respiration et marche
    if (exo.nom.contains('Respiration') || exo.nom.contains('Marche')) score += 1;
    scores[exo] = score;
  }

  final sorted = scores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sorted.take(10).map((e) => e.key).toList();
}

// ═══════════════════════════════════════════════════
//  ÉCRAN SÉANCE PERSONNALISÉE
// ═══════════════════════════════════════════════════
class SeancePersonnaliseeScreen extends StatefulWidget {
  const SeancePersonnaliseeScreen({super.key});

  @override
  State<SeancePersonnaliseeScreen> createState() => _SeancePersonnaliseeScreenState();
}

class _SeancePersonnaliseeScreenState extends State<SeancePersonnaliseeScreen> {
  int _currentExo = 0;
  bool _seanceCommencee = false;
  final Set<int> _exosTermines = {};

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final profile = provider.userProfile;
    final exos = _selectionnerExos(profile);
    final prenom = profile?.prenom ?? 'vous';

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
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_exosTermines.length}/10',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de progression
          LinearProgressIndicator(
            value: _exosTermines.length / 10,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF26C6DA)),
            minHeight: 6,
          ),

          if (!_seanceCommencee)
            Expanded(child: _IntroSeance(
              prenom: prenom,
              profile: profile,
              exos: exos,
              onCommencer: () => setState(() => _seanceCommencee = true),
            ))
          else
            Expanded(
              child: Column(
                children: [
                  // Liste exercices
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: exos.length,
                      itemBuilder: (ctx, i) => _ExoCard(
                        exo: exos[i],
                        index: i,
                        isActive: i == _currentExo,
                        isDone: _exosTermines.contains(i),
                        onTap: () => setState(() => _currentExo = i),
                        onTermine: () {
                          setState(() {
                            _exosTermines.add(i);
                            if (i < exos.length - 1) _currentExo = i + 1;
                          });
                          if (_exosTermines.length == 10) {
                            _showSeanceComplete(context, provider, exos);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showSeanceComplete(BuildContext context, AppProvider provider, List<_ExoData> exos) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF26C6DA), Color(0xFF0097A7)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text('Séance terminée !',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(height: 10),
              Text('Bravo ! Vous avez complété vos 10 exercices personnalisés.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    height: 1.5,
                  )),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0097A7),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Retour au tableau de bord',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  INTRO SÉANCE
// ═══════════════════════════════════════════════════
class _IntroSeance extends StatelessWidget {
  final String prenom;
  final UserProfile? profile;
  final List<_ExoData> exos;
  final VoidCallback onCommencer;

  const _IntroSeance({
    required this.prenom,
    required this.profile,
    required this.exos,
    required this.onCommencer,
  });

  @override
  Widget build(BuildContext context) {
    final zones = profile?.zonesDouleur ?? [];
    final dureeTotal = exos.fold<int>(0, (sum, e) {
      final d = int.tryParse(e.duree.split(' ').first) ?? 2;
      return sum + d;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bulle IA personnalisée
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF26C6DA), Color(0xFF0097A7)],
              ),
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
                      Text(
                        'Séance pour $prenom',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        zones.isNotEmpty
                            ? 'J\'ai sélectionné 10 exercices adaptés à vos douleurs : ${zones.join(', ')}. Cette séance est spécialement conçue pour vous !'
                            : 'J\'ai sélectionné 10 exercices adaptés à votre profil et votre niveau d\'activité. Prenez votre temps !',
                        style: GoogleFonts.roboto(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats séance
          Row(
            children: [
              _StatBadge(emoji: '⏱️', label: '$dureeTotal min', sublabel: 'durée'),
              const SizedBox(width: 12),
              _StatBadge(emoji: '🏋️', label: '10', sublabel: 'exercices'),
              const SizedBox(width: 12),
              _StatBadge(emoji: '📊', label: profile?.niveauActivite ?? 'Adapté', sublabel: 'niveau'),
            ],
          ),
          const SizedBox(height: 20),

          // Liste aperçu
          Text('Vos 10 exercices du jour',
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              )),
          const SizedBox(height: 12),
          ...exos.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF26C6DA).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('${e.key + 1}',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF26C6DA),
                        )),
                  ),
                ),
                const SizedBox(width: 10),
                Text(e.value.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(e.value.nom,
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      )),
                ),
                Text(e.value.duree,
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    )),
              ],
            ),
          )),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow_rounded, size: 24),
              label: Text('Commencer la séance',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  )),
              onPressed: onCommencer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26C6DA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String emoji;
  final String label;
  final String sublabel;
  const _StatBadge({required this.emoji, required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            Text(sublabel, style: GoogleFonts.roboto(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  CARTE EXERCICE
// ═══════════════════════════════════════════════════
class _ExoCard extends StatelessWidget {
  final _ExoData exo;
  final int index;
  final bool isActive;
  final bool isDone;
  final VoidCallback onTap;
  final VoidCallback onTermine;

  const _ExoCard({
    required this.exo,
    required this.index,
    required this.isActive,
    required this.isDone,
    required this.onTap,
    required this.onTermine,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDone
              ? const Color(0xFFE8F5E9)
              : isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone
                ? const Color(0xFF4CAF50)
                : isActive
                    ? const Color(0xFF26C6DA)
                    : Colors.transparent,
            width: 2,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: const Color(0xFF26C6DA).withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(
          children: [
            // En-tête
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                          : const Color(0xFF26C6DA).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check, color: Color(0xFF4CAF50), size: 20)
                          : Text('${index + 1}', style: GoogleFonts.montserrat(
                              fontSize: 14, fontWeight: FontWeight.w700,
                              color: const Color(0xFF26C6DA))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(exo.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(exo.nom,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDone ? const Color(0xFF388E3C) : AppTheme.textPrimary,
                                )),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('${exo.zone} • ${exo.duree} • ${exo.niveau}',
                            style: GoogleFonts.roboto(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  if (!isDone)
                    Icon(
                      isActive ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppTheme.textLight,
                    ),
                  if (isDone)
                    const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 22),
                ],
              ),
            ),

            // Détail si actif
            if (isActive && !isDone)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Text(exo.description,
                        style: GoogleFonts.roboto(fontSize: 13, color: AppTheme.textSecondary, height: 1.4)),
                    const SizedBox(height: 12),
                    ...exo.etapes.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20, height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFF26C6DA),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('${e.key + 1}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(e.value,
                                style: GoogleFonts.roboto(fontSize: 13, color: AppTheme.textPrimary)),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text('Exercice terminé ✓',
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                        onPressed: onTermine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
