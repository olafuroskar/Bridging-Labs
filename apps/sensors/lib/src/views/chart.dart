part of '../../main.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final limitCount = 100;
  final sinPoints = <FlSpot>[];
  final cosPoints = <FlSpot>[];

  double xValue = 0;
  double step = 0.05;

  late Timer timer;

  Color colorFromString(String input) {
    // Hash the string using SHA1 to get a consistent and uniform output
    final hash = sha1.convert(utf8.encode(input)).bytes;

    // Use first 3 bytes for RGB, set alpha to 0xFF (opaque)
    final r = hash[0];
    final g = hash[1];
    final b = hash[2];

    return Color.fromARGB(0xFF, r, g, b);
  }

  LineChartBarData line(String inlet, List<List<dynamic>> buffer) {
    return LineChartBarData(
      spots: buffer
          .map((val) => FlSpot(double.parse(val[0]), double.parse(val[1])))
          .toList(),
      dotData: const FlDotData(
        show: false,
      ),
      color: colorFromString(inlet),
      barWidth: 4,
      isCurved: false,
    );
  }

  LineChartBarData sinLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: false,
      ),
      gradient: LinearGradient(
        colors: [Colors.greenAccent, Colors.green],
        stops: const [0.1, 1.0],
      ),
      barWidth: 4,
      isCurved: false,
    );
  }

  LineChartBarData cosLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: false,
      ),
      gradient: LinearGradient(
        colors: [Colors.redAccent, Colors.red],
        stops: const [0.1, 1.0],
      ),
      barWidth: 4,
      isCurved: false,
    );
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      while (sinPoints.length > limitCount) {
        sinPoints.removeAt(0);
        cosPoints.removeAt(0);
      }
      setState(() {
        sinPoints.add(FlSpot(xValue, math.sin(xValue)));
        cosPoints.add(FlSpot(xValue, math.cos(xValue)));
      });
      xValue += step;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InletProvider>(builder: (context, appState, child) {
      return Scaffold(
          appBar: AppBar(title: const Text('Chart')),
          body: Column(
            // return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: 2,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: LineChart(
                    LineChartData(
                      minY: -1,
                      maxY: 1,
                      // minX: sinPoints.first.x,
                      // maxX: sinPoints.last.x,
                      lineTouchData: const LineTouchData(enabled: false),
                      clipData: const FlClipData.all(),
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: appState.buffers.entries
                          .map((entry) => line(entry.key, entry.value))
                          .toList(),
                      titlesData: const FlTitlesData(
                        show: false,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ));
      // );
    });
  }
}
