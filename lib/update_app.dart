import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_version_model.dart';

class UpdateApp extends StatefulWidget {
  final Widget child;

  const UpdateApp({super.key, required this.child});

  @override
  UpdateAppState createState() => UpdateAppState();
}

String UPDATE_DIALOG_KEY_NAME = "UpdateDialogKeyName";

class UpdateAppState extends State<UpdateApp> {
  @override
  void initState() {
    super.initState();
    checkLatestVersion(context);
  }

  AppVersion? appVersion;
  checkLatestVersion(BuildContext context) async {
    await Future.delayed(Duration(seconds: 5));

    //Add query here to get the minimum and latest app version
    appVersion = await AppVersion.fetchLatestVersion();

    if (appVersion == null) {
      return;
    }

    Version minAppVersion = Version.parse(appVersion!.minAppVersion);
    Version latestAppVersion = Version.parse(appVersion!.version);

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Version currentVersion = Version.parse(packageInfo.version);
    if (minAppVersion > currentVersion) {
      _showCompulsoryUpdateDialog(
        context: context,
        message: "للاستمرار يجب تحديث التطبيق\n${appVersion!.about ?? ""}",
      );
    } else if (latestAppVersion > currentVersion) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      bool? showUpdates = false;
      showUpdates = sharedPreferences.getBool(UPDATE_DIALOG_KEY_NAME);
      if (showUpdates != null && showUpdates == false) {
        return;
      }

      _showOptionalUpdateDialog(
        context: context,
        message: "تحديث جديد متاح\n${appVersion!.about ?? ""}",
      );
    }
  }

  _showOptionalUpdateDialog({
    required BuildContext context,
    required String message,
  }) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder:
          (BuildContext context) => DoNotAskAgainDialog(
            dialogKeyName: UPDATE_DIALOG_KEY_NAME,
            title: "تحديث التطبيق",
            subTitle: message,
            positiveButtonText: "تحديث الآن",
            negativeButtonText: "لاحقاً",
            onPositiveButtonClicked: _onUpdateNowClicked,
            doNotAskAgainText: "لا تسأل مرة أخرى",
          ),
    );
  }

  Future<void> _onUpdateNowClicked() async {
    print('Update now clicked');
  }

  _showCompulsoryUpdateDialog({
    required BuildContext context,
    required String message,
  }) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "تحديث التطبيق";
        String btnLabel = "تحديث الآن";
        return Platform.isIOS
            ? CupertinoAlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: _onUpdateNowClicked,
                  child: Text(btnLabel),
                ),
              ],
            )
            : AlertDialog(
              title: Text(title, style: TextStyle(fontSize: 22)),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  onPressed: _onUpdateNowClicked,
                  child: Text(btnLabel, style: TextStyle(color: Colors.blue)),
                ),
              ],
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class DoNotAskAgainDialog extends StatefulWidget {
  final String title, subTitle, positiveButtonText, negativeButtonText;
  final VoidCallback onPositiveButtonClicked;
  final String doNotAskAgainText;
  final String dialogKeyName;

  const DoNotAskAgainDialog({
    super.key,
    this.doNotAskAgainText = 'لا تسأل مرة أخرى',
    required this.dialogKeyName,
    required this.title,
    required this.subTitle,
    required this.positiveButtonText,
    required this.negativeButtonText,
    required this.onPositiveButtonClicked,
  });

  @override
  DoNotAskAgainDialogState createState() => DoNotAskAgainDialogState();
}

class DoNotAskAgainDialogState extends State<DoNotAskAgainDialog> {
  bool doNotAskAgain = false;

  _updateDoNotShowAgain() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(UPDATE_DIALOG_KEY_NAME, false);
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text(widget.title),
        content: Text(widget.subTitle),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: widget.onPositiveButtonClicked,
            child: Text(widget.positiveButtonText),
          ),
          CupertinoDialogAction(
            child: Text(widget.doNotAskAgainText),
            onPressed: () {
              Navigator.pop(context);
              _updateDoNotShowAgain();
            },
          ),
          CupertinoDialogAction(
            child: Text(widget.negativeButtonText),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    }
    return AlertDialog(
      title: Text(widget.title, style: TextStyle(fontSize: 24)),
      content: FittedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.subTitle, style: TextStyle(fontSize: 14)),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: doNotAskAgain,

                    onChanged: (val) {
                      setState(() {
                        doNotAskAgain = val ?? false;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      doNotAskAgain = doNotAskAgain == false;
                    });
                  },
                  child: Text(
                    widget.doNotAskAgainText,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: doNotAskAgain ? null : widget.onPositiveButtonClicked,
          child: Text(
            widget.positiveButtonText,
            style: TextStyle(color: doNotAskAgain ? null : Colors.blue),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            if (doNotAskAgain) {
              _updateDoNotShowAgain();
            }
          },
          child: Text(
            widget.negativeButtonText,
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
