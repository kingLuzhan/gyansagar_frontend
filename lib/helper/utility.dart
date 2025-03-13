import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Utility {
  static void displaySnackbar(BuildContext context,
      {String msg = "Feature is under development",
        GlobalKey<ScaffoldMessengerState>? key}) {
    final snackBar = SnackBar(content: Text(msg));

    if (key?.currentState != null) {
      key!.currentState!.hideCurrentSnackBar();
      key.currentState!.showSnackBar(snackBar);
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  static Future<void> launchOnWeb(String? url) async {
    if (url == null || url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static String toDMYformat(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String toDMformat(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  static String toFormattedDate2(DateTime date) {
    return DateFormat('dd-MMM-yyyy hh:mm a').format(date);
  }

  static String toFormattedDate3(DateTime date) {
    return DateFormat('yyyy-MM-dd hh:mm').format(date);
  }

  static String toTimeOfDay(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String toTimeOfDate(DateTime date) {
    return DateFormat('hh:mm a dd MMM').format(date);
  }

  static String timeFrom24(String date) {
    try {
      final parts = date.split(":");
      if (parts.length != 2) return "Invalid Time";
      final hr = int.tryParse(parts[0]) ?? 0;
      final mm = int.tryParse(parts[1]) ?? 0;
      final time = DateTime(2020, 1, 1, hr, mm);
      return DateFormat('hh:mm a').format(time);
    } catch (e) {
      return "Invalid Time";
    }
  }

  static String getPassedTime(String date) {
    if (date.isEmpty) return '';

    try {
      DateTime dt = DateTime.parse(date).toLocal();
      if (DateTime.now().isBefore(dt)) {
        return DateFormat.jm().format(dt);
      }

      var dur = DateTime.now().difference(dt);
      if (dur.inDays > 0) return '${dur.inDays} d';
      if (dur.inHours > 0) return '${dur.inHours} h';
      if (dur.inMinutes > 0) return '${dur.inMinutes} m';
      if (dur.inSeconds > 0) return '${dur.inSeconds} s';

      return 'now';
    } catch (e) {
      return "Invalid Date";
    }
  }
}
