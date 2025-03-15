import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/model/quiz_model.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:flutter/services.dart';

class QuizSolutionPage extends StatelessWidget {
  const QuizSolutionPage({super.key, required this.model});
  final QuizDetailModel model;

  static MaterialPageRoute getRoute(QuizDetailModel model) {
    return MaterialPageRoute(
      builder: (_) => QuizSolutionPage(
        model: model,
      ),
    );
  }

  Widget _questionTile(BuildContext context, Question model) {
    final correct = model.selectedAnswer == model.answer;
    final unAnswered = model.selectedAnswer == null;
    if (unAnswered) {
      return _unAnswered(context, model);
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: correct ? AppTheme.outlineSucess(context) : AppTheme.outlineError(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppTheme.fullWidth(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            color: correct ? PColors.green.withOpacity(.3) : PColors.red.withOpacity(.3),
            child: Text(model.statement, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text("Your Answer", style: Theme.of(context).textTheme.titleSmall).hP16,
          Text(model.selectedAnswer ?? '', style: Theme.of(context).textTheme.titleMedium).hP16,
          if (!correct) ...[
            const SizedBox(height: 8),
            Divider(
              height: 12,
              color: unAnswered ? Theme.of(context).primaryColor : PColors.red.withOpacity(.3),
              thickness: 1,
            ),
            const SizedBox(height: 8),
            Text("Correct Answer", style: Theme.of(context).textTheme.titleSmall).hP16,
            Text(model.answer, style: Theme.of(context).textTheme.titleMedium).hP16,
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _unAnswered(BuildContext context, Question model) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppTheme.outlinePrimary(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppTheme.fullWidth(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            color: Theme.of(context).primaryColor,
            child: Text(model.statement, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text("Unanswered", style: Theme.of(context).textTheme.titleSmall).hP16,
          const SizedBox(height: 8),
          Divider(
            height: 12,
            color: Theme.of(context).primaryColor,
            thickness: 1,
          ),
          const SizedBox(height: 8),
          Text("Correct Answer", style: Theme.of(context).textTheme.titleSmall).hP16,
          Text(model.answer, style: Theme.of(context).textTheme.titleMedium).hP16,
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PColors.pink,
        iconTheme: const IconThemeData(color: PColors.white),
        title: Text("Solution", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
        centerTitle: true, systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: model.questions.length,
                itemBuilder: (context, index) {
                  int i = 2 % (index + 1) == 2 ? 0 : 1;
                  return _questionTile(context, model.questions[index]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}