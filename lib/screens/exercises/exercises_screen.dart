import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/assets/logo_data.dart';
import '../../core/services/motivation_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/common_widgets.dart';
import '../../models/app_models.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final displayed = provider.filteredExercises.isEmpty &&
                provider.activeFilter == 'all'
            ? provider.exercises
            : provider.filteredExercises;

        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.memory(SanteoLogoData.bytes,
                              height: 30,
                              fit: BoxFit.contain),
                          const SizedBox(width: 10),
                          Text(
                            'Bibliothèque d\'exercices',
                            style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Search
                      TextField(
                        controller: _searchCtrl,
                        onChanged: (v) {
                          if (v.isEmpty) {
                            provider.filterExercises('all');
                          } else {
                            provider.searchExercises(v);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Rechercher un exercice...',
                          prefixIcon:
                              const Icon(Icons.search, color: AppTheme.textLight),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    provider.filterExercises('all');
                                    setState(() {});
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'Tous',
                              isActive: provider.activeFilter == 'all',
                              onTap: () {
                                provider.filterExercises('all');
                                _searchCtrl.clear();
                              },
                            ),
                            _FilterChip(
                              label: 'Étirement',
                              icon: Icons.self_improvement,
                              color: AppTheme.primary,
                              isActive: provider.activeFilter == 'etirement',
                              onTap: () => provider.filterExercises('etirement'),
                            ),
                            _FilterChip(
                              label: 'Renforcement',
                              icon: Icons.fitness_center,
                              color: AppTheme.secondary,
                              isActive:
                                  provider.activeFilter == 'renforcement',
                              onTap: () =>
                                  provider.filterExercises('renforcement'),
                            ),
                            _FilterChip(
                              label: 'Mobilité',
                              icon: Icons.rotate_right,
                              color: const Color(0xFF7E57C2),
                              isActive: provider.activeFilter == 'mobilite',
                              onTap: () => provider.filterExercises('mobilite'),
                            ),
                            _FilterChip(
                              label: 'Cardio',
                              icon: Icons.directions_run,
                              color: AppTheme.error,
                              isActive: provider.activeFilter == 'cardio',
                              onTap: () => provider.filterExercises('cardio'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // Grid
                Expanded(
                  child: displayed.isEmpty
                      ? _EmptyState()
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: displayed.length,
                          itemBuilder: (ctx, i) =>
                              _ExerciseCard(exercise: displayed[i]),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primary;
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? chipColor : AppTheme.divider,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: chipColor.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14,
                  color: isActive ? Colors.white : chipColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseCard({required this.exercise});

  Color get _typeColor {
    switch (exercise.type) {
      case 'etirement': return AppTheme.primary;
      case 'renforcement': return AppTheme.secondary;
      case 'mobilite': return const Color(0xFF7E57C2);
      case 'cardio': return AppTheme.error;
      default: return AppTheme.textLight;
    }
  }

  IconData get _typeIcon {
    switch (exercise.type) {
      case 'etirement': return Icons.self_improvement;
      case 'renforcement': return Icons.fitness_center;
      case 'mobilite': return Icons.rotate_right;
      case 'cardio': return Icons.directions_run;
      default: return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetail(context),
      child: SanteoCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_typeIcon, color: _typeColor, size: 22),
            ),
            const SizedBox(height: 10),

            // Name
            Text(
              exercise.name,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Zone
            Text(
              exercise.targetZone,
              style: GoogleFonts.roboto(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // Bottom row
            Row(
              children: [
                Icon(Icons.timer, size: 12, color: AppTheme.textLight),
                const SizedBox(width: 3),
                Text('${exercise.duration}min',
                    style: GoogleFonts.roboto(
                        fontSize: 11, color: AppTheme.textSecondary)),
                const Spacer(),
                DifficultyChip(difficulty: exercise.difficulty),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExerciseDetailSheet(exercise: exercise),
    );
  }
}

class _ExerciseDetailSheet extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseDetailSheet({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ExerciseTypeChip(type: exercise.type),
                        const SizedBox(width: 8),
                        DifficultyChip(difficulty: exercise.difficulty),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      exercise.name,
                      style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: AppTheme.textLight),
                        const SizedBox(width: 4),
                        Text(exercise.targetZone,
                            style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: AppTheme.textSecondary)),
                        const SizedBox(width: 16),
                        const Icon(Icons.timer_outlined,
                            size: 16, color: AppTheme.textLight),
                        const SizedBox(width: 4),
                        Text('${exercise.duration} minutes',
                            style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: AppTheme.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Instructions',
                        style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 10),
                    Text(
                      exercise.description,
                      style: GoogleFonts.roboto(
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                          height: 1.7),
                    ),
                    const SizedBox(height: 24),
                    // Climate tip
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.wb_sunny_outlined,
                              color: AppTheme.primary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Conseil tropical : Pratiquez tôt le matin ou en soirée pour éviter la chaleur. Hydratez-vous bien avant, pendant et après l\'exercice.',
                              style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: AppTheme.primaryDark,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Commencer cet exercice'),
                        onPressed: () async {
                          Navigator.pop(context);
                          final provider = context.read<AppProvider>();
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);
                          final session = WorkoutSession(
                            id: 'session_${DateTime.now().millisecondsSinceEpoch}',
                            userId: provider.userId ?? '',
                            date: DateTime.now(),
                            exercicesCompletes: [exercise.id],
                            dureeMinutes: exercise.duration,
                            niveauDouleur: 2.0,
                          );
                          await provider.recordSession(session);
                          final totalSessions = provider.totalSessionCount;
                          final msg = MotivationService.exerciseCompleted(
                              exercise.name, totalSessions);

                          // Snackbar riche avec icône
                          scaffoldMessenger
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.25),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.emoji_events,
                                          color: Colors.white, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        msg,
                                        style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize: 13,
                                            height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppTheme.success,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                margin: const EdgeInsets.all(16),
                              ),
                            );

                          // Dialog milestone spécial
                          final milestoneMsg =
                              MotivationService.sessionMilestone(
                                  totalSessions);
                          if (milestoneMsg.isNotEmpty) {
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                            if (context.mounted) {
                              _showMilestoneDialog(
                                  context, milestoneMsg, totalSessions);
                            }
                          }
                        },
                      ),
                    ),
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

// ═══════════════════════════════════════════════════
//  MILESTONE DIALOG
// ═══════════════════════════════════════════════════

void _showMilestoneDialog(
    BuildContext context, String message, int sessionCount) {
  final level = MotivationService.getLevel(sessionCount, 0);
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Color(level.colorValue),
              Color(level.colorValue).withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  level.iconAsset,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nouveau Jalon !',
              style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 14,
                  height: 1.5),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                level.label,
                style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(level.colorValue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Continuer 💪',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, color: AppTheme.textLight, size: 60),
          const SizedBox(height: 16),
          Text('Aucun exercice trouvé',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  fontSize: 16)),
          const SizedBox(height: 8),
          Text('Essayez un autre filtre ou terme de recherche.',
              style: GoogleFonts.roboto(
                  color: AppTheme.textLight, fontSize: 13)),
        ],
      ),
    );
  }
}
