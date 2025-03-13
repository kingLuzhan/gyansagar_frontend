import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/states/home_state.dart';
import 'package:gyansagar_frontend/states/teacher/poll_state.dart';
import 'package:gyansagar_frontend/ui/page/poll/poll_option_widget.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/form/p_textfield.dart';
import 'package:gyansagar_frontend/ui/widget/p_button.dart';
import 'package:gyansagar_frontend/ui/widget/secondary_app_bar.dart';
import 'package:provider/provider.dart';

class CreatePoll extends StatefulWidget {
  CreatePoll({Key? key}) : super(key: key);

  static MaterialPageRoute getRoute() {
    return MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider<PollState>(
        create: (context) => PollState(),
        child: CreatePoll(),
      ),
    );
  }

  @override
  _CreateBatchState createState() => _CreateBatchState();
}

class _CreateBatchState extends State<CreatePoll> {
  late TextEditingController _description;
  late TextEditingController _question;
  final _formKey = GlobalKey<FormState>();
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _description = TextEditingController();
    _question = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _question.dispose();
    _description.dispose();
    super.dispose();
  }

  Widget _secondaryButton(BuildContext context,
      {required String label, required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.add_circle, color: PColors.primary, size: 17),
        label: Text(
          label,
          style: theme.textTheme.labelLarge
              ?.copyWith(color: PColors.primary, fontWeight: FontWeight.bold),
        ));
  }

  Widget _title(context, String name) {
    return Text(name,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16));
  }

  Widget _day(String text, {required VoidCallback onPressed, Widget? child}) {
    final theme = Theme.of(context);
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: AppTheme.outline(context),
      child: child ?? Row(
        children: <Widget>[
          Text(text),
          Spacer(),
          SizedBox(
            height: 50,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.center,
              children: <Widget>[
                Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 15,
                      child: Icon(Icons.arrow_drop_up, size: 30).pB(10),
                    )),
                Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 15,
                      child: Icon(Icons.arrow_drop_down, size: 30).pT(10),
                    ))
              ],
            ),
          ),
          SizedBox(width: 4)
        ],
      ),
    ).ripple(onPressed);
  }

  Future<String> getTime(BuildContext context) async {
    final time =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) {
      return "";
    }
    TimeOfDay selectedTime = time;
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    String formattedTime = localizations.formatTimeOfDay(selectedTime,
        alwaysUse24HourFormat: true);
    print(formattedTime);
    return formattedTime;
  }

  Future<DateTime> getDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 2)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    return date ?? DateTime.now();
  }

  void createPoll() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final state = context.read<PollState>();
    final isTrue = _formKey.currentState?.validate() ?? false;

    if (!isTrue) {
      return;
    }
    isLoading.value = true;

    final newPoll = await state.createPoll(_question.text);
    isLoading.value = false;

    final homeState = context.read<HomeState>();
    homeState.getPollList();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar("Create Poll"),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PTextField(
                  type: Type.text,
                  controller: _question,
                  label: "Poll question",
                  hintText: "Enter question",
                  maxLines: 0,
                  height: 0.0,
                ),
                SizedBox(height: 15),
                _title(context, "Poll Expire time"),
                SizedBox(height: 8),
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: AppTheme.outline(context),
                  child: Container(
                    width: AppTheme.fullWidth(context) - 32,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        icon: SizedBox(
                            height: 50,
                            child: Stack(
                              clipBehavior: Clip.hardEdge,
                              alignment: Alignment.center,
                              children: <Widget>[
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: SizedBox(
                                      width: 15,
                                      child: Icon(Icons.arrow_drop_up, size: 30)
                                          .pB(10),
                                    )),
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: SizedBox(
                                      width: 15,
                                      child: Icon(Icons.arrow_drop_down, size: 30)
                                          .pT(10),
                                    ))
                              ],
                            )),
                        isExpanded: true,
                        value: context.watch<PollState>().pollExpiry,
                        items: <String>[
                          '12 Hours',
                          '24 Hours',
                          '36 Hours',
                          '48 Hours',
                          "60 Hours",
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          context.read<PollState>().setPollExpiry = val!;
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                _title(context, "Options"),
                SizedBox(height: 5),
                Consumer<PollState>(
                  builder: (context, state, child) {
                    return Column(
                        children: Iterable.generate(state.pollOptions.length,
                                (index) {
                              return PollOption(
                                  index: index, value: state.pollOptions[index]);
                            }).toList());
                  },
                ),
                _secondaryButton(context, label: "Add option", onPressed: () {
                  context.read<PollState>().addPollOptions();
                }),
                SizedBox(height: 150),
                PFlatButton(
                  label: "Create",
                  isLoading: isLoading,
                  onPressed: createPoll,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}