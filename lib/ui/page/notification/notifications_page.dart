import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/utility.dart';
import 'package:gyansagar_frontend/model/notification_model.dart';
import 'package:gyansagar_frontend/states/notificaion/notification_state.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/p_loader.dart';
import 'package:gyansagar_frontend/ui/widget/secondary_app_bar.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key key}) : super(key: key);
  static MaterialPageRoute getRoute() {
    return MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<NotificationState>(
              create: (_) => NotificationState(),
              builder: (_, child) => NotificationPage(),
            ));
  }

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<NotificationState>(context, listen: false).getNotifications();
  }

  Widget _notificationTile(NotificationModel model) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: AppTheme.decoration(context),
        child: ListTile(
          title: Text(model.title,
              style:
                  Theme.of(context).textTheme.bodyLarge.copyWith(fontSize: 14)),
          trailing: Text(
              Utility.getPassedTime(model.createdAt.toIso8601String()),
              style:
                  Theme.of(context).textTheme.titleMedium.copyWith(fontSize: 12)),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar("Notifications"),
      body: Container(
        child: Consumer<NotificationState>(
          builder: (context, state, child) {
            if (state.isLoading) return Ploader();
            if (state.notifications.isNotEmpty)
              return ListView.builder(
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) {
                    return _notificationTile(state.notifications[index]);
                  });
            if (!(state.notifications.isNotEmpty))
              return Center(
                child: Container(
                  height: 100,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: AppTheme.outline(context),
                  width: AppTheme.fullWidth(context),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "You have no notification",
                        style: Theme.of(context).textTheme.titleLarge.copyWith(
                              color: PColors.gray,
                            ),
                      ),
                      SizedBox(height: 10),
                      // Text("Ask your teacher to add you in a batch!!",
                      //     style: Theme.of(context).textTheme.bodyText1),
                    ],
                  ),
                ),
              );
            return Ploader();
          },
        ),
      ),
    );
  }
}
