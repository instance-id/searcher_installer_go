import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:searcher_installer_go/animations/charts/animate_chart.dart';

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2(AnimateCharts animation, {Key key})
      : _chartControl = animation,
        super(key: key);
  final AnimateCharts _chartControl;

  @override
  _LineChartSample2State createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  final fromDate = DateTime.now().subtract(Duration(days: 6));
  final toDate = DateTime.now();
  final date7 = DateTime.now().subtract(Duration(days: 6));
  final date6 = DateTime.now().subtract(Duration(days: 5));
  final date5 = DateTime.now().subtract(Duration(days: 4));
  final date4 = DateTime.now().subtract(Duration(days: 3));
  final date3 = DateTime.now().subtract(Duration(days: 2));
  final date2 = DateTime.now().subtract(Duration(days: 1));
  final date1 = DateTime.now();

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = [
      Color(0xff23b6e6),
      Color(0xff02d39a),
    ];
    return AspectRatio(
      aspectRatio: 2.50,
      child: Card(
        elevation: widget._chartControl.chartHeight.value,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(18)),
              color: Color(0xff303030)),
          // color: Color(0xff232d37)),
          child: Padding(
            padding: const EdgeInsets.only(
                right: 40.0, left: 12.0, top: 20, bottom: 10),
            child: FlChart(
              chart: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalGrid: true,
                    getDrawingVerticalGridLine: (value) {
                      return const FlLine(
                        color: Color(0xff37434d),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingHorizontalGridLine: (value) {
                      return const FlLine(
                        color: Color(0xff37434d),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        fontSize: 10,
                        fontStyle: FontStyle.normal,
                        fontFamily: 'Roboto',
                      ),
                      getTitles: (value) {
                        var tmpval = value.toInt();
                        var val =
                            DateTime.now().add(Duration(days: tmpval - 6));
                        return "${val.month}-${(val.day.toString())}";
                      },

//                          (value) {
//                        switch (value.toInt()) {
//                          case 2:
//                            return 'MAR';
//                          case 3:
//                            return 'APR';
//                          case 4:
//                            return 'MAY';
//                          case 5:
//                            return 'JUN';
//                          case 6:
//                            return 'JLY';
//                          case 7:
//                            return 'AUG';
//                          case 8:
//                            return 'SEP';
//                        }
//                        return '';
//                      },
                      margin: 8,
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      textStyle: TextStyle(
                        // fontWeight: FontWeight.w700,
                        // color: Colors.white70,
                        fontSize: 10,
                        // fontStyle: FontStyle.normal,
                        fontFamily: 'Roboto',
                      ),
                      getTitles: (value) {
                        switch (value.toInt()) {
                          case 1:
                            return '10k';
                          case 3:
                            return '30k';
                          case 5:
                            return '50k';
                        }
                        return '';
                      },
                      reservedSize: 28,
                      margin: 12,
                    ),
                  ),
                  borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: Color(0xFF37434d),
                        width: 2,
                      )),
                  minX: 1,
                  maxX: 7,
                  minY: 0,
                  maxY: 5,
                  lineTouchData: LineTouchData(
                      touchSpotThreshold: 25,
                      touchTooltipData: TouchTooltipData(
                          tooltipBgColor: Theme.of(context).cardColor,
                          getTooltipItems: (List<TouchedSpot> touchedSpots) {
                            if (touchedSpots == null) {
                              return null;
                            }

                            return touchedSpots.map((TouchedSpot touchedSpot) {
                              if (touchedSpots == null ||
                                  touchedSpot.spot == null) {
                                return null;
                              }

                              String text =
                                  touchedSpot.spot.y.toInt().toString();
                              final color = touchedSpot.getColor();
                              text = 'Value: $text';
                              return TooltipItem(
                                  text,
                                  Theme.of(context).textTheme.caption.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.bold));
                            }).toList();
                          })),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(1, widget._chartControl.chartValues(3.2, 1.6)),
                        FlSpot(2, widget._chartControl.chartValues(3.4, 2.7)),
                        FlSpot(3, widget._chartControl.chartValues(3.6, 2)),
                        FlSpot(4, widget._chartControl.chartValues(3.8, 3.4)),
                        FlSpot(5, widget._chartControl.chartValues(4, 3)),
                        FlSpot(6, widget._chartControl.chartValues(4.2, 3.6)),
                        FlSpot(7, widget._chartControl.chartValues(4.4, 2.2)),
                      ],
                      curveSmoothness: 0.2,
                      isCurved: true,
                      colors: gradientColors,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                      ),
                      belowBarData: BelowBarData(
                        show: true,
                        colors: gradientColors
                            .map((color) => color.withOpacity(0.1))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String formatAsIntOrDouble(double str) {
  final values = str.toString().split(".");
  if (values.length > 1) {
    final int intDecimal = int.parse(values[1]);
    if (intDecimal == 0) {
      return str.toInt().toString();
    }
  }
  return str.toString();
}
