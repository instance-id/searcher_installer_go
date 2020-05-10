import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:searcher_installer/animations/charts/animate_chart.dart';
import 'package:searcher_installer/helpers/charts/chart_source/bezier/bezier_chart_config.dart';
import 'package:searcher_installer/helpers/charts/chart_source/bezier/bezier_chart_widget.dart';
import 'package:searcher_installer/helpers/charts/chart_source/bezier/bezier_line.dart';

class StatsLineChart extends StatefulWidget {
  StatsLineChart(AnimateCharts animation) : _chartController = animation;
  final AnimateCharts _chartController;

  @override
  _StatsLineChartState createState() => _StatsLineChartState();
}

// ignore: camel_case_types
class _StatsLineChartState extends State<StatsLineChart> {
  List<DataPoint> _items;
  List<double> _xAxis;

  void _loadData() async {
    await Future.delayed(Duration(seconds: 0));
    final String data = '''[
        {"Day":21,"Value":"50"},
        {"Day":22,"Value":"20"},
        {"Day":23,"Value":"60"},
        {"Day":24,"Value":"80"},
        {"Day":25,"Value":"100"},
        {"Day":26,"Value":"45"},
        {"Day":27,"Value":"60"}]''';
    final List list = json.decode(data);
    setState(() {
      _items = list
          .map((item) => DataPoint(
              value: double.parse(item["Value"].toString()),
              xAxis: double.parse(item["Day"].toString())))
          .toList();
      _xAxis =
          list.map((item) => double.parse(item["Day"].toString())).toList();
    });
  }

  @override
  void initState() {
    _loadData();
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
    //var pointerStatus = Provider.of<PointerStatus>(context);

    return Center(
      child: _items != null
          ? Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "7 day statistics",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  _buildChart(
                    BezierChartScale.CUSTOM,
                    context,
                    LinearGradient(
                      colors: [
                        Color(0x00303030),
                        Color(0x22000000),
                        Color(0x44000000),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ],
              ),
            )
          : CircularProgressIndicator(),
    );
  }

  _buildChart(
      BezierChartScale scale, BuildContext context, LinearGradient gradient) {
    return Center(
      child: Card(
        elevation: widget._chartController.chartHeight.value,
        //margin: EdgeInsets.all(10.0),
        child: Container(
          //color: Color(0x22303030),
          height: MediaQuery.of(context).size.height * 0.3,
          width: MediaQuery.of(context).size.width,
          child: BezierChart(
            bezierChartScale: scale,
//            fromDate: fromDate,
//            toDate: toDate,
            selectedDate: date1,
//            footerDateTimeBuilder:
//                (DateTime value, BezierChartScale scaleType) {
//              final newFormat = intl.DateFormat('MM/dd');
//              return newFormat.format(value);
//            },
            xAxisCustomValues: [0, 1, 2, 3, 4, 5, 6],
//              date7.day.truncateToDouble(),
//              date6.day.truncateToDouble(),
//              date5.day.truncateToDouble(),
//              date4.day.truncateToDouble(),
//              date3.day.truncateToDouble(),
//              date2.day.truncateToDouble(),
//              date1.day.truncateToDouble(),
            footerValueBuilder: (double value) {
              var tmpval = value.toInt();
              var val = DateTime.now().add(Duration(days: tmpval - 6));
              return "${DateTime.now().month.toString()}-${formatAsIntOrDouble(val.day.ceilToDouble())}";
            },
            series: [
              BezierLine(
                label: "Copied",
                data: // _items,
                    [
                  DataPoint<double>(
                      value: widget._chartController
                          .chartValues(date7.day.truncateToDouble(), 10.0),
                      xAxis: date7.day.truncateToDouble()),
                  DataPoint<double>(
                      value: widget._chartController
                          .chartValues(date6.day.truncateToDouble(), 30.0),
                      xAxis: date6.day.truncateToDouble()),
                  DataPoint<double>(
                      value: widget._chartController
                          .chartValues(date5.day.truncateToDouble(), 50),
                      xAxis: date5.day.truncateToDouble()),
                  DataPoint<double>(
                      value: widget._chartController
                          .chartValues(date4.day.truncateToDouble(), 20),
                      xAxis: date4.day.truncateToDouble()),
                  DataPoint<double>(
                      value: widget._chartController
                          .chartValues(date3.day.truncateToDouble(), 80),
                      xAxis: date3.day.truncateToDouble()),
                  DataPoint<double>(
                      value: widget._chartController
                          .chartValues(date2.day.truncateToDouble(), 14),
                      xAxis: date2.day.truncateToDouble()),
                  DataPoint<double>(
                      value: widget._chartController
                          .chartValues(date1.day.truncateToDouble(), 30),
                      xAxis: date1.day.truncateToDouble()),
                ],
                onMissingValue: (dateTime) {
                  return 0.0;
                },
              ),
              BezierLine(
                label: "Error",
                lineColor: Colors.blue,
                data: [
                  DataPoint<double>(
                      value: 20, xAxis: date7.day.truncateToDouble()),
                  DataPoint<double>(
                      value: 25, xAxis: date6.day.truncateToDouble()),
                  DataPoint<double>(
                      value: 75, xAxis: date5.day.truncateToDouble()),
                  DataPoint<double>(
                      value: 80, xAxis: date4.day.truncateToDouble()),
                  DataPoint<double>(
                      value: 20, xAxis: date3.day.truncateToDouble()),
                  DataPoint<double>(
                      value: 60, xAxis: date2.day.truncateToDouble()),
                  DataPoint<double>(
                      value: 47, xAxis: date1.day.truncateToDouble()),
                ],
                onMissingValue: (dateTime) {
                  return 0.0;
                },
              ),
            ],
            config: BezierChartConfig(
              displayYAxis: true,
              displayLinesXAxis: false,
              startYAxisFromNonZeroValue: false,
              backgroundColor: Color(0x00000000),
              showDataPoints: true,
              xLinesColor: Colors.blue,
              stepsYAxis: 10,
              verticalIndicatorStrokeWidth: 3.0,
              verticalIndicatorColor: Colors.black45,
              showVerticalIndicator: true,
              verticalIndicatorFixedPosition: false,
              backgroundGradient: gradient,
              snap: false,
              mouseHover: true,
              pinchZoom: false,
              footerHeight: 30.0,
              contentWidth: MediaQuery.of(context).size.width / 2,
              // ---------------------------------------------------- Visual ---
              xAxisTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontStyle: FontStyle.normal,
                fontFamily: 'Roboto',
              ),
              yAxisTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontStyle: FontStyle.normal,
                fontFamily: 'Roboto',
              ),
              bubbleIndicatorColor: Colors.white30.withOpacity(0.9),
              bubbleIndicatorLabelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontSize: 10,
                fontStyle: FontStyle.normal,
                fontFamily: 'Roboto',
              ),
              bubbleIndicatorTitleStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontSize: 10,
                fontStyle: FontStyle.normal,
                fontFamily: 'Roboto',
              ),
              bubbleIndicatorValueStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontSize: 12,
                fontStyle: FontStyle.normal,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
