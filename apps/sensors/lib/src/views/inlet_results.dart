part of '../../main.dart';

class InletResultScreen extends StatefulWidget {
  const InletResultScreen({super.key});

  @override
  State<InletResultScreen> createState() => _InletResultScreenState();
}

class _InletResultScreenState extends State<InletResultScreen> {
  var baselineX = 0.0;
  var baselineY = 0.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<InletProvider>(builder: (context, appState, child) {
      final data = appState.currentDoubleChunk;

      final xAccData =
          data.map((element) => FlSpot(element.$2, element.$1[0])).toList();

      return Scaffold(
          appBar: AppBar(title: const Text('Selected Inlets'), actions: [
            IconButton(
                onPressed: () {
                  appState.createInlet();
                },
                icon: Icon(Icons.play_arrow))
          ]),
          body: xAccData.isEmpty
              ? Container()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Timestamp',
                      // 'x: ${xValue.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Color.fromARGB(1, 10, 10, 10),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      // 'sin: ${sinPoints.last.y.toStringAsFixed(1)}',
                      'User acceleration',
                      style: TextStyle(
                        color: Color.fromARGB(1, 10, 10, 10),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Text(
                    //   'cos: ${cosPoints.last.y.toStringAsFixed(1)}',
                    //   style: TextStyle(
                    //     color: widget.cosColor,
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    const SizedBox(
                      height: 12,
                    ),
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: LineChart(
                          LineChartData(
                            minY: -5,
                            maxY: 5,
                            minX: xAccData.first.x,
                            maxX: xAccData.last.x,
                            lineTouchData: const LineTouchData(enabled: false),
                            clipData: const FlClipData.all(),
                            gridData: const FlGridData(
                              show: true,
                              drawVerticalLine: false,
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              line(xAccData),
                              // cosLine(cosPoints),
                            ],
                            titlesData: const FlTitlesData(
                              show: false,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ));
    });
  }

  LineChartBarData line(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: false,
      ),
      barWidth: 4,
      isCurved: false,
    );
  }

  // LineChartBarData cosLine(List<FlSpot> points) {
  //   return LineChartBarData(
  //     spots: points,
  //     dotData: const FlDotData(
  //       show: false,
  //     ),
  //     gradient: LinearGradient(
  //       colors: [widget.cosColor.withValues(alpha: 0), widget.cosColor],
  //       stops: const [0.1, 1.0],
  //     ),
  //     barWidth: 4,
  //     isCurved: false,
  //   );
  // }
}
