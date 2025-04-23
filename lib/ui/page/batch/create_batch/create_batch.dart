import 'dart:developer';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/model/batch_model.dart';
import 'package:gyansagar_frontend/model/batch_time_slot_model.dart';
import 'package:gyansagar_frontend/states/home_state.dart';
import 'package:gyansagar_frontend/states/teacher/create_batch_state.dart';
import 'package:gyansagar_frontend/ui/kit/alert.dart';
import 'package:gyansagar_frontend/ui/page/batch/create_batch/device_contacts_page.dart';
import 'package:gyansagar_frontend/ui/page/batch/create_batch/search_student_delegate.dart';
import 'package:gyansagar_frontend/ui/page/batch/create_batch/widget/add_students_widget.dart';
import 'package:gyansagar_frontend/ui/page/batch/create_batch/widget/batch_time_slots.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/form/p_textfield.dart';
import 'package:gyansagar_frontend/ui/widget/p_button.dart';
import 'package:gyansagar_frontend/ui/widget/secondary_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateBatch extends StatefulWidget {
  const CreateBatch({super.key, required this.model});

  final BatchModel model;

  static MaterialPageRoute getRoute({required BatchModel model}) {
    return MaterialPageRoute(
      builder:
          (_) => ChangeNotifierProvider<CreateBatchStates>(
            create: (context) => CreateBatchStates(model),
            child: CreateBatch(model: model),
          ),
    );
  }

  @override
  _CreateBatchState createState() => _CreateBatchState();
}

