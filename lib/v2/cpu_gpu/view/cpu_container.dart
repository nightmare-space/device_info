import 'package:device_info/canvas/circle_progress.dart';
import 'package:device_info/utils/get_ratio_color.dart';
import 'package:device_info/v2/cpu_gpu/controller/cpu_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'cpu_detail_container.dart';

class CPUContainer extends StatefulWidget {
  const CPUContainer({super.key});

  @override
  State<CPUContainer> createState() => _CPUContainerState();
}

class _CPUContainerState extends State<CPUContainer> {
  CPUController controller = Get.put(CPUController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CPUController>(
      init: controller,
      builder: (_) {
        return Column(
          children: [
            SizedBox(
              height: 60.w,
              child: Stack(
                children: [
                  LineChartSample(data: controller.cpuUsuages.items),
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'CPU:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 20.w),
                          Builder(builder: (context) {
                            double value = 0;
                            if (controller.cpuUsuages.items.isNotEmpty) {
                              value = controller.cpuUsuages.items.last;
                            }
                            return Center(
                              child: SizedBox(
                                width: 50.w,
                                height: 50.w,
                                child: CustomPaint(
                                  size: Size(50.w, 50.w),
                                  painter: CircleProgress(
                                    value / 100,
                                    6.0,
                                    getColor(controller.gpuUsuage / 100),
                                    Theme.of(context).primaryColor.withOpacity(0.11),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${value.toStringAsFixed(1)}%',
                                      style: TextStyle(fontSize: 10.w, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.w),
            Container(
              height: 60.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'GPU:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 20.w),
                  Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CustomPaint(
                        size: const Size(50.0, 50.0),
                        painter: CircleProgress(
                          controller.gpuUsuage / 100,
                          6.0,
                          getColor(controller.gpuUsuage / 100),
                          Theme.of(context).primaryColor.withOpacity(0.11),
                        ),
                        child: Center(
                          child: Text(
                            '${controller.gpuUsuage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

String toPercentage(double scale) {
  if (scale.isNaN) {
    return '0%';
  }
  return '${(scale * 100).toInt()}%';
}

class LineChartSample extends StatelessWidget {
  final List<double> data;

  const LineChartSample({super.key, required this.data});
  double getNextMultipleOfTen(int input) {
    return ((input + 9) ~/ 10) * 10;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3.2,
      child: SizedBox(
        width: double.infinity,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 29,
            minY: 0,
            maxY: data.isEmpty ? 0 : getNextMultipleOfTen(data.max.toInt()) + 5,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((touchedSpot) {
                    return LineTooltipItem(
                      '${touchedSpot.y.toStringAsFixed(1)}%',
                      TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipColor: (touchedSpot) {
                  return Theme.of(context).colorScheme.primary.withOpacity(0.6);
                },
              ),
              touchCallback: (p0, p1) {},
              handleBuiltInTouches: true,
            ),
            lineBarsData: [
              LineChartBarData(
                spots: data.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value.toDouble());
                }).toList(),
                isCurved: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 0.w,
                  getTitlesWidget: (value, meta) {
                    return SizedBox();
                  },
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    TextStyle style = TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.w,
                    );
                    return SizedBox();
                    String text;
                    if (value.toInt() > 100) {
                      text = '';
                    } else if (value.toInt() % 10 == 0) {
                      text = '${value.toInt()}';
                    } else {
                      text = '';
                    }
                    return Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        text,
                        style: style,
                        textAlign: TextAlign.left,
                      ),
                    );
                  },
                  reservedSize: 10.w,
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: false,
              drawVerticalLine: true,
              horizontalInterval: 1000,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2,
                );
              },
              // getDrawingVerticalLine: (value) {
              //   return FlLine(
              //     color: const Color(0xff37434d),
              //     strokeWidth: 1,
              //   );
              // },
            ),
          ),
          duration: Duration.zero,
        ),
      ),
    );
  }
}
