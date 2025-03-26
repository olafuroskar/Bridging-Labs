part of '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0 ? const OutletScreen() : const InletScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.outlet), label: 'Outlet'),
          NavigationDestination(icon: Icon(Icons.input), label: 'Inlet'),
        ],
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
