import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionControllerProvider = Provider<PermissionController>((ref) {
  return PermissionController();
});

class PermissionController {
  PermissionController();

  Future<void> getPermission(Permission permission) async {
    var status;
    if (!(await permission.isGranted)) {
      status = await permission.request();
      print("___________________-----$status-----___________________1");
    } else {
      print("___________________-----Granted-----___________________2");
    }
    print("$status");
  }
}
