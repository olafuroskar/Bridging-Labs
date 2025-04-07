part of '../../main.dart';

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
    polar.batteryLevel.listen((e) => log('Battery: ${e.level}'));
    polar.deviceConnecting.listen((_) => log('Device connecting'));
    polar.deviceConnected.listen((_) => log('Device connected'));
    polar.deviceDisconnected.listen((_) => log('Device disconnected'));
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
