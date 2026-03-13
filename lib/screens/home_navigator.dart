import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/premium_gate.dart';
import 'dashboard/dashboard_screen.dart';
import 'exercises/exercises_screen.dart';
import 'progress/progress_screen.dart';
import 'chat/chat_screen.dart';
import 'profile/profile_screen.dart';
import 'academie/academie_screen.dart';
import 'kine/parler_kine_screen.dart';

class HomeNavigator extends StatefulWidget {
  const HomeNavigator({super.key});

  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ExercisesScreen(),
    PremiumGate(
      featureName: 'Académie SANI',
      featureDescription: 'Accédez aux 6 pathologies, conseils personnalisés et à l\'IA SANI avec l\'abonnement Premium.',
      featureIcon: Icons.school_outlined,
      child: AcademieScreen(),
    ),
    PremiumGate(
      featureName: 'Parler à un kiné',
      featureDescription: 'Échangez avec Axel, Déborah, Maeva ou Solenne — nos kinés bien-être certifiés du Pacifique.',
      featureIcon: Icons.people_alt_outlined,
      child: ParlerKineScreen(),
    ),
    ChatScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.grey[500],
        selectedFontSize: 9,
        unselectedFontSize: 8,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Exercices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Académie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt),
            label: 'Kiné',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology),
            label: 'IA Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Progrès',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

