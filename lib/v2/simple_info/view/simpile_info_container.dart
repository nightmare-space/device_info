import 'package:device_info/v2/simple_info/controller/simile_info_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class SimpileInfoContainer extends StatefulWidget {
  const SimpileInfoContainer({super.key});

  @override
  State<SimpileInfoContainer> createState() => _SimpileInfoContainerState();
}

class _SimpileInfoContainerState extends State<SimpileInfoContainer> {
  SimileInfoController controller = Get.put(SimileInfoController());

  @override
  void initState() {
    super.initState();
    controller.getSimpleInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SimileInfoController>(builder: (_) {
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
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
              child: Text('ID ${controller.info.deviceId ?? ''}'),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
              child: Text('Android ${controller.info.androidVersion}'),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
              child: Text('已开机 ${controller.info.uptime}'),
            ),
          ],
        ),
      );
    });
  }
}
