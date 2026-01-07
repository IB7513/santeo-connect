import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_theme.dart';
import '../../core/assets/logo_data.dart';
import '../../core/services/motivation_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/common_widgets.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final activeDays = provider.sessions
            .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
            .toSet();

        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Row(
                      children: [
                        Image.memory(SanteoLogoData.bytes,
                            height: 30,
                            fit: BoxFit.contain),
                        const SizedBox(width: 10),
                        Text(
                          'Suivi de progression',
                          style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh,
                              color: AppTheme.primary),
                          onPressed: () => provider.analyzeWeeklyProgress(),
                          tooltip: 'Analyser avec IA',
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Summary KPIs
                      Row(
                        children: [
                          KpiCard(
                            value: provider.totalActiveDays.toString(),
                            label: 'Jours actifs',
                            icon: Icons.event_available,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 10),
                          KpiCard(
                            value:
                                '${provider.weeklyAdherence.toStringAsFixed(0)}%',
                            label: 'Adhérence',
                            icon: Icons.trending_up,
                            color: _adherenceColor(provider.weeklyAdherence),
                          ),
                          const SizedBox(width: 10),
                          KpiCard(
                            value: '${provider.totalMinutes}',
                            label: 'Min. total',
                            icon: Icons.timer,
                            color: AppTheme.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // === BANNIÈRE ENCOURAGEMENT ===
                      _ProgressEncouragementBanner(provider: provider),
                      const SizedBox(height: 16),

                      // Adherence bar
                      SanteoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Adhérence hebdomadaire',
                                style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary)),
                            const SizedBox(height: 12),
                            CircularPercentIndicator(
                              radius: 70,
                              lineWidth: 10,
                              percent: (provider.weeklyAdherence / 100)
                                  .clamp(0.0, 1.0),
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${provider.weeklyAdherence.toStringAsFixed(0)}%',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: _adherenceColor(
                                            provider.weeklyAdherence)),
                                  ),
                                  Text('cette semaine',
                                      style: GoogleFonts.roboto(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary)),
                                ],
                              ),
                              progressColor:
                                  _adherenceColor(provider.weeklyAdherence),
                              backgroundColor: AppTheme.divider,
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Weekly sessions chart
                      if (provider.sessions.isNotEmpty) ...[
                        SanteoCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sessions par semaine',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary)),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 160,
                                child: _WeeklyBarChart(
                                    sessions: provider.sessions),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Calendar
                      SanteoCard(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                              child: Text('Calendrier des séances',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary)),
                            ),
                            TableCalendar(
                              firstDay: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDay: DateTime.now()
                                  .add(const Duration(days: 30)),
                              focusedDay: _focusedDay,
                              selectedDayPredicate: (day) =>
                                  isSameDay(_selectedDay, day),
                              onDaySelected: (selected, focused) {
                                setState(() {
                                  _selectedDay = selected;
                                  _focusedDay = focused;
                                });
                              },
                              eventLoader: (day) {
                                final d =
                                    DateTime(day.year, day.month, day.day);
                                return activeDays.contains(d) ? [1] : [];
                              },
                              calendarStyle: CalendarStyle(
                                markerDecoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                todayDecoration: BoxDecoration(
                                  color:
                                      AppTheme.primary.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                outsideDaysVisible: false,
                              ),
                              headerStyle: HeaderStyle(
                                titleTextStyle: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                                formatButtonVisible: false,
                                titleCentered: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // AI Weekly Analysis
                      SanteoCard(
                        gradient: provider.aiWeeklyAnalysis != null
                            ? const LinearGradient(
                                colors: [Color(0xFF26C6DA), Color(0xFF00838F)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: provider.aiWeeklyAnalysis != null
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : AppTheme.primary
                                            .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.psychology,
                                      color: provider.aiWeeklyAnalysis != null
                                          ? Colors.white
                                          : AppTheme.primary,
                                      size: 20),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Analyse IA de la semaine',
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: provider.aiWeeklyAnalysis != null
                                          ? Colors.white
                                          : AppTheme.textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (provider.isLoadingProgress)
                              const Center(
                                child: CircularProgressIndicator(
                                    color: AppTheme.primary),
                              )
                            else if (provider.aiWeeklyAnalysis != null)
                              Text(
                                provider.aiWeeklyAnalysis!,
                                style: GoogleFonts.roboto(
                                    fontSize: 13,
                                    color: Colors.white,
                                    height: 1.6),
                              )
                            else
                              Column(
                                children: [
                                  Text(
                                    'Obtenez une analyse personnalisée de votre semaine avec des recommandations IA adaptées à votre profil.',
                                    style: GoogleFonts.roboto(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                        height: 1.5),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        provider.analyzeWeeklyProgress(),
                                    icon: const Icon(Icons.psychology),
                                    label:
                                        const Text('Analyser ma semaine'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _adherenceColor(double adherence) {
    if (adherence >= 70) return AppTheme.success;
    if (adherence >= 40) return AppTheme.warning;
    return AppTheme.error;
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List sessions;

  const _WeeklyBarChart({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    final Map<int, int> sessionsByDay = {};
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: now.weekday - 1 - i));
      final count = sessions.where((s) {
        final d = s.date as DateTime;
        return d.year == day.year &&
            d.month == day.month &&
            d.day == day.day;
      }).length;
      sessionsByDay[i] = count;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 5,
        barGroups: List.generate(
          7,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (sessionsByDay[i] ?? 0).toDouble(),
                color: sessionsByDay[i]! > 0
                    ? AppTheme.primary
                    : AppTheme.divider,
                width: 22,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6)),
              ),
            ],
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text(
                weekdays[v.toInt()],
                style: GoogleFonts.roboto(
                    fontSize: 11, color: AppTheme.textSecondary),
              ),
            ),
          ),
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  BANNIÈRE ENCOURAGEMENT PROGRESSION
// ═══════════════════════════════════════════════════

class _ProgressEncouragementBanner extends StatelessWidget {
  final AppProvider provider;
  const _ProgressEncouragementBanner({required this.provider});

  // Calcul du streak actuel (jours consécutifs)
  int get _currentStreak {
    if (provider.sessions.isEmpty) return 0;
    final sortedDates = provider.sessions
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime check = DateTime.now();
    for (final d in sortedDates) {
      final diff = DateTime(check.year, check.month, check.day)
          .difference(d)
          .inDays;
      if (diff == 0 || diff == 1) {
        streak++;
        check = d;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final adherence = provider.weeklyAdherence;
    final sessions = provider.totalSessionCount;
    final streak = _currentStreak;
    final level =
        MotivationService.getLevel(sessions, adherence);

    final adherenceMsg = MotivationService.adherenceMessage(adherence);
    final streakMsg = MotivationService.streakMessage(streak);

    return Column(
      children: [
        // Carte niveau actuel
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(level.colorValue),
                Color(level.colorValue).withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(level.iconAsset,
                      style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niveau : ${level.label}',
                      style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      adherenceMsg,
                      style: GoogleFonts.roboto(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Carte streak si > 0
        if (streak > 0) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_fire_department,
                      color: AppTheme.warning, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔥 Streak : $streak jour${streak > 1 ? "s" : ""} consécutif${streak > 1 ? "s" : ""}',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppTheme.textPrimary),
                      ),
                      if (streakMsg.isNotEmpty)
                        Text(
                          streakMsg,
                          style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              height: 1.3),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