class _CreateBatchState extends State<CreateBatch> {
  late TextEditingController _name;
  late TextEditingController _description;
  late TextEditingController _subject;
  final _formKey = GlobalKey<FormState>();
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> addSubjectLoading = ValueNotifier<bool>(false);
  ValueNotifier<List<ActorModel>> student = ValueNotifier<List<ActorModel>>([]);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    var state = Provider.of<CreateBatchStates>(context, listen: false);
    _name = TextEditingController(text: state.batchName ?? "");
    _description = TextEditingController(text: state.description ?? "");
    _subject = TextEditingController();
    state.getStudentList().then((_) {
      student.value = state.studentsList;
    });
    super.initState();
  }

  Widget _subjects(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<CreateBatchStates>(
      builder: (context, state, child) {
        return state.availableSubjects.isEmpty
            ? const SizedBox.shrink()
            : SizedBox(
              width: AppTheme.fullWidth(context),
              child: Wrap(
                children:
                    state.availableSubjects
                        .map(
                          (e) => Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 8) +
                                const EdgeInsets.only(right: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    e.isSelected
                                        ? PColors.green
                                        : theme.dividerColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                e.name,
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontSize: 10,
                                  color:
                                      !e.isSelected
                                          ? Colors.black
                                          : Colors.white,
                                ),
                              ),
                            ).ripple(() {
                              Provider.of<CreateBatchStates>(
                                    context,
                                    listen: false,
                                  ).setSelectedSubjects =
                                  e.name;
                            }, borderRadius: BorderRadius.circular(20)),
                          ),
                        )
                        .toList(),
              ),
            );
      },
    );
  }

  Widget _title(BuildContext context, String name) {
    return Text(
      name,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _secondaryButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_circle, color: PColors.primary, size: 17),
      label: Text(
        label,
        style: theme.textTheme.labelLarge!.copyWith(
          color: PColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void displayStudentsList() async {
    final list =
        Provider.of<CreateBatchStates>(context, listen: false).studentsList;
    if (!(list.isNotEmpty)) {
      return;
    }
    print(list.length);
    await showSearch(
      context: context,
      delegate: StudentSearch(
        list,
        Provider.of<CreateBatchStates>(context, listen: false),
        student,
      ),
    );
  }

  void addSubjects() async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 200,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: <Widget>[
                _title(context, "Add new subject"),
                const SizedBox(height: 30),
                PTextField(type: FieldType.text, controller: _subject),
                PFlatButton(
                  label: "Add",
                  isLoading: addSubjectLoading,
                  onPressed: saveSubject,
                ),
              ],
            ),
          ).cornerRadius(10),
        );
      },
    );
  }

  void saveSubject() async {
    if (_subject.text.isNotEmpty) {
      addSubjectLoading.value = true;
      final state = Provider.of<CreateBatchStates>(context, listen: false);
      state.addNewSubject(_subject.text);
      addSubjectLoading.value = false;
      _subject.clear();
      Navigator.pop(context);
    }
  }

  void createBatch() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final state = Provider.of<CreateBatchStates>(context, listen: false);

    final isTrue = _formKey.currentState?.validate() ?? false;
    var isValidTimeSlots = state.checkSlotsValidations();
    if (!isTrue || !isValidTimeSlots) {
      return;
    }

    // Get selected students with valid emails
    final selectedStudents =
        student.value
            .where(
              (element) => element.isSelected && _isValidEmail(element.email),
            )
            .map((e) => e.email)
            .toList();

    // Validate students selection
    if (selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select at least one student with a valid email",
          ),
        ),
      );
      return;
    }

    isLoading.value = true;
    try {
      state.setBatchName = _name.text;
      state.setBatchdescription = _description.text;
      state.setSelectedStudents = selectedStudents;
      final newBatch = await state.createBatch();
      isLoading.value = false;

      var message =
          state.isEditBatch
              ? "Batch updated successfully!"
              : "Batch created successfully!";

      Alert.success(
        context,
        message: message,
        title: "Success",
        onPressed: () {
          Navigator.of(
            context,
          ).popUntil((route) => route.isFirst); // This will pop until homepage
        },
      );

      Provider.of<HomeState>(context, listen: false).getBatchList();
    } catch (error) {
      isLoading.value = false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  // Helper function to validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: const CustomAppBar("Create Batch"),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 16),
                PTextField(
                  type: FieldType.text,
                  controller: _name,
                  label: "Batch Name",
                  hintText: "Enter batch name",
                ),
                PTextField(
                  type: FieldType.optional,
                  controller: _description,
                  label: "Description",
                  hintText: "Description",
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _title(context, "Pick Subject"),
                    _secondaryButton(
                      context,
                      label: "Add Subject",
                      onPressed: addSubjects,
                    ),
                  ],
                ),
                _subjects(context),
                const SizedBox(height: 10),
                _title(context, "Select Students"),
                const SizedBox(height: 10),
                _secondaryButton(
                  context,
                  label: "Select Institute Students",
                  onPressed: displayStudentsList,
                ),
                ValueListenableBuilder<List<ActorModel>>(
                  valueListenable: student,
                  builder: (context, listenableList, child) {
                    return Wrap(
                      children:
                          listenableList
                              .where((element) => element.isSelected)
                              .map(
                                (e) => CircleAvatar(
                                  radius: 15,
                                  child: Text(
                                    e.name.substring(0, 2).toUpperCase(),
                                    style: theme.textTheme.bodySmall!.copyWith(
                                      fontSize: 12,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ).p(5),
                              )
                              .toList(),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Consumer<CreateBatchStates>(
                  builder: (context, state, child) {
                    return Column(
                      children: [
                        ...state.timeSlots.map((model) {
                          final index = state.timeSlots.indexOf(model);
                          return Dismissible(
                            key: Key(model.key),
                            onDismissed: (_) => state.removeTimeSlot(model),
                            child: BatchTimeSlotWidget(
                              model: model,
                              indexValue: index,
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 10),
                        _secondaryButton(
                          context,
                          label: "Add Class Time",
                          onPressed: () {
                            state.setTimeSlots(BatchTimeSlotModel.initial());
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Consumer<CreateBatchStates>(
                  builder: (context, state, child) {
                    return PFlatButton(
                      label: state.isEditBatch ? "Update" : "Create",
                      isLoading: isLoading,
                      onPressed: createBatch,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
