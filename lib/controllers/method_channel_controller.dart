import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';


class MethodChannelController {
  static const platform = MethodChannel('flutter.native/helper');

  bool isOverlayPermissionGiven = false;
  bool isUsageStatPermissionGiven = false;
  bool isNotificationPermissionGiven = false;


  /// Overlay Permissions...
  /// Check overlay permissions.
  Future<bool> checkOverlayPermission() async {
    try {
      return await platform
          .invokeMethod('checkOverlayPermission')
          .then((value) {
        isOverlayPermissionGiven = value as bool;
        // Update any Riverpod state notifier if necessary
        return isOverlayPermissionGiven;
      });
    } on PlatformException catch (e) {
      // Handle exceptions
      isOverlayPermissionGiven = false;
      return isOverlayPermissionGiven;
    }
  }

  /// Ask overlay permissions.
  Future<bool> askOverlayPermission() async {
    try {
      return await platform.invokeMethod('askOverlayPermission').then((value) {
        isOverlayPermissionGiven = (value as bool);
        return isOverlayPermissionGiven;
      });
    } on PlatformException catch (e) {
      // Handle exceptions
      return false;
    }
  }

  /// Notification Permissions...
  /// Check for notification permissions.
  Future<bool> checkNotificationPermission() async {
    isNotificationPermissionGiven =
    await Permission.notification.isGranted;
    return isNotificationPermissionGiven;
  }

  /// Ask for Notification permissions.
  Future<bool> askNotificationPermission() async {
    await Permission.notification.request();
    isNotificationPermissionGiven = await Permission.notification.isGranted;
    return isNotificationPermissionGiven;
  }

  Future<bool> checkUsageStatePermission() async {
    isUsageStatPermissionGiven =
    (await UsageStats.checkUsagePermission() ?? false);
    // Update any Riverpod state notifier if necessary
    return isUsageStatPermissionGiven;
  }

  Future<bool> askUsageStatsPermission() async {
    try {
      return await platform
          .invokeMethod('askUsageStatsPermission')
          .then((value) {
        return (value as bool);
      });
    } on PlatformException catch (e) {
      // Handle exceptions
      return false;
    }
  }

  Future stopForeground() async {
    try {
      await platform.invokeMethod('stopForeground', "");
    } on PlatformException catch (e) {
      // Handle exceptions
    }
  }

}


final methodChannelControllerProvider = Provider<MethodChannelController>((ref) =>
   MethodChannelController()
);
