import 'package:android_api_server_client/android_api_server_client.dart';
import 'package:device_info/v2/cpu_gpu/view/cpu_line_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:global_repository/global_repository.dart';

import '../controller/cpu_controller.dart';

class CPUDetailContainer extends StatefulWidget {
  const CPUDetailContainer({super.key});

  @override
  State<CPUDetailContainer> createState() => _CPUDetailContainerState();
}

class _CPUDetailContainerState extends State<CPUDetailContainer> {
  CPUController controller = Get.put(CPUController());

  @override
  void dispose() {
    Get.delete<CPUController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CPUController>(
      builder: (controller) {
        List<CPU_GPU_Info> infos = controller.cpuGpuInfoQueue.items;
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: LayoutBuilder(builder: (context, con) {
                return Wrap(
                  spacing: 4,
                  runSpacing: 12,
                  children: [
                    if (infos.isEmpty)
                      const SizedBox()
                    else
                      for (int i = 0; i < infos.last.cpu.length; i++)
                        Container(
                          width: (con.maxWidth - 4 * 3) / 4,
                          // height: 100,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${infos.last.cpu[i] / 1000}',
                                    style: TextStyle(
                                      fontSize: 12.w,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    "Mhz",
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.w),
                              Builder(builder: (context) {
                                List<double> datas = [];
                                for (CPU_GPU_Info info in infos) {
                                  datas.add(info.cpu[i] / 1000);
                                }
                                return CPULineChart(datas: datas);
                              }),
                              SizedBox(height: 8.w),
                            ],
                          ),
                        ),
                  ],
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
