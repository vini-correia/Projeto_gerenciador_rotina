import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'tasks_page.dart';
import 'finances_page.dart';
import 'workouts_page.dart';
import 'studies_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TasksPage(),
    const FinancesPage(),
    const WorkoutsPage(),
    const StudiesPage(),
  ];

  final List<String> _titles = [
    'Minha Agenda',
    'Dashboard Financeiro',
    'Rotina de Treinos',
    'Estudos e Projetos'
  ];

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text(_titles[_selectedIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF0F172A),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.track_changes, color: Colors.blueAccent, size: 40),
                  SizedBox(height: 12),
                  Text(
                      'Workspace',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  Text(
                      'Menu Principal',
                      style: TextStyle(color: Colors.grey, fontSize: 14)
                  ),
                ],
              ),
            ),
            _buildMenuItem(Icons.event_note, 'Minha Agenda', 0),
            _buildMenuItem(Icons.attach_money, 'Finanças', 1),
            _buildMenuItem(Icons.fitness_center, 'Treinos', 2),
            _buildMenuItem(Icons.school, 'Estudos', 3),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blueAccent : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.blueAccent.withOpacity(0.1),
      onTap: () => _selectPage(index),
    );
  }
}