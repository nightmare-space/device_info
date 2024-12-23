import 'package:device_info/canvas/circle_progress.dart';
import 'package:device_info/utils/get_ratio_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import '../controller/ram_controller.dart';

class RamContainer extends StatefulWidget {
  const RamContainer({super.key});

  @override
  State<RamContainer> createState() => _RamContainerState();
}

class _RamContainerState extends State<RamContainer> {
  RamController controller = Get.put(RamController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(10),
          width: 200.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'RAM:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.w,
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Center(
                    child: SizedBox(
                      width: 50.w,
                      height: 50.w,
                      child: CustomPaint(
                        size: Size(50.w, 50.w),
                        painter: CircleProgress(
                          controller.ramInfo.radio,
                          6.0,
                          getColor(controller.ramInfo.radio),
                          Theme.of(context).primaryColor.withOpacity(0.11),
                        ),
                        child: Center(
                          child: Text(
                            (controller.ramInfo.radio * 100).toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 10.w,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              GetBuilder<RamController>(builder: (_) {
                return Column(
                  children: [
                    SizedBox(height: 8.w),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          FileUtil.formatBytes(controller.ramInfo.free! * 1000),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12.w,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' / ',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12.w,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          FileUtil.formatBytes(controller.ramInfo.total! * 1000),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12.w,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
