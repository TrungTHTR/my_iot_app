import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_iot_app/presentation/widgets/device_card.dart';

import '../providers/device_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceListProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Smart Home'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Row(children: const [Icon(Icons.cloud_done), SizedBox(width: 8), Text('Sync 88%')]),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(14.0),
        child: GridView.builder(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          itemCount: devices.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: .95,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, i) {
            final d = devices[i];
            return DeviceCard(device: d, index: i);
          },
        ),
      ),
      bottomNavigationBar: Container(
        height: 58,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Expanded(
              child: IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
            ),
            Expanded(
              child: IconButton(onPressed: () {}, icon: const Icon(Icons.science)),
            ),
            Expanded(
              child: IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
            ),
          ],
        ),
      ),
    );
  }
}
