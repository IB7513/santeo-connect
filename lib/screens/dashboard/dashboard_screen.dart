import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/assets/logo_data.dart';
import '../../core/services/motivation_service.dart';
import '../../core/services/subscription_service.dart';
import '../../providers/app_providers.dart';
import '../../models/app_models.dart';
import '../../widgets/premium_gate.dart';
import '../dashboard/assessment_result_screen.dart';
import '../exercises/seance_personnalisee_screen.dart';
import '../kine/parler_kine_screen.dart';
import '../subscription/paywall_screen.dart';
import '../exercises/exercise_guided_screen.dart';
import '../../core/services/daily_plan_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return FadeTransition(
          opacity: _fadeAnim,
          child: Scaffold(
            backgroundColor: const Color(0xFFF0F4F8),
            body: SafeArea(
              child: RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: () => provider.analyzeWeeklyProgress(),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                        child: _HeroHeader(provider: provider)),
                    SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 16),
                          // Bannière félicitations dynamique
                          _CongratsBanner(provider: provider),
                          const SizedBox(height: 16),
                          // Bannière Premium (masquée si déjà abonné)
                          const PremiumBanner(),
                          // KPIs
                          _KpiRow(provider: provider),
                          const SizedBox(height: 16),
                          // Bilan IA
                          _AIAssessmentCard(provider: provider),
                          const SizedBox(height: 16),
                          // Actions rapides : Séance + Kiné
                          _QuickActionsRow(provider: provider),
                          const SizedBox(height: 16),
                          // Métriques santé
                          _HealthMetricsRow(provider: provider),
                          const SizedBox(height: 16),
                          // Programme du jour
                          _TodayProgramSection(provider: provider),
                          const SizedBox(height: 16),
                          // Analyse hebdo IA
                          if (provider.aiWeeklyAnalysis != null) ...[
                            _WeeklyAnalysisCard(provider: provider),
                            const SizedBox(height: 16),
                          ],
                          // Historique
                          _RecentSessionsCard(provider: provider),

                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════
//  HERO HEADER
// ═══════════════════════════════════════════════════
class _HeroHeader extends StatelessWidget {
  final AppProvider provider;
  const _HeroHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    final prenom =
        provider.userProfile?.prenom ?? provider.userName ?? 'Vous';
    final territory = provider.userProfile?.localisation ??
        provider.userTerritory ??
        'Pacifique';
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? '☀️ Bonjour'
        : hour < 18
            ? '🌤 Bon après-midi'
            : '🌙 Bonsoir';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF26C6DA), Color(0xFF0097A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -25,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              SanteoLogoData.bytes,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SANTEO Connect',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    _buildAvatar(prenom, provider),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '$greeting, $prenom !',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      territory,
                      style: GoogleFonts.roboto(
                          color: Colors.white70, fontSize: 13),
                    ),
                    if (provider.isDemoUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '🎭 Démo',
                          style: GoogleFonts.roboto(
                              color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String prenom, AppProvider provider) {
    final demo = provider.activeDemoProfile;
    final initials = demo?.avatarInitials ??
        (prenom.isNotEmpty ? prenom[0].toUpperCase() : 'U');
    final Color color = _roleColor(demo?.role ?? 'patient');
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16),
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'pro':
        return const Color(0xFF5C6BC0);
      case 'admin':
        return const Color(0xFF26A69A);
      case 'youth':
        return const Color(0xFFFF7043);
      case 'senior':
        return const Color(0xFF78909C);
      default:
        return AppTheme.secondary;
    }
  }
}

// ═══════════════════════════════════════════════════
//  BANNIÈRE FÉLICITATIONS DYNAMIQUE
// ═══════════════════════════════════════════════════
class _CongratsBanner extends StatelessWidget {
  final AppProvider provider;
  const _CongratsBanner({required this.provider});

