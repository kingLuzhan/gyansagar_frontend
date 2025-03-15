import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/helper/images.dart';
import 'package:gyansagar_frontend/model/quiz_model.dart';
import 'package:gyansagar_frontend/states/quiz/quiz_state.dart';
import 'package:gyansagar_frontend/ui/kit/alert.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/quiz/result/quiz_result_page.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/quiz/start/widget/question_count_section.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/quiz/start/widget/timer.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:provider/provider.dart';

class StartQuizPage extends StatefulWidget {
  const StartQuizPage({super.key, required this.model, required this.batchId});
  final AssignmentModel model;
  final String batchId;

  static MaterialPageRoute getRoute({required AssignmentModel model, required String batchId}) {
    return MaterialPageRoute(
      builder: (_) => Provider(
        create: (_) => QuizState(batchId: batchId),
        child: ChangeNotifierProvider<QuizState>(
          create: (_) => QuizState(batchId: batchId),
          child: StartQuizPage(model: model, batchId: batchId),
          builder: (_, child) => child!,
        ),
      ),
    );
  }

  @override
  _StartQuizPageState createState() => _StartQuizPageState();
}

class _StartQuizPageState extends State<StartQuizPage> {
  ValueNotifier<bool> isDisplayQuestion = ValueNotifier<bool>(false);
  ValueNotifier<int> currentQuestion = ValueNotifier<int>(0);
  String? remainingTime;
  String? timeTaken;
  PageController _pageController = PageController();
  bool isQuizEnd = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Provider.of<QuizState>(context, listen: false).getAssignmentDetail(widget.model.id);
  }

  @override
  void dispose() {
    isDisplayQuestion.dispose();
    super.dispose();
  }

  Widget _headerSection(QuizState state) {
    final theme = Theme.of(context);
    return Container(
      color: PColors.red.withOpacity(.3),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 16),
              ValueListenableBuilder<int>(
                valueListenable: currentQuestion,
                builder: (BuildContext context, int value, Widget? child) {
                  return Text(
                    "question: ${value + 1}/${state.quizModel.questions.length}",
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  );
                },
              ),
              const Spacer(),
              SizedBox(
                height: 45,
                width: 45,
                child: GestureDetector(
                  onTap: () {
                    isDisplayQuestion.value = !isDisplayQuestion.value;
                  },
                  child: Image.asset(Images.dropdown, height: 20).p16,
                ),
              ),
            ],
          ),
          QuestionCountSection(isDisplayQuestion: isDisplayQuestion),
        ],
      ),
    );
  }

  Widget _question(Question model) {
    return Container(
      width: AppTheme.fullWidth(context),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(model.statement),
            const SizedBox(height: 4),
            Column(
              children: model.options.map((e) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: AppTheme.outline(context),
                  width: AppTheme.fullWidth(context) - 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        e == model.selectedAnswer ? Icons.check_circle_rounded : Icons.panorama_fish_eye,
                        color: e == model.selectedAnswer ? PColors.green : PColors.gray,
                      ).p16,
                      Text(e).extended,
                    ],
                  ),
                ).ripple(() {
                  model.selectedAnswer = e;
                  Provider.of<QuizState>(context, listen: false).addAnswer(model);
                });
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _body(QuizState state) {
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      controller: _pageController,
      itemCount: state.quizModel.questions.length,
      onPageChanged: (page) {
        currentQuestion.value = page;
      },
      itemBuilder: (context, index) {
        return _question(state.quizModel.questions[index]);
      },
    ).extended;
  }

  Widget _footer() {
    final theme = Theme.of(context);
    return Container(
      decoration: AppTheme.decoration(context),
      child: OverflowBar(
        alignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: AppTheme.outlinePrimary(context),
            width: AppTheme.fullWidth(context) * .45,
            child: TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linear,
                );
              },
              child: Text(
                "Previous",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ),
          Container(
            decoration: AppTheme.outlinePrimary(context),
            width: AppTheme.fullWidth(context) * .45,
            child: TextButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linear,
                );
              },
              child: Text(
                "Next",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget noQuiz() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: AppTheme.fullWidth(context),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "Nothing to see here",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: PColors.gray,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "No Assignment is uploaded yet for this batch!!",
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void onTimerComplete(String timerText, {bool force = false}) {
    bool isTimerEnd = timerText == "0:00 time left";
    if (isQuizEnd) {
      print("Return from end");
      return;
    } else if (!force && isTimerEnd) {
      isQuizEnd = true;
    }
    final state = Provider.of<QuizState>(context, listen: false);
    final unAnswered = state.quizModel.questions.where((element) => element.selectedAnswer == null).length;
    print("Quiz time End");

    final list = state.quizModel.questions.where((value) => value.selectedAnswer == null).toList();

    Alert.dialog(
      context,
      title: "Review",
      buttonText: "Submit Quiz",
      titleBackGround: const Color(0xffF7506A),
      enableCrossButton: !isQuizEnd,
      onPressed: () {
        Navigator.pop(context);
        final state = Provider.of<QuizState>(context, listen: false);
        Navigator.pushReplacement(
          context,
          QuizResultPage.getRoute(
            model: state.quizModel,
            batchId: state.batchId,
            timeTaken: timeTaken!,
          ),
        );
      },
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(Images.timer, height: 20),
                const SizedBox(width: 10),
                Text(
                  timerText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "$unAnswered Unanswered questions",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              children: Iterable.generate(unAnswered, (index) {
                return _circularNo(
                  context,
                  state.quizModel.questions.indexOf(list[index]),
                  list[index],
                );
              }).toList(),
            ),
            const SizedBox(height: 42),
            Container(
              decoration: isTimerEnd ? AppTheme.outline(context) : AppTheme.outlinePrimary(context),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              child: TextButton(
                onPressed: isTimerEnd
                    ? null
                    : () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Go back to quiz",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isTimerEnd ? PColors.gray : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _circularNo(context, int index, Question model) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: model.selectedAnswer != null ? PColors.green : Colors.white,
        border: Border.all(color: Colors.black),
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(Images.timer, height: 20),
            const SizedBox(width: 10),
            Consumer<QuizState>(builder: (context, state, child) {
              return Timer(
                duration: state.quizModel.duration,
                onTimerComplete: onTimerComplete,
                onTimerChanged: (value) {
                  remainingTime = value;
                },
                timeTaken: (val) {
                  timeTaken = val;
                },
              );
            }),
          ],
        ),
        actions: [
          Center(
            child: Text(
              "Submit",
              style: theme.textTheme.labelLarge?.copyWith(color: theme.primaryColor),
            ).p16.ripple(() {
              onTimerComplete(remainingTime!, force: true);
            }),
          ),
        ],
      ),
      body: Consumer<QuizState>(
        builder: (context, state, child) {
          if (state.isBusy) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!(state.quizModel.questions.isNotEmpty)) {
            return noQuiz();
          }
          return SizedBox(
            height: AppTheme.fullHeight(context),
            child: Column(
              children: <Widget>[
                _headerSection(state),
                _body(state),
                _footer(),
              ],
            ),
          );
        },
      ),
    );
  }
}