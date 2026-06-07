import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/assets/logo_data.dart';

// ═══════════════════════════════════════════════════
//  DONNÉES PATHOLOGIES
// ═══════════════════════════════════════════════════
class _Pathologie {
  final String id;
  final String titre;
  final String icone;
  final Color couleur;
  final String description;
  final List<String> symptomes;
  final List<String> conseils;
  final String avatarMessage;

  const _Pathologie({
    required this.id,
    required this.titre,
    required this.icone,
    required this.couleur,
    required this.description,
    required this.symptomes,
    required this.conseils,
    required this.avatarMessage,
  });
}

const List<_Pathologie> _pathologies = [
  _Pathologie(
    id: 'lombalgie',
    titre: 'Lombalgie',
    icone: '🦴',
    couleur: Color(0xFF26C6DA),
    description: 'La lombalgie est une douleur dans le bas du dos, très fréquente dans les îles du Pacifique. Elle touche 8 personnes sur 10 au cours de leur vie.',
    symptomes: ['Douleur dans le bas du dos', 'Raideur le matin', 'Douleur irradiant dans les fesses', 'Difficulté à se pencher en avant'],
    conseils: ['Restez actif, évitez le repos strict', 'Pratiquez les exercices de mobilité', 'Dormez sur un matelas ferme', 'Évitez de porter des charges lourdes'],
    avatarMessage: 'Bonjour ! Je suis SANI, votre assistant santé. La lombalgie est la 1ère cause de consultation en Nouvelle-Calédonie. Bonne nouvelle : dans 90% des cas, elle guérit avec des exercices adaptés. Je vais vous expliquer tout ce qu\'il faut savoir ! 💙',
  ),
  _Pathologie(
    id: 'cervicalgie',
    titre: 'Cervicalgie',
    icone: '🤕',
    couleur: Color(0xFF7E57C2),
    description: 'La cervicalgie est une douleur au niveau du cou. Elle est souvent liée aux postures prolongées, au travail sur écran ou au stress.',
    symptomes: ['Douleur dans le cou', 'Raideur cervicale', 'Maux de tête', 'Douleur irradiant dans le bras'],
    conseils: ['Faites des pauses régulières devant l\'écran', 'Pratiquez les étirements cervicaux', 'Ajustez votre poste de travail', 'Gérez le stress avec la relaxation'],
    avatarMessage: 'Bonjour ! Avec les smartphones et les écrans, la cervicalgie touche de plus en plus de personnes au Pacifique. Les exercices doux et les bonnes postures font toute la différence. Je vais vous guider pas à pas ! 🌺',
  ),
  _Pathologie(
    id: 'arthrose',
    titre: 'Arthrose',
    icone: '🦵',
    couleur: Color(0xFFFF9E80),
    description: 'L\'arthrose est une maladie des articulations très répandue. Elle touche surtout les genoux, les hanches et les mains, et s\'aggrave avec l\'âge.',
    symptomes: ['Douleur à l\'effort', 'Raideur après le repos', 'Gonflement articulaire', 'Craquements dans les articulations'],
    conseils: ['Maintenez une activité physique régulière', 'Perdez du poids si nécessaire', 'Utilisez des chaussures adaptées', 'Évitez les activités à fort impact'],
    avatarMessage: 'Ia orana ! L\'arthrose n\'est pas une fatalité. Le mouvement est votre meilleur médicament ! Contrairement aux idées reçues, bouger protège vos articulations. Ensemble, on va trouver les exercices parfaits pour vous ! 🌊',
  ),
  _Pathologie(
    id: 'tendinite',
    titre: 'Tendinite',
    icone: '💪',
    couleur: Color(0xFF66BB6A),
    description: 'La tendinite est une inflammation d\'un tendon, souvent causée par une surcharge ou un geste répété. Elle touche fréquemment l\'épaule, le coude et le talon.',
    symptomes: ['Douleur à la mobilisation', 'Gonflement local', 'Chaleur au toucher', 'Douleur nocturne'],
    conseils: ['Reposez le tendon en phase aiguë', 'Appliquez du froid 15min/jour', 'Reprenez progressivement l\'activité', 'Renforcez les muscles autour du tendon'],
    avatarMessage: 'Kia ora ! La tendinite est fréquente chez les travailleurs manuels et les sportifs du Pacifique. La clé est de doser votre activité et de renforcer progressivement. Je vous explique comment récupérer efficacement ! 💪',
  ),
  _Pathologie(
    id: 'sciatique',
    titre: 'Sciatique',
    icone: '⚡',
    couleur: Color(0xFFF44336),
    description: 'La sciatique est une douleur qui suit le trajet du nerf sciatique, du bas du dos jusqu\'au pied. Elle est souvent causée par une hernie discale.',
    symptomes: ['Douleur en éclair de la fesse au pied', 'Engourdissement dans la jambe', 'Fourmillements au pied', 'Faiblesse musculaire du membre'],
    conseils: ['Évitez les positions prolongées', 'Pratiquez la marche douce', 'Consultez si la douleur dure plus de 6 semaines', 'Évitez de soulever des charges lourdes'],
    avatarMessage: 'Bonjour ! La sciatique peut être très douloureuse mais dans 80% des cas elle passe avec un traitement adapté. Les bons exercices peuvent soulager rapidement. Je vais vous montrer lesquels éviter et lesquels pratiquer ! ⚡',
  ),
  _Pathologie(
    id: 'hypertension',
    titre: 'Hypertension',
    icone: '❤️',
    couleur: Color(0xFFEC407A),
    description: 'L\'hypertension artérielle est très fréquente en Polynésie et en Nouvelle-Calédonie. L\'activité physique régulière est l\'un des meilleurs traitements naturels.',
    symptomes: ['Souvent silencieuse', 'Maux de tête', 'Vertiges', 'Bourdonnements d\'oreilles'],
    conseils: ['Faites 30 min de marche par jour', 'Réduisez le sel dans votre alimentation', 'Évitez le stress', 'Prenez votre traitement régulièrement'],
    avatarMessage: 'Bonjour ! L\'hypertension touche 1 adulte sur 3 au Pacifique. L\'exercice physique peut réduire votre tension de 5 à 8 mmHg — autant qu\'un médicament ! Je vais vous expliquer les exercices les plus adaptés. ❤️',
  ),
];

