import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/generated/l10n.dart';
import 'package:permission_handler/permission_handler.dart';

Future<PermissionStatus> requestLocationPermission(BuildContext context) async {
  final PermissionStatus permissionRequestResult =
      await Permission.location.request();
  if (permissionRequestResult != PermissionStatus.granted) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).locationDialogTitle),
        content: Text(S.of(context).locationDialogContent),
        actions: [
          FlatButton(
              onPressed: () => {Navigator.of(context).pop()},
              child: Text(S.of(context).locationDialogNo)),
          FlatButton(
              onPressed: () async {
                bool isOpened = await openAppSettings();
                if (isOpened) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(S.of(context).locationDialogYes))
        ],
      ),
    );
  }

  return await Permission.location.status;
}

Future<PermissionStatus> requestStoragePermission(BuildContext context) async {
  final PermissionStatus permissionRequestResult =
      await Permission.storage.request();
  if (permissionRequestResult != PermissionStatus.granted) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).storageDialogTitle),
        content: Text(S.of(context).storageDialogContent),
        actions: [
          FlatButton(
              onPressed: () => {Navigator.of(context).pop()},
              child: Text(S.of(context).storageDialogNo)),
          FlatButton(
              onPressed: () async {
                bool isOpened = await openAppSettings();
                if (isOpened) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(S.of(context).storageDialogNo))
        ],
      ),
    );
  }

  return await Permission.storage.status;
}