  String get _message {
    final sessions = provider.totalSessionCount;
    final adherence = provider.weeklyAdherence;
    final hasAssessment = provider.aiAssessment != null;
    final prenom = provider.userProfile?.prenom ?? provider.userName ?? 'vous';
    return MotivationService.dashboardGreeting(
        prenom, sessions, adherence, hasAssessment);
  }

  Color get _bannerColor {
    final sessions = provider.totalSessionCount;
    final adherence = provider.weeklyAdherence;
    if (sessions == 0) return AppTheme.primary;
    if (adherence >= 80) return const Color(0xFF66BB6A);
    if (adherence >= 50) return AppTheme.primary;
    if (adherence > 0 && adherence < 30) return AppTheme.warning;
    return AppTheme.primary;
  }

  IconData get _bannerIcon {
    final sessions = provider.totalSessionCount;
    final adherence = provider.weeklyAdherence;
    if (sessions == 0) return Icons.auto_awesome;
    if (sessions >= 10) return Icons.emoji_events;
    if (adherence >= 80) return Icons.star;
    if (sessions >= 5) return Icons.military_tech;
    return Icons.celebration;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _bannerColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _bannerColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_bannerIcon, color: _bannerColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _message,
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: AppTheme.textPrimary,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  KPI ROW
// ═══════════════════════════════════════════════════
class _KpiRow extends StatelessWidget {
  final AppProvider provider;
  const _KpiRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            value: '${provider.totalSessionCount}',
            label: 'Séances',
            icon: Icons.fitness_center,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            value: '${provider.totalMinutes}',
            label: 'Minutes',
            icon: Icons.timer_outlined,
            color: AppTheme.secondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            value: '${provider.totalActiveDays}',
            label: 'Jours actifs',
            icon: Icons.calendar_today,
            color: AppTheme.success,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.roboto(
                fontSize: 11, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  AI ASSESSMENT CARD
// ═══════════════════════════════════════════════════
class _AIAssessmentCard extends StatelessWidget {
  final AppProvider provider;
  const _AIAssessmentCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final hasAssessment = provider.aiAssessment != null;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const AssessmentResultScreen()),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF26C6DA), Color(0xFF00838F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              top: -15,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.psychology,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mon Bilan IA Santé',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              hasAssessment
                                  ? '✅ Personnalisé • Adapté au Pacifique'
                                  : 'Générez votre bilan personnalisé',
                              style: GoogleFonts.roboto(
                                  color: Colors.white70,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white70, size: 16),
                    ],
                  ),
                  if (hasAssessment) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _truncate(provider.aiAssessment!, 200),
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.5,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '👆 Appuyez pour lire le bilan complet',
                      style: GoogleFonts.roboto(
                          color: Colors.white60, fontSize: 12),
                    ),
                  ] else ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome,
                              color: AppTheme.primary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Générer mon bilan IA gratuit',
                            style: GoogleFonts.montserrat(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncate(String text, int max) =>
      text.length <= max ? text : '${text.substring(0, max)}...';
}

