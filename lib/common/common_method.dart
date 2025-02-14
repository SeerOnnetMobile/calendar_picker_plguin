import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

Future showBottomDialog(Widget widget, {required BuildContext context,Function? onDismiss, double? dialogWidth}) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.only(top: 10),
        width: dialogWidth ?? double.infinity,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            )),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [widget],
        ),
      );
    },
  );
}

Future showSmartBottomDialog(Widget widget, {onDismiss, double? dialogWidth,required Function(String errorMsg) errorCallback}) async {
  try {
    SmartDialog.show(
      alignment: Alignment.bottomCenter,
      onDismiss: () {
        if (onDismiss != null) {
          onDismiss();
        }
      },
      builder: (_) => Container(
        padding: const EdgeInsets.only(top: 10),
        width: dialogWidth ?? double.infinity,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            )),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [widget],
        ),
      ),
    );
  } catch(e) {
    errorCallback(e.toString());
  }


}


