import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/model/batch_model.dart';
import 'package:gyansagar_frontend/ui/kit/overlay_loader.dart';
import 'package:gyansagar_frontend/states/quiz/quiz_state.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/quiz/quiz_list_page.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/p_loader.dart';
import 'package:provider/provider.dart';

class BatchAssignmentPage extends StatelessWidget {
  const BatchAssignmentPage({
    Key? key,
    required this.model,
    required this.loader,
  }) : super(key: key);

  final BatchModel model;
  final CustomLoader loader;

  static MaterialPageRoute getRoute(BatchModel model, CustomLoader loader) {
    return MaterialPageRoute(
        builder: (_) => BatchAssignmentPage(model: model, loader: loader));
  }

  Widget noQuiz(BuildContext context) {
    return Container(
      height: 100,
      margin: EdgeInsets.symmetric(horizontal: 16),
      width: AppTheme.fullWidth(context),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Nothing to see here",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: PColors.gray,
              )),
          SizedBox(height: 10),
          Text("No Assignment is uploaded yet for this batch!!",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizState>(
      builder: (context, state, child) {
        if (state.isBusy) {
          return Ploader();
        }
        if (state.assignmentsList.isEmpty) {
          return noQuiz(context);
        }
        return QuizListPage(loader: loader);
      },
    );
  }
}