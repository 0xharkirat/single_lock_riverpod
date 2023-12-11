import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:single_lock_riverpod/controllers/method_channel_controller.dart';
import 'package:single_lock_riverpod/controllers/permission_controller.dart';
import 'package:single_lock_riverpod/widgets/ask_permission_dialog.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String welcomeText = "No permissions";

  void _init() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await ref.read(permissionControllerProvider).getPermission(Permission.ignoreBatteryOptimizations);
      await getPermissions();
      updateWelcomeText();
    });
  }

  void updateWelcomeText() async {
    bool hasPermissions = await checkPermissions();
    setState(() {
      welcomeText = hasPermissions ? "Permissions Granted" : "No Permissions";
    });
  }

   Future<void> getPermissions() async {
    if (!(await checkPermissions())) {
      askPermissionBottomSheet(context);
    }
  }

  Future<bool> checkPermissions() async {
    final methodChannelController = ref.read(methodChannelControllerProvider);
    return await methodChannelController.checkNotificationPermission() &&
        await methodChannelController.checkOverlayPermission() &&
        await methodChannelController.checkUsageStatePermission();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Single Lock"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ref.read(methodChannelControllerProvider).startForegroundService();
          },
          child: Text('Start Foreground Service'),
        ),
      ),
    );
  }
}

