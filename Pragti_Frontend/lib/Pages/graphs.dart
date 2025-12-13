import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pragti/Widgets/style.dart';

class Graphs extends StatefulWidget {
  const Graphs({super.key});

  @override
  State<Graphs> createState() => _GraphsState();
}

class _GraphsState extends State<Graphs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: MyAppbar(title: "GRAPHS"),
      backgroundColor: MyColors.forestgreen,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final pageWidth = constraints.maxWidth;
          final pageHeight = constraints.maxHeight;
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(0),
              bottomLeft: Radius.circular(1),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: pageWidth,
                    height: pageHeight / 2,
                    child: Card(
                      child: Column(
                        children: [
                          Text("EXPENSES"),
                          SfCircularChart(
                            title: ChartTitle(text: 'Expenses Per Category'),
                            legend: Legend(isVisible: true),
                            series: <PieSeries<_PieData, String>>[
                              PieSeries<_PieData, String>(
                                // explode: true,
                                enableTooltip: true,
                                explodeIndex: 0,
                                dataSource: [
                                  _PieData("Entertainment", 3),
                                  _PieData("Medicine", 5),
                                  _PieData("Food", 12),
                                ],
                                xValueMapper: (_PieData data, _) => data.xData,
                                yValueMapper: (_PieData data, _) => data.yData,
                                dataLabelMapper:
                                    (_PieData data, _) => data.xData,
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  labelPosition: ChartDataLabelPosition.inside,
                                  labelIntersectAction:
                                      LabelIntersectAction.shift,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: pageWidth,
                    height: pageHeight / 2,
                    child: Card(
                      child: Column(
                        children: [
                          Text("HABIT TRACKER"),
                          Row(children: [Text("sample ")]),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: pageWidth,
                    height: pageHeight / 2,
                    child: Card(
                      child: Column(
                        children: [
                          Text("HABIT TRACKER"),
                          Row(children: [Text("sample ")]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PieData {
  _PieData(this.xData, this.yData);
  final String xData;
  final num yData;
  String? text;
}
