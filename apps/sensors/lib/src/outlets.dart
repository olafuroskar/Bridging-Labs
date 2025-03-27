part of '../main.dart';

class OutletScreen extends StatefulWidget {
  const OutletScreen({super.key});

  @override
  State<OutletScreen> createState() => _OutletScreenState();
}

class _OutletScreenState extends State<OutletScreen>
    with SingleTickerProviderStateMixin {
  static const List<Tab> tabs = <Tab>[
    Tab(text: 'Available Devices'),
    Tab(text: 'Active Outlets'),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Outlets'),
          bottom: TabBar(
            tabs: tabs,
            controller: _tabController,
          ),
        ),
        body: TabBarView(
            controller: _tabController,
            children: [AvailableDevices(), ActiveOutlets()]));
  }
}
