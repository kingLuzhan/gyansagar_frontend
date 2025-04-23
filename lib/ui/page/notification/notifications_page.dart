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
import 'package:gyansagar_frontend/resources/service/dio_client.dart';
import 'package:gyansagar_frontend/helper/shared_preference_helper.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:gyansagar_frontend/helper/constants.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});
  static MaterialPageRoute getRoute() {
    return MaterialPageRoute(
      builder:
          (_) => ChangeNotifierProvider<NotificationState>(
            create:
                (_) => NotificationState(
                  notificationRepository: NotificationRepository(
                    ApiGatewayImpl(
                      DioClient(
                        Dio(),
                        baseEndpoint:
                            Constants.productionBaseUrl, // <-- Add this line
                        logging: true,
                      ),
                      pref: SharedPreferenceHelper.instance,
                    ),
                  ),
                ),
            builder: (_, child) => const NotificationPage(),
          ),
    );
  }

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    // Fix: Delay fetchNotifications until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationState>(
        context,
        listen: false,
      ).fetchNotifications();
    });
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isRead) {
      await Provider.of<NotificationState>(
        context,
        listen: false,
      ).markAsRead(notification.id);
    }
  }

  Future<void> _markAllAsRead() async {
    await Provider.of<NotificationState>(
      context,
      listen: false,
    ).markAllAsRead();
  }

  Widget _notificationTile(NotificationModel model) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: AppTheme.decoration(context),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          model.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 14,
            fontWeight: model.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle:
            model.body != null && model.body!.isNotEmpty
                ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    model.body!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
                : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('MMM dd, yyyy').format(model.createdAt),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 4),
            if (!model.isRead)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: () => _markAsRead(model),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: Consumer<NotificationState>(
        builder: (context, state, child) {
          if (state.isLoading) return const Ploader();
          if (state.notifications.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: () => state.fetchNotifications(),
              child: ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  return _notificationTile(state.notifications[index]);
                },
              ),
            );
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
                      "You have no notifications",
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: PColors.gray),
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
    );
  }
}