// ═══════════════════════════════════════════════════
//  HEALTH METRICS ROW
// ═══════════════════════════════════════════════════
class _HealthMetricsRow extends StatelessWidget {
  final AppProvider provider;
  const _HealthMetricsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final adherence = provider.weeklyAdherence;
    final pain = provider.avgPainLevel;

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'Adhérence',
            subtitle: 'Cette semaine',
            value: '${adherence.toStringAsFixed(0)}%',
            color: _adherenceColor(adherence),
            icon: Icons.show_chart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                LinearPercentIndicator(
                  lineHeight: 8,
                  percent: (adherence / 100).clamp(0.0, 1.0),
                  backgroundColor:
                      _adherenceColor(adherence).withValues(alpha: 0.15),
                  progressColor: _adherenceColor(adherence),
                  barRadius: const Radius.circular(8),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 6),
                Text(
                  _adherenceLabel(adherence),
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    color: _adherenceColor(adherence),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            title: 'Douleur moy.',
            subtitle: 'Toutes séances',
            value: pain > 0
                ? '${pain.toStringAsFixed(1)}/10'
                : 'N/A',
            color: _painColor(pain),
            icon: Icons.healing,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) {
                    final filled = pain > 0 &&
                        (i + 1) <= (pain / 2).ceil();
                    return Expanded(
                      child: Container(
                        height: 8,
                        margin:
                            EdgeInsets.only(right: i < 4 ? 3 : 0),
                        decoration: BoxDecoration(
                          color: filled
                              ? _painColor(pain)
                              : _painColor(pain)
                                  .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                Text(
                  _painLabel(pain),
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    color: _painColor(pain),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _adherenceColor(double v) {
    if (v >= 70) return AppTheme.success;
    if (v >= 40) return AppTheme.warning;
    return AppTheme.error;
  }

  String _adherenceLabel(double v) {
    if (v >= 80) return '🌟 Excellent !';
    if (v >= 60) return '💪 Bien';
    if (v >= 30) return '🌱 En cours';
    return '👋 À démarrer';
  }

  Color _painColor(double p) {
    if (p == 0) return AppTheme.textLight;
    if (p <= 3) return AppTheme.success;
    if (p <= 6) return AppTheme.warning;
    return AppTheme.error;
  }

  String _painLabel(double p) {
    if (p == 0) return 'Aucune donnée';
    if (p <= 3) return '✅ Faible';
    if (p <= 6) return '⚡ Modérée';
    return '⚠️ Élevée';
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final Color color;
  final IconData icon;
  final Widget child;

  const _MetricCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 5),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.roboto(
                fontSize: 10, color: AppTheme.textLight),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: color,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  TODAY'S PROGRAM
// ═══════════════════════════════════════════════════
// ═══════════════════════════════════════════════════
//  PROGRAMME DU JOUR — 2 exercices IA avec déblocage
// ═══════════════════════════════════════════════════
class _TodayProgramSection extends StatefulWidget {
  final AppProvider provider;
  const _TodayProgramSection({required this.provider});

  @override
  State<_TodayProgramSection> createState() => _TodayProgramSectionState();
}

class _TodayProgramSectionState extends State<_TodayProgramSection> {
  final _planService = DailyPlanService();
  List<DailyExerciseSlot> _slots = [];
  bool _loading = true;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPlan());
  }

  Future<void> _loadPlan() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final slots = await _planService.getDailyPlan();
      final streak = await _planService.getStreak();
      if (mounted) setState(() { _slots = slots; _streak = streak; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onSlotCompleted(int slot) async {
    final updated = await _planService.markSlotCompleted(slot);
    if (mounted) setState(() => _slots = updated);
    if (mounted) _showCongrats(slot);
  }

  void _openGuidedScreen(DailyExerciseSlot s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseGuidedScreen(
          exerciseData: s.exerciseData,
          isFromDailyPlan: true,
          onCompleted: () => _onSlotCompleted(s.slot),
        ),
      ),
    ).then((completed) {
      if (completed == true) _onSlotCompleted(s.slot);
    });
  }

  void _showCongrats(int slot) {
    final both = _slots.every((s) => s.isCompleted);
    final msg = both
        ? '🏆 Les 2 exercices du jour complétés ! Streak : $_streak jours 🔥'
        : '✅ Exercice ${slot + 1} terminé ! Le suivant est maintenant disponible 💪';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.celebration, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: GoogleFonts.roboto(color: Colors.white, fontSize: 13))),
        ]),
        backgroundColor: both ? const Color(0xFFFF9E80) : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── En-tête ─────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exercices du jour',
                  style: GoogleFonts.montserrat(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary),
                ),
                if (_streak > 0)
                  Text(
                    '🔥 $_streak jour${_streak > 1 ? "s" : ""} de suite',
                    style: GoogleFonts.roboto(
                        fontSize: 12, color: AppTheme.secondary,
                        fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            if (!_loading)
              GestureDetector(
                onTap: _loadPlan,
                child: const Icon(Icons.refresh_rounded,
                    color: AppTheme.textLight, size: 20),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Contenu ─────────────────────────────────────────────────
        if (_loading)
          _buildSkeleton()
        else if (_slots.isEmpty)
          _buildEmptyState()
        else
          ..._slots.map((s) => _DailySlotCard(
            slot: s,
            onTap: s.isAvailable ? () => _openGuidedScreen(s) : null,
          )),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: List.generate(2, (_) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 88,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(width: 48, height: 48,
                decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(14))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(height: 14, width: 120, decoration: BoxDecoration(
                  color: AppTheme.divider, borderRadius: BorderRadius.circular(7))),
              const SizedBox(height: 8),
              Container(height: 10, width: 80, decoration: BoxDecoration(
                  color: AppTheme.divider, borderRadius: BorderRadius.circular(5))),
            ])),
          ]),
        ),
      )),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        const Icon(Icons.fitness_center, color: AppTheme.textLight, size: 40),
        const SizedBox(height: 10),
        Text('Catalogue en cours de chargement…',
            style: GoogleFonts.roboto(
                fontSize: 13, color: AppTheme.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _loadPlan,
          child: const Text('Réessayer'),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════
//  DAILY SLOT CARD
// ═══════════════════════════════════════════════════
class _DailySlotCard extends StatelessWidget {
  final DailyExerciseSlot slot;
  final VoidCallback? onTap;
  const _DailySlotCard({required this.slot, this.onTap});

  Color get _catColor {
    switch (slot.categorie) {
      case 'renforcement': return const Color(0xFF5C6BC0);
      case 'cardio':       return const Color(0xFFFF7043);
      case 'mobilite':     return const Color(0xFF26A69A);
      case 'etirement':    return AppTheme.primary;
      case 'relaxation':   return const Color(0xFF7E57C2);
      default:             return AppTheme.primary;
    }
  }

  IconData get _catIcon {
    switch (slot.categorie) {
      case 'renforcement': return Icons.fitness_center;
      case 'cardio':       return Icons.directions_run;
      case 'mobilite':     return Icons.self_improvement;
      case 'etirement':    return Icons.accessibility_new;
      case 'relaxation':   return Icons.air_rounded;
      default:             return Icons.sports_gymnastics;
    }
  }

  String get _diffLabel {
    switch (slot.difficulte) {
      case 'debutant':      return 'Débutant';
      case 'intermediaire': return 'Intermédiaire';
      case 'avance':        return 'Avancé';
      default:              return slot.difficulte;
    }
  }

  Color get _diffColor {
    switch (slot.difficulte) {
      case 'avance':        return AppTheme.error;
      case 'intermediaire': return AppTheme.warning;
      default:              return AppTheme.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked    = slot.isLocked;
    final isCompleted = slot.isCompleted;
    final cardColor   = isLocked ? const Color(0xFFF5F7FA) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isCompleted
              ? Border.all(color: AppTheme.success.withValues(alpha: 0.4), width: 1.5)
              : isLocked
                  ? Border.all(color: AppTheme.divider, width: 1)
                  : Border.all(color: _catColor.withValues(alpha: 0.25), width: 1.5),
          boxShadow: isLocked ? [] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // ── Icône catégorie ────────────────────────────────────────
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isLocked
                      ? AppTheme.divider
                      : _catColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: isLocked
                    ? const Icon(Icons.lock_rounded, color: AppTheme.textLight, size: 22)
                    : isCompleted
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppTheme.success, size: 24)
                        : Icon(_catIcon, color: _catColor, size: 24),
              ),
              const SizedBox(width: 12),

              // ── Texte ──────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Numéro slot + titre
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isLocked
                                ? AppTheme.divider
                                : _catColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Exercice ${slot.slot + 1}',
                            style: GoogleFonts.roboto(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isLocked ? AppTheme.textLight : _catColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '✓ Complété',
                              style: GoogleFonts.roboto(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.success),
                            ),
                          ),
                        if (isLocked)
                          Text(
                            'Finissez l\'exercice 1 d\'abord',
                            style: GoogleFonts.roboto(
                                fontSize: 10, color: AppTheme.textLight),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLocked ? '???' : slot.titre,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isLocked
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isLocked) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _Tag('${slot.estimatedMinutes} min',
                              Icons.timer_outlined),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _diffColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _diffLabel,
                              style: GoogleFonts.roboto(
                                  fontSize: 10,
                                  color: _diffColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ── Bouton action ──────────────────────────────────────────
              if (!isLocked && !isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_catColor, _catColor.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Commencer',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isLocked)
                const Icon(Icons.lock_rounded,
                    color: AppTheme.textLight, size: 20)
              else
                const Icon(Icons.check_circle_rounded,
                    color: AppTheme.success, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Tag(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.textLight),
        const SizedBox(width: 3),
        Text(label,
            style: GoogleFonts.roboto(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
//  ANCIEN _ExerciseListItem (conservé pour compat)
// ═══════════════════════════════════════════════════
class _ExerciseListItem extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onStart;
  const _ExerciseListItem(
      {required this.exercise, required this.onStart});

  Color get _typeColor {
    switch (exercise.type) {
      case 'renforcement':
        return const Color(0xFF5C6BC0);
      case 'cardio':
        return const Color(0xFFFF7043);
      case 'mobilite':
        return const Color(0xFF26A69A);
      default:
        return AppTheme.primary;
    }
  }

  IconData get _typeIcon {
    switch (exercise.type) {
      case 'renforcement':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'mobilite':
        return Icons.self_improvement;
      default:
        return Icons.accessibility_new;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_typeIcon, color: _typeColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _tag('${exercise.duration} min',
                          Icons.timer_outlined),
                      const SizedBox(width: 8),
                      _diffTag(exercise.difficulty),
                    ],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onStart,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF26C6DA), Color(0xFF0097A7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'Démarrer',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label, IconData icon) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textLight),
          const SizedBox(width: 3),
          Text(label,
              style: GoogleFonts.roboto(
                  fontSize: 11, color: AppTheme.textSecondary)),
        ],
      );

  Widget _diffTag(String diff) {
    Color c;
    switch (diff) {
      case 'difficile':
        c = AppTheme.error;
        break;
      case 'moyen':
        c = AppTheme.warning;
        break;
      default:
        c = AppTheme.success;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(diff,
          style: GoogleFonts.roboto(
              fontSize: 10, color: c, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyProgramCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.fitness_center,
              color: AppTheme.textLight, size: 48),
          const SizedBox(height: 12),
          Text('Aucun exercice prévu',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(
            'Générez votre bilan IA pour obtenir\nun programme personnalisé.',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
                fontSize: 12, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  WEEKLY ANALYSIS
// ═══════════════════════════════════════════════════
class _WeeklyAnalysisCard extends StatefulWidget {
  final AppProvider provider;
  const _WeeklyAnalysisCard({required this.provider});

  @override
  State<_WeeklyAnalysisCard> createState() =>
      _WeeklyAnalysisCardState();
}

class _WeeklyAnalysisCardState extends State<_WeeklyAnalysisCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.provider.aiWeeklyAnalysis ?? '';
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.success.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.insights,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '📊 Analyse IA — Cette semaine',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () =>
                      setState(() => _expanded = !_expanded),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                text.length > 140
                    ? '${text.substring(0, 140)}...'
                    : text,
                style: GoogleFonts.roboto(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.5),
              ),
              secondChild: Text(
                text,
                style: GoogleFonts.roboto(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  QUICK ACTIONS ROW (Séance du jour + Parler à un kiné)
// ═══════════════════════════════════════════════════
class _QuickActionsRow extends StatelessWidget {
  final AppProvider provider;
  const _QuickActionsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<SubscriptionService>().isPremium;
    return Row(
      children: [
        // Bouton Ma séance du jour
        Expanded(
          child: InkWell(
            onTap: () {
              if (isPremium) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const SeancePersonnaliseeScreen()));
              } else {
                PaywallScreen.show(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF42A5F5).withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.fitness_center,
                            color: Colors.white, size: 22),
                      ),
                      if (!isPremium)
                        Positioned(top: -4, right: -4,
                          child: Container(
                            width: 16, height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFB300), shape: BoxShape.circle),
                            child: const Icon(Icons.lock, color: Colors.white, size: 9))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Ma séance\ndu jour',
                      style: GoogleFonts.montserrat(
                        color: Colors.white, fontWeight: FontWeight.w700,
                        fontSize: 14, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(
                    isPremium ? '10 exos • personnalisés' : 'Premium requis',
                    style: GoogleFonts.roboto(
                      color: Colors.white.withValues(alpha: 0.8), fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Bouton Parler à un kiné
        Expanded(
          child: InkWell(
            onTap: () {
              if (isPremium) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const ParlerKineScreen()));
              } else {
                PaywallScreen.show(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF26C6DA), Color(0xFF00838F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.people_alt_outlined,
                            color: Colors.white, size: 22),
                      ),
                      if (!isPremium)
                        Positioned(top: -4, right: -4,
                          child: Container(
                            width: 16, height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFB300), shape: BoxShape.circle),
                            child: const Icon(Icons.lock, color: Colors.white, size: 9))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Parler à\nun kiné',
                      style: GoogleFonts.montserrat(
                        color: Colors.white, fontWeight: FontWeight.w700,
                        fontSize: 14, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(
                    isPremium ? '3 kinés disponibles' : 'Premium requis',
                    style: GoogleFonts.roboto(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
//  QUICK ACTIONS
// ═══════════════════════════════════════════════════
class _QuickActionsSection extends StatelessWidget {
  final AppProvider provider;
  const _QuickActionsSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ActionBtn(
                icon: Icons.chat_bubble_outline,
                label: 'Chat IA',
                color: const Color(0xFF7E57C2),
                onTap: () =>
                    Navigator.pushNamed(context, '/chat'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionBtn(
                icon: Icons.psychology,
                label: 'Bilan IA',
                color: AppTheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const AssessmentResultScreen()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionBtn(
                icon: Icons.show_chart,
                label: 'Analyse',
                color: AppTheme.success,
                isLoading: provider.isLoadingProgress,
                onTap: () => provider.analyzeWeeklyProgress(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: color),
                  )
                : Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  RECENT SESSIONS
// ═══════════════════════════════════════════════════
class _RecentSessionsCard extends StatelessWidget {
  final AppProvider provider;
  const _RecentSessionsCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final sessions =
        provider.sessions.reversed.take(5).toList();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historique des séances',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${provider.sessions.length} séances',
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (sessions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const Icon(Icons.history,
                          color: AppTheme.textLight, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        'Aucune séance encore 🌱\nCommencez votre première dès maintenant !',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          color: AppTheme.textLight,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...sessions.map((s) => _SessionRow(session: s)),
          ],
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final WorkoutSession session;
  const _SessionRow({required this.session});

  @override
  Widget build(BuildContext context) {
    final daysAgo =
        DateTime.now().difference(session.date).inDays;
    final label = daysAgo == 0
        ? "Aujourd'hui"
        : daysAgo == 1
            ? 'Hier'
            : 'Il y a $daysAgo j.';
    final painColor = session.niveauDouleur <= 3
        ? AppTheme.success
        : session.niveauDouleur <= 6
            ? AppTheme.warning
            : AppTheme.error;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fitness_center,
                color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.exercicesCompletes.length} exercice(s)',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '$label  •  ${session.dureeMinutes} min',
                  style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: painColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${session.niveauDouleur.toStringAsFixed(0)}/10',
              style: GoogleFonts.roboto(
                fontSize: 11,
                color: painColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


