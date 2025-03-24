part of '../main.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: LoadingPage(),
    );
  }
}

/// A loading page shown while the app is loading and setting up the sensing layer.
class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  Future<bool> init(BuildContext context) async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init(context),
      builder: (context, snapshot) => (!snapshot.hasData)
          ? Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [CircularProgressIndicator()],
              )))
          : ExampleLslApp(),
    );
  }
}

/// The main view of the app, shown once loading is done.
class ExampleLslApp extends StatefulWidget {
  const ExampleLslApp({super.key});

  @override
  ExampleLslAppState createState() => ExampleLslAppState();
}

class ExampleLslAppState extends State<ExampleLslApp> {
  int _selectedIndex = 0;

  final List<dynamic> _pages = [
    OutletPage(),
    InletPage(),
  ];

  @override
  void dispose() {
    // TODO: Delete everything
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.output), label: 'Outlets'),
          BottomNavigationBarItem(icon: Icon(Icons.input), label: 'Inlets'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);
}
