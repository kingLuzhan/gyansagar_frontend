import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/states/home_state.dart';
import 'package:gyansagar_frontend/ui/page/home/widget/poll_widget.dart';
import 'package:gyansagar_frontend/ui/widget/secondary_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:gyansagar_frontend/ui/kit/overlay_loader.dart';

class ViewAllPollPage extends StatelessWidget {
  const ViewAllPollPage({super.key});

  static MaterialPageRoute getRoute() {
    return MaterialPageRoute(
      builder: (_) => const ViewAllPollPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Make sure to refresh the poll list when the page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeState>().getPollList();
    });
    
    return Scaffold(
      appBar: const CustomAppBar("All Polls"),
      body: Consumer<HomeState>(
        builder: (context, state, child) {
          return Container(
            child: ListView.builder(
              itemCount: state.allPolls.length,
              itemBuilder: (context, index) {
                return PollWidget(
                  model: state.allPolls[index],
                  loader: CustomLoader(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}