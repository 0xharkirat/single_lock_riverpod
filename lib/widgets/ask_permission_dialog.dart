import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:single_lock_riverpod/controllers/method_channel_controller.dart';

askPermissionBottomSheet(context) {
  return showModalBottomSheet(
    barrierColor: Colors.black.withOpacity(0.8),
    context: context,
    isDismissible: false,
    isScrollControlled: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const AskPermissionBottomSheet();
    },
  );
}

class AskPermissionBottomSheet extends ConsumerWidget {
  const AskPermissionBottomSheet({Key? key}) : super(key: key);

  Widget permissionWidget(context, name, bool permission) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 6,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        // height: 40.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).primaryColor,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 6,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "$name",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              // if (permission)
              Icon(
                Icons.check_circle,
                color: !permission
                    ? Colors.grey[700]
                    : Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methodChannelController = ref.read(methodChannelControllerProvider);

    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Text(
                          "AppLock needs system permissions to work with.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (!methodChannelController.isOverlayPermissionGiven)
                              GestureDetector(
                                onTap: () {
                                  methodChannelController.askOverlayPermission();
                                },
                                child: permissionWidget(
                                  context,
                                  "System overlay",
                                  methodChannelController.isOverlayPermissionGiven,
                                ),
                              ),
                            if (!methodChannelController.isUsageStatPermissionGiven)
                              GestureDetector(
                                onTap: () {
                                  methodChannelController.askUsageStatsPermission();
                                },
                                child: permissionWidget(
                                  context,
                                  "Usage accesss",
                                  methodChannelController.isUsageStatPermissionGiven,
                                ),
                              ),
                            if (!methodChannelController.isNotificationPermissionGiven)
                              GestureDetector(
                                onTap: () {
                                  methodChannelController.askNotificationPermission();
                                },
                                child: permissionWidget(
                                  context,
                                  "Push notification",
                                  methodChannelController.isNotificationPermissionGiven,
                                ),
                              ),
                          ],
                        ),
                      ),
                      MaterialButton(
                        color: Theme.of(context).primaryColor,
                        onPressed: () async {
                          if (await methodChannelController.checkOverlayPermission() &&
                              await methodChannelController.checkUsageStatePermission() &&
                              await methodChannelController.checkNotificationPermission()) {
                            Navigator.pop(context);
                          } else {
                            Fluttertoast.showToast(
                                msg: "Required permissions not given !");
                          }
                        },
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
