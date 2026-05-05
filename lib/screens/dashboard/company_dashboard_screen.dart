// lib/screens/dashboard/company_dashboard_screen.dart
// Dashboard Entreprise — SANTEO Connect
// Vue d'ensemble : stats d'usage, utilisateurs actifs, progression, alertes

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({super.key});

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  // ── Métriques chargées ────────────────────────────────────────────────
  int _totalUsers = 0;
  int _activeUsersThisWeek = 0;
  int _sessionsThisWeek = 0;
  int _totalSessionsAll = 0;
  double _avgSessionsPerUser = 0;
  double _avgCompletionRate = 0;
  List<Map<String, dynamic>> _topExercises = [];
  List<Map<String, dynamic>> _recentUsers = [];
  Map<String, int> _sessionsByDay = {};
  Map<String, int> _usersByZone = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════════
  //  CHARGEMENT DES DONNÉES
  // ════════════════════════════════════════════════════════════════════

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = FirebaseFirestore.instance;
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      // ── 1. Nombre total d'utilisateurs ─────────────────────────────
      final usersSnapshot = await db.collection('users').get();
      _totalUsers = usersSnapshot.docs.length;

      // ── 2. Sessions de la semaine ───────────────────────────────────
      final sessionsSnapshot = await db.collection('sessions').get();
      _totalSessionsAll = sessionsSnapshot.docs.length;

      final weekSessions = sessionsSnapshot.docs.where((doc) {
        final data = doc.data();
        final ts = data['completed_at'];
        if (ts == null) return false;
        try {
          final date = (ts as Timestamp).toDate();
          return date.isAfter(weekAgo);
        } catch (_) {
          return false;
        }
      }).toList();

      _sessionsThisWeek = weekSessions.length;

      // Utilisateurs uniques cette semaine
      final activeUids = weekSessions
          .map((s) => s.data()['user_id'] as String? ?? '')
          .where((u) => u.isNotEmpty)
          .toSet();
      _activeUsersThisWeek = activeUids.length;

      // ── 3. Taux de complétion moyen ─────────────────────────────────
      if (sessionsSnapshot.docs.isNotEmpty) {
        final completions = sessionsSnapshot.docs
            .map((d) => (d.data()['completed'] as bool?) == true ? 1 : 0)
            .fold<int>(0, (a, b) => a + b);
        _avgCompletionRate =
            completions / sessionsSnapshot.docs.length * 100;
      }

      // ── 4. Sessions / utilisateur ────────────────────────────────────
      if (_totalUsers > 0) {
        _avgSessionsPerUser = _totalSessionsAll / _totalUsers;
      }

      // ── 5. Top exercices ─────────────────────────────────────────────
      final exCount = <String, int>{};
      for (final doc in sessionsSnapshot.docs) {
        final exId = doc.data()['exercise_id'] as String? ?? '';
        if (exId.isNotEmpty) {
          exCount[exId] = (exCount[exId] ?? 0) + 1;
        }
      }
      final sorted = exCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _topExercises = sorted.take(5).map((e) => {
        'id': e.key,
        'count': e.value,
        'name': _exerciseName(e.key),
      }).toList();

      // ── 6. Sessions par jour (7 derniers jours) ──────────────────────
      _sessionsByDay = {};
      for (var i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final key = '${day.day}/${day.month}';
        _sessionsByDay[key] = 0;
      }
      for (final doc in weekSessions) {
        final ts = doc.data()['completed_at'] as Timestamp?;
        if (ts != null) {
          final date = ts.toDate();
          final key = '${date.day}/${date.month}';
          if (_sessionsByDay.containsKey(key)) {
            _sessionsByDay[key] = (_sessionsByDay[key] ?? 0) + 1;
          }
        }
      }

      // ── 7. Répartition par zone ciblée ──────────────────────────────
      _usersByZone = {};
      for (final doc in usersSnapshot.docs) {
        final zones = (doc.data()['pain_zones'] as List?)?.cast<String>() ?? [];
        for (final z in zones) {
          _usersByZone[z] = (_usersByZone[z] ?? 0) + 1;
        }
      }

      // ── 8. Utilisateurs récents ──────────────────────────────────────
      final recentDocs = usersSnapshot.docs.take(10).toList();
      _recentUsers = recentDocs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'displayName': data['display_name'] as String? ?? 'Utilisateur',
          'email': data['email'] as String? ?? '',
          'createdAt': data['created_at'],
          'territory': data['territory'] as String? ?? 'NC',
        };
      }).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement : $e';
        _isLoading = false;
      });
    }
  }

  String _exerciseName(String id) {
    // Mapping ID → nom lisible
    final names = {
      'ex_abdos_2_temps': 'Abdos 2 temps',
      'ex_abdos_4_temps': 'Abdos 4 temps',
      'ex_bird_dog': 'Bird Dog',
      'ex_cat_cow': 'Cat-Cow',
      'ex_planche_haute': 'Planche Haute',
      'ex_dead_bug': 'Dead Bug',
      'ex_gainage_crunch': 'Gainage Crunch',
      'ex_mountain_climber': 'Mountain Climber',
      'ex_baby_stretch': 'Baby Stretch',
      'ex_down_dog': 'Down Dog',
    };
    return names[id] ?? id.replaceAll('ex_', '').replaceAll('_', ' ');
  }

  // ════════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOverviewTab(),
                            _buildUsersTab(),
                            _buildExercisesTab(),
                          ],
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _loadDashboardData,
        backgroundColor: AppTheme.primary,
        tooltip: 'Actualiser',
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                child: const Icon(Icons.business_center,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard Entreprise',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Vue d\'ensemble — SANTEO Connect',
                      style: GoogleFonts.roboto(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge actif
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Live',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // KPIs express
          Row(
            children: [
              _KpiChip(
                label: 'Utilisateurs',
                value: '$_totalUsers',
                icon: Icons.people,
              ),
              const SizedBox(width: 8),
              _KpiChip(
                label: 'Actifs 7j',
                value: '$_activeUsersThisWeek',
                icon: Icons.flash_on,
              ),
              const SizedBox(width: 8),
              _KpiChip(
                label: 'Sessions 7j',
                value: '$_sessionsThisWeek',
                icon: Icons.fitness_center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── TabBar ────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primary,
        indicatorWeight: 2.5,
        labelStyle: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Vue globale'),
          Tab(text: 'Utilisateurs'),
          Tab(text: 'Exercices'),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  TAB 1 : VUE GLOBALE
  // ════════════════════════════════════════════════════════════════════

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Métriques principales ──────────────────────────────────
          _SectionTitle(title: 'Métriques clés'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _MetricCard(
                title: 'Total sessions',
                value: '$_totalSessionsAll',
                icon: Icons.sports_gymnastics,
                color: AppTheme.primary,
                subtitle: 'Toutes périodes',
              ),
              _MetricCard(
                title: 'Taux de complétion',
                value: '${_avgCompletionRate.toStringAsFixed(0)}%',
                icon: Icons.check_circle_outline,
                color: AppTheme.success,
                subtitle: 'Sessions terminées',
              ),
              _MetricCard(
                title: 'Sessions / user',
                value: _avgSessionsPerUser.toStringAsFixed(1),
                icon: Icons.trending_up,
                color: AppTheme.secondary,
                subtitle: 'En moyenne',
              ),
              _MetricCard(
                title: 'Actifs ce mois',
                value: '$_activeUsersThisWeek',
                icon: Icons.person_pin_rounded,
                color: const Color(0xFF7E57C2),
                subtitle: 'Sur 7 jours',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Graphique sessions/jour ────────────────────────────────
          _SectionTitle(title: 'Sessions par jour (7 derniers jours)'),
          const SizedBox(height: 12),
          _buildSessionsChart(),

          const SizedBox(height: 24),

          // ── Zones ciblées ──────────────────────────────────────────
          if (_usersByZone.isNotEmpty) ...[
            _SectionTitle(title: 'Zones corporelles les plus ciblées'),
            const SizedBox(height: 12),
            _buildZonesBreakdown(),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionsChart() {
    if (_sessionsByDay.isEmpty) {
      return const _EmptyCard(message: 'Aucune session cette semaine');
    }

    final maxVal = _sessionsByDay.values.fold(0, (a, b) => a > b ? a : b);
    final displayMax = maxVal > 0 ? maxVal : 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _sessionsByDay.entries.map((entry) {
              final ratio = entry.value / displayMax;
              final barHeight = 100.0 * ratio;
              final isToday = entry.key ==
                  '${DateTime.now().day}/${DateTime.now().month}';

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      Text(
                        '${entry.value}',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isToday
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: barHeight.clamp(4.0, 100.0),
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppTheme.primary
                              : AppTheme.primary.withValues(alpha: 0.35),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.key,
                        style: GoogleFonts.roboto(
                          fontSize: 9,
                          color: isToday
                              ? AppTheme.primary
                              : AppTheme.textLight,
                          fontWeight: isToday
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildZonesBreakdown() {
    final sorted = _usersByZone.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = sorted.fold(0, (a, b) => a + b.value);
    if (total == 0) return const _EmptyCard(message: 'Données insuffisantes');

    final colors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.success,
      const Color(0xFF7E57C2),
      AppTheme.warning,
      const Color(0xFF26A69A),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: sorted.take(6).toList().asMap().entries.map((entry) {
          final i = entry.key;
          final zone = entry.value;
          final pct = zone.value / total;
          final color = colors[i % colors.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        zone.key,
                        style: GoogleFonts.roboto(
                            fontSize: 13, color: AppTheme.textPrimary),
                      ),
                    ),
                    Text(
                      '${zone.value}',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${(pct * 100).toStringAsFixed(0)}%)',
                      style: GoogleFonts.roboto(
                          fontSize: 11, color: AppTheme.textLight),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 5,
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  TAB 2 : UTILISATEURS
  // ════════════════════════════════════════════════════════════════════

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Résumé utilisateurs'),
          const SizedBox(height: 12),

          // Stats engagements
          Row(
            children: [
              Expanded(
                child: _StatBadge(
                  label: 'Inscrits',
                  value: '$_totalUsers',
                  icon: Icons.person_add_alt_1,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBadge(
                  label: 'Actifs 7j',
                  value: '$_activeUsersThisWeek',
                  icon: Icons.local_fire_department,
                  color: AppTheme.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _SectionTitle(title: 'Utilisateurs récents'),
          const SizedBox(height: 12),

          if (_recentUsers.isEmpty)
            const _EmptyCard(message: 'Aucun utilisateur enregistré')
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _recentUsers.asMap().entries.map((entry) {
                  final i = entry.key;
                  final user = entry.value;
                  final isLast = i == _recentUsers.length - 1;

                  return Column(
                    children: [
                      _UserRow(user: user),
                      if (!isLast)
                        const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: AppTheme.divider),
                    ],
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 20),

          // Engagement par territoire
          if (_usersByZone.isNotEmpty) ...[
            _SectionTitle(title: 'Taux d\'engagement'),
            const SizedBox(height: 12),
            _buildEngagementCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildEngagementCard() {
    final engagementRate = _totalUsers > 0
        ? (_activeUsersThisWeek / _totalUsers * 100)
        : 0.0;
    final color = engagementRate >= 70
        ? AppTheme.success
        : engagementRate >= 40
            ? AppTheme.warning
            : AppTheme.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${engagementRate.toStringAsFixed(0)}%',
                style: GoogleFonts.montserrat(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Taux d\'engagement',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Actifs 7j / Total inscrits',
                    style: GoogleFonts.roboto(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (engagementRate / 100).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            engagementRate >= 70
                ? '✅ Excellent taux d\'engagement !'
                : engagementRate >= 40
                    ? '⚠️ Engagement modéré — relancer avec des notifications'
                    : '🔴 Faible engagement — action requise',
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: color,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  TAB 3 : EXERCICES
  // ════════════════════════════════════════════════════════════════════

  Widget _buildExercisesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Top 5 exercices les plus pratiqués'),
          const SizedBox(height: 12),

          if (_topExercises.isEmpty)
            const _EmptyCard(message: 'Aucune session enregistrée')
          else ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _topExercises.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final ex = entry.value;
                  final maxCount = _topExercises.first['count'] as int;
                  final count = ex['count'] as int;
                  final pct = maxCount > 0 ? count / maxCount : 0.0;

                  final medalColors = [
                    const Color(0xFFFFD700),
                    const Color(0xFFC0C0C0),
                    const Color(0xFFCD7F32),
                    AppTheme.textLight,
                    AppTheme.textLight,
                  ];

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: medalColors[entry.key]
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$rank',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: medalColors[entry.key],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ex['name'] as String,
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '$count session${count > 1 ? 's' : ''}',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 5,
                            backgroundColor:
                                AppTheme.primary.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primary),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Statistiques globales exercices
          _SectionTitle(title: 'Aperçu global'),
          const SizedBox(height: 12),
          _buildGlobalExerciseStats(),
        ],
      ),
    );
  }

  Widget _buildGlobalExerciseStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'Exercices disponibles',
            value: '33',
            icon: Icons.fitness_center,
            color: AppTheme.primary,
          ),
          const Divider(height: 16, color: AppTheme.divider),
          _InfoRow(
            label: 'Sessions totales enregistrées',
            value: '$_totalSessionsAll',
            icon: Icons.assignment_turned_in_outlined,
            color: AppTheme.success,
          ),
          const Divider(height: 16, color: AppTheme.divider),
          _InfoRow(
            label: 'Taux de complétion moyen',
            value: '${_avgCompletionRate.toStringAsFixed(0)}%',
            icon: Icons.pie_chart_outline,
            color: AppTheme.secondary,
          ),
          const Divider(height: 16, color: AppTheme.divider),
          _InfoRow(
            label: 'Sessions / utilisateur',
            value: _avgSessionsPerUser.toStringAsFixed(1),
            icon: Icons.person_outline,
            color: const Color(0xFF7E57C2),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  WIDGETS UTILITAIRES
// ═══════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _KpiChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _KpiChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.roboto(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final Map<String, dynamic> user;
  const _UserRow({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user['displayName'] as String? ?? 'Utilisateur';
    final territory = user['territory'] as String? ?? '';
    final initials = name.isNotEmpty
        ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
            child: Text(
              initials,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (territory.isNotEmpty)
                  Text(
                    territory,
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Actif',
              style: GoogleFonts.roboto(
                fontSize: 10,
                color: AppTheme.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined,
              size: 40, color: AppTheme.textLight),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.roboto(
                fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
