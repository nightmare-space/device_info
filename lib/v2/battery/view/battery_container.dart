import 'package:device_info/v2/battery/controller/battery_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class BatteryContainer extends StatefulWidget {
  const BatteryContainer({super.key});

  @override
  State<BatteryContainer> createState() => _BatteryContainerState();
}

class _BatteryContainerState extends State<BatteryContainer> {
  BatteryController controller = Get.put(BatteryController());

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BatteryController>(
      init: controller,
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(10.w),
          width: 200.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '电池',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12.w,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.w),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 32.w,
                        height: 66.w,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.11),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        width: 32.w,
                        height: (controller.batteryInfo.level ?? 0) / 100 * 66.w,
                        // height: 30.w,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${controller.batteryInfo.level ?? ''}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 30.w,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.11),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                          child: Center(
                            child: Text(
                              '${controller.batteryInfo.temperature ?? ''} ℃',
                            ),
                          ),
                        ),
                        SizedBox(height: 4.w),
                        Container(
                          height: 30.w,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.11),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                          child: Center(
                            child: Text(
                              '未充电',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
