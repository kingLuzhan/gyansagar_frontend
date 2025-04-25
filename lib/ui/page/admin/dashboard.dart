import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyansagar_frontend/states/auth/auth_state.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _DashboardOverview(),
    const _UsersManagement(),
    const _ContentManagement(),
    const _Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gyansagar Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authState = Provider.of<AuthState>(context, listen: false);
              await authState.logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/admin/login');
            },
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.book),
                label: Text('Content'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _StatCard(
          title: 'Total Users',
          value: '1,234',
          icon: Icons.people,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'Total Courses',
          value: '56',
          icon: Icons.book,
          color: Colors.green,
        ),
        _StatCard(
          title: 'Active Users',
          value: '789',
          icon: Icons.person,
          color: Colors.orange,
        ),
        _StatCard(
          title: 'Total Revenue',
          value: '\$12,345',
          icon: Icons.monetization_on,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}

class _UsersManagement extends StatelessWidget {
  const _UsersManagement();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Users Management'));
  }
}

class _ContentManagement extends StatelessWidget {
  const _ContentManagement();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Content Management'));
  }
}

class _Settings extends StatelessWidget {
  const _Settings();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings'));
  }
}