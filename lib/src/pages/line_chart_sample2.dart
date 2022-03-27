import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({Key key, this.datas}) : super(key: key);
  final List<int> datas;

  @override
  _LineChartSample2State createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.60,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              color: Theme.of(context).primaryColor.withOpacity(0.11),
            ),
            child: LineChart(
              mainData(),
            ),
          ),
        ),
      ],
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );
    String text;
    switch (value.toInt()) {
      case 1000:
        text = '1000';
        break;
      case 2000:
        text = '2000';
        break;
      default:
        return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.left,
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1000,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Theme.of(context).colorScheme.outline,
            strokeWidth: 1,
          );
        },
        // getDrawingVerticalLine: (value) {
        //   return FlLine(
        //     color: const Color(0xff37434d),
        //     strokeWidth: 1,
        //   );
        // },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 30,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        // bottomTitles: AxisTitles(
        //   sideTitles: SideTitles(
        //     showTitles: true,
        //     interval: 1,
        //     getTitlesWidget: (double value, TitleMeta meta) {
        //       const style = TextStyle(
        //         color: Color(0xff67727d),
        //         fontWeight: FontWeight.bold,
        //         fontSize: 8,
        //       );
        //       // String text;
        //       // switch (value.toInt()) {
        //       //   case 1000:
        //       //     text = '1000';
        //       //     break;
        //       //   case 2000:
        //       //     text = '2000';
        //       //     break;
        //       //   default:
        //       //     return Container();
        //       // }

        //       return Text(
        //         value.toString(),
        //         style: style,
        //         textAlign: TextAlign.left,
        //       );
        //     },
        //     reservedSize: 26,
        //   ),
        // ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(
          color: const Color(0xff37434d),
          width: 1,
        ),
      ),
      minX: 0,
      maxX: 10,
      minY: 0,
      maxY: 2500,
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (int i = 0; i < widget.datas.length; i++)
              FlSpot(
                i.toDouble(),
                widget.datas[i].toDouble(),
              ),
          ],
          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
  }
}
