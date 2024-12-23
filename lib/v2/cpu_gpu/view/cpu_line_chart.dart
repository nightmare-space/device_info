import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class CPULineChart extends StatefulWidget {
  const CPULineChart({super.key, this.datas});
  final List<double>? datas;

  @override
  State createState() => _CPULineChartState();
}

class _CPULineChartState extends State<CPULineChart> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.5,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.11),
        ),
        child: LineChart(
          mainData(),
          duration: Duration.zero,
        ),
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      minX: 0,
      maxX: 9,
      minY: 0,
      maxY: 3000,
      // when mouse hover
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              return LineTooltipItem(
                '${touchedSpot.y}',
                TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12.w,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
          getTooltipColor: (touchedSpot) {
            return Theme.of(context).colorScheme.primary.withOpacity(0.6);
          },
        ),
        // distanceCalculator: (touchPoint, spotPixelCoordinates) {
        //   return (touchPoint - spotPixelCoordinates).distance;
        // },
        touchCallback: (p0, p1) {},
        handleBuiltInTouches: true,
      ),
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
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            strokeWidth: 0.4,
            dashArray: [8, 4],
          );
        },
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
            getTitlesWidget: (value, meta) {
              return SizedBox();
            },
            reservedSize: 0.w,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: widget.datas!.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.toDouble());
          }).toList(),
          isCurved: false,
          color: Theme.of(context).colorScheme.primary,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
