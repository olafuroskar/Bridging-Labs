part of '../../main.dart';

class InletResultScreen extends StatefulWidget {
  const InletResultScreen({super.key});

  @override
  State<InletResultScreen> createState() => _InletResultScreenState();
}

List<double> normalizeToRange(List<int> data) {
  if (data.isEmpty) return [];

  int minVal = data.reduce((a, b) => a < b ? a : b);
  int maxVal = data.reduce((a, b) => a > b ? a : b);

  if (minVal == maxVal) {
    return List.filled(data.length,
        50.0); // Assign mid-range value if all elements are the same
  }

  return data.map((x) => ((x - minVal) / (maxVal - minVal)) * 100).toList();
}

class _InletResultScreenState extends State<InletResultScreen> {
  var baselineX = 0.0;
  var baselineY = 0.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<InletProvider>(builder: (context, appState, child) {
      final data = appState.currentIntChunk;
      // final data = appState.currentIntChunk.isNotEmpty
      //     ? appState.currentIntChunk
      //     : appState.currentDoubleChunk.isNotEmpty
      //         ? appState.currentDoubleChunk
      //         : [];

      final normalizedData =
          normalizeToRange(data.map((elem) => elem.$1[0]).toList());

      final xAccData = data
          .asMap()
          .entries
          .map((entry) => FlSpot(entry.value.$2, normalizedData[entry.key]))
          .toList();

      return Scaffold(
          appBar: AppBar(title: const Text('Selected Inlets'), actions: [
            IconButton(
                onPressed: () {
                  appState.createInlet();
                },
                icon: Icon(Icons.play_arrow))
          ]),
          body: Column(
              children: normalizedData
                  .map((item) => Text(item.toString()))
                  .toList()));
      // body: xAccData.isEmpty
      //     ? Container()
      //     : Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           Text(
      //             'Timestamp',
      //             style: const TextStyle(
      //               color: Color.fromARGB(255, 10, 10, 10),
      //               fontSize: 18,
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //           Text(
      //             'User acceleration',
      //             style: TextStyle(
      //               color: Color.fromARGB(255, 10, 10, 10),
      //               fontSize: 18,
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //           AspectRatio(
      //             aspectRatio: 16 / 9,
      //             child: Padding(
      //               padding: const EdgeInsets.only(bottom: 24.0),
      //               child: LineChart(
      //                 LineChartData(
      //                   // minY: -5,
      //                   // maxY: 5,
      //                   minY: 0,
      //                   maxY: 100,
      //                   minX: xAccData.first.x,
      //                   maxX: xAccData.last.x,
      //                   lineTouchData: const LineTouchData(enabled: false),
      //                   clipData: const FlClipData.all(),
      //                   gridData: const FlGridData(
      //                     show: true,
      //                     drawVerticalLine: false,
      //                   ),
      //                   borderData: FlBorderData(show: false),
      //                   lineBarsData: [
      //                     line(xAccData),
      //                   ],
      //                   titlesData: const FlTitlesData(
      //                     show: false,
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           )
      //         ],
      //       ));
    });
  }

  LineChartBarData line(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: false,
      ),
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 50, 168, 82),
          Color.fromARGB(255, 245, 66, 66)
        ],
        stops: const [0.1, 1.0],
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
