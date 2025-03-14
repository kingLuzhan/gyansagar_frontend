import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/images.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/p_button.dart';

class Alert {
  static void success(BuildContext context,
      {required String message,
        required String title,
        double height = 150,
        required VoidCallback onPressed}) async {
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (_) =>
          Dialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              height: height,
              width: MediaQuery
                  .of(context)
                  .size
                  .width * .75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(title,
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 16),
                  Text(
                    message,
                    style: Theme
                        .of(context)
                        .typography
                        .dense
                        .bodyMedium
                        ?.copyWith(
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onPressed();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Theme
                          .of(context)
                          .primaryColor,
                    ),
                    child: Text("OK",
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: theme.colorScheme.onPrimary)),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  static void yesOrNo(BuildContext context,
      {required String message,
        required String title,
        required VoidCallback onYes,
        required VoidCallback onCancel,
        bool barrierDismissible = true}) async {
    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) =>
          Dialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              width: MediaQuery
                  .of(context)
                  .size
                  .width * .75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(title,
                      style: Theme
                          .of(context)
                          .typography
                          .dense
                          .titleLarge
                          ?.copyWith(color: Colors.black)),
                  SizedBox(height: 12),
                  Text(message,
                      style: Theme
                          .of(context)
                          .typography
                          .dense
                          .bodyMedium
                          ?.copyWith(
                          color: Colors.black, fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  OverflowBar(
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onCancel();
                          },
                          child: Text("Cancel")),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onYes();
                        },
                        child: Text("Confirm", textAlign: TextAlign.center),
                        style: ElevatedButton.styleFrom(
                          elevation: 1, backgroundColor: Theme
                            .of(context)
                            .primaryColor,
                          padding: EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
    );
  }

  static void dialog(BuildContext context,
      {required String title,
        required Widget child,
        required VoidCallback onPressed,
        Color titleBackGround = PColors.orange,
        String buttonText = "Ok",
        bool enableCrossButton = true}) async {
    final theme = Theme.of(context);
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) =>
          Dialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: Wrap(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 16),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          decoration: BoxDecoration(
                              color: titleBackGround,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width - 160,
                                  child: Text(
                                    title,
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                        color: theme.colorScheme.onPrimary),
                                  )).vP8,
                              Image.asset(Images.cross, height: 30)
                                  .p(8)
                                  .ripple(() {
                                if (enableCrossButton) Navigator.pop(context);
                              })
                            ],
                          )),
                      child,
                      SizedBox(
                        height: 12,
                      ),
                      PFlatButton(
                        label: buttonText,
                        onPressed: onPressed,
                        isLoading: ValueNotifier(
                            false), // Wrap bool in ValueNotifier
                      ).hP16
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}