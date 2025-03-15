import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/utility.dart';
import 'package:gyansagar_frontend/model/notification_model.dart';
import 'package:gyansagar_frontend/states/notificaion/notification_state.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/p_loader.dart';
import 'package:gyansagar_frontend/ui/widget/secondary_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:gyansagar_frontend/resources/repository/notification_repository.dart';
import 'package:gyansagar_frontend/resources/service/api_gateway_impl.dart';
import 'package:gyansagar_frontend/resources/service/dio_client.dart'; // Ensure this is available for DioClient
import 'package:gyansagar_frontend/helper/shared_preference_helper.dart'; // Ensure this is available for SharedPreferenceHelper
import 'package:dio/dio.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});
  static MaterialPageRoute getRoute() {
    return MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<NotificationState>(
          create: (_) => NotificationState(
            notificationRepository: NotificationRepository(
              ApiGatewayImpl(
                DioClient(Dio(), logging: true), // Provide Dio instance and other parameters
                pref: SharedPreferenceHelper.instance, // Use the singleton instance
              ),
            ),
          ),
          builder: (_, child) => const NotificationPage(),
        ));
  }

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<NotificationState>(context, listen: false).fetchNotifications();
  }

  Widget _notificationTile(NotificationModel model) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: AppTheme.decoration(context),
        child: ListTile(
          title: Text(model.title,
              style:
              Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14)),
          trailing: Text(
              Utility.getPassedTime(model.createdAt.toIso8601String()),
              style:
              Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 12)),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar("Notifications"),
      body: Container(
        child: Consumer<NotificationState>(
          builder: (context, state, child) {
            if (state.isLoading) return const Ploader();
            if (state.notifications.isNotEmpty) {
              return ListView.builder(
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) {
                    return _notificationTile(state.notifications[index]);
                  });
            }
            if (state.notifications.isEmpty) {
              return Center(
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: AppTheme.outline(context),
                  width: AppTheme.fullWidth(context),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "You have no notification",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: PColors.gray,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            }
            return const Ploader();
          },
        ),
      ),
    );
  }
}