// ═══════════════════════════════════════════════════
//  ÉCRAN PRINCIPAL ACADÉMIE
// ═══════════════════════════════════════════════════
class AcademieScreen extends StatefulWidget {
  const AcademieScreen({super.key});

  @override
  State<AcademieScreen> createState() => _AcademieScreenState();
}

class _AcademieScreenState extends State<AcademieScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _avatarController;
  late Animation<double> _bounceAnimation;
  bool _avatarParle = false;
  String _avatarTexte = 'Bonjour ! Je suis SANI, votre assistante santé. Choisissez une pathologie pour en apprendre plus ! 🌺';

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  void _parlerAvatar(String message) {
    setState(() {
      _avatarParle = true;
      _avatarTexte = message;
    });
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) setState(() => _avatarParle = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF26C6DA), Color(0xFF0097A7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.memory(SanteoLogoData.bytes, height: 30, fit: BoxFit.contain),
                      const SizedBox(width: 10),
                      Text(
                        'Académie Santé',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '📚 Éducation santé',
                          style: GoogleFonts.roboto(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Avatar SANI
                  _AvatarSani(
                    bounceAnimation: _bounceAnimation,
                    parle: _avatarParle,
                    message: _avatarTexte,
                  ),
                ],
              ),
            ),

            // Grille pathologies
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choisissez une pathologie',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tapez sur une carte pour que SANI vous explique',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: _pathologies.length,
                      itemBuilder: (ctx, i) => _PathologieCard(
                        pathologie: _pathologies[i],
                        onTap: () {
                          _parlerAvatar(_pathologies[i].avatarMessage);
                          _showDetail(context, _pathologies[i]);
                        },
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, _Pathologie p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PathologieDetail(pathologie: p),
    );
  }
}

// ═══════════════════════════════════════════════════
//  AVATAR SANI
// ═══════════════════════════════════════════════════
class _AvatarSani extends StatelessWidget {
  final Animation<double> bounceAnimation;
  final bool parle;
  final String message;

  const _AvatarSani({
    required this.bounceAnimation,
    required this.parle,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Avatar animé
        AnimatedBuilder(
          animation: bounceAnimation,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, bounceAnimation.value),
            child: child,
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF80DEEA), Color(0xFF26C6DA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text('👩‍⚕️', style: TextStyle(fontSize: 36)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'SANI',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Bulle de dialogue
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (parle)
                  Row(
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF26C6DA),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'SANI parle...',
                        style: GoogleFonts.roboto(
                          fontSize: 10,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                if (parle) const SizedBox(height: 6),
                Text(
                  message,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
//  CARTE PATHOLOGIE
// ═══════════════════════════════════════════════════
class _PathologieCard extends StatelessWidget {
  final _Pathologie pathologie;
  final VoidCallback onTap;

  const _PathologieCard({required this.pathologie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: pathologie.couleur.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: pathologie.couleur.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: pathologie.couleur.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(pathologie.icone, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              pathologie.titre,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: pathologie.couleur.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'En savoir plus',
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: pathologie.couleur,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  DÉTAIL PATHOLOGIE (Bottom Sheet)
// ═══════════════════════════════════════════════════
class _PathologieDetail extends StatelessWidget {
  final _Pathologie pathologie;
  const _PathologieDetail({required this.pathologie});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Header coloré
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    pathologie.couleur,
                    pathologie.couleur.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(pathologie.icone, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pathologie.titre,
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Éducation santé • SANI',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Contenu
            Expanded(
              child: SingleChildScrollView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bulle avatar
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: pathologie.couleur.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: pathologie.couleur.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('👩‍⚕️', style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              pathologie.avatarMessage,
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Description
                    _Section(
                      titre: '📖 Qu\'est-ce que c\'est ?',
                      couleur: pathologie.couleur,
                      child: Text(
                        pathologie.description,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Symptômes
                    _Section(
                      titre: '🔍 Symptômes',
                      couleur: pathologie.couleur,
                      child: Column(
                        children: pathologie.symptomes.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: pathologie.couleur,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(s, style: GoogleFonts.roboto(
                                  fontSize: 14, color: AppTheme.textPrimary,
                                )),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Conseils
                    _Section(
                      titre: '💡 Conseils de SANI',
                      couleur: pathologie.couleur,
                      child: Column(
                        children: pathologie.conseils.asMap().entries.map((e) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: pathologie.couleur.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                  color: pathologie.couleur,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${e.key + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(e.value, style: GoogleFonts.roboto(
                                  fontSize: 13, color: AppTheme.textPrimary,
                                )),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Avertissement
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFB74D)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFFF9800), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Ces informations sont éducatives. Consultez toujours un professionnel de santé pour un diagnostic et traitement adaptés.',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: const Color(0xFFE65100),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String titre;
  final Color couleur;
  final Widget child;

  const _Section({required this.titre, required this.couleur, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titre,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
