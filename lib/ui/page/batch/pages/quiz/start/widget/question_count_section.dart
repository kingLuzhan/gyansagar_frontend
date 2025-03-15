import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/model/quiz_model.dart';
import 'package:gyansagar_frontend/states/quiz/quiz_state.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:provider/provider.dart';

class QuestionCountSection extends StatelessWidget {
  const QuestionCountSection({super.key, required this.isDisplayQuestion});
  final ValueNotifier<bool> isDisplayQuestion;

  Widget _circularNo(BuildContext context, int index, Question model) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: model.selectedAnswer != null ? PColors.green : Colors.white,
      ),
      child: Text(
        "${index + 1}",
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: model.selectedAnswer != null ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDisplayQuestion,
      builder: (BuildContext context, bool value, Widget? child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.decelerate,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: !value ? 0 : 16),
          width: AppTheme.fullWidth(context),
          decoration: AppTheme.decoration(context).copyWith(
            color: PColors.red.withOpacity(.1),
          ),
          child: !value
              ? const SizedBox.shrink()
              : Consumer<QuizState>(
            builder: (context, QuizState state, child) {
              return Wrap(
                children: Iterable.generate(state.quizModel.questions.length, (index) {
                  return _circularNo(context, index, state.quizModel.questions[index]);
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }
}