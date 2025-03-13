import 'package:contacts_service/contacts_service.dart';
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

class CreateBatch extends StatefulWidget {
  const CreateBatch({
    Key? key,
    required this.model,
  }) : super(key: key);

  final BatchModel model;

  static MaterialPageRoute getRoute({required BatchModel model}) {
    return MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider<CreateBatchStates>(
        create: (context) => CreateBatchStates(model),
        child: CreateBatch(model: model),
      ),
    );
  }

  @override
  _CreateBatchState createState() => _CreateBatchState();
}

class _CreateBatchState extends State<CreateBatch> {
  late TextEditingController _contactController;
  late TextEditingController _name;
  late TextEditingController _description;
  late TextEditingController _subject;
  final _formKey = GlobalKey<FormState>();
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> addSubjectLoading = ValueNotifier<bool>(false);
  ValueNotifier<List<ActorModel>> student = ValueNotifier<List<ActorModel>>([]);
  ValueNotifier<List<Contact>> deviceContact = ValueNotifier<List<Contact>>([]);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    var state = Provider.of<CreateBatchStates>(context, listen: false);
    _contactController = TextEditingController();
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
            ? SizedBox.shrink()
            : SizedBox(
          width: AppTheme.fullWidth(context),
          child: Wrap(
              children: state.availableSubjects
                  .map(
                    (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8) +
                      EdgeInsets.only(right: 8),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: e.isSelected
                            ? PColors.green
                            : theme.dividerColor,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      e.name,
                      style: theme.textTheme.bodyLarge!.copyWith(
                          fontSize: 10,
                          color: !e.isSelected
                              ? Colors.black
                              : Colors.white),
                    ),
                  ).ripple(() {
                    Provider.of<CreateBatchStates>(context,
                        listen: false)
                        .setSelectedSubjects = e.name;
                  }, borderRadius: BorderRadius.circular(20)),
                ),
              )
                  .toList()),
        );
      },
    );
  }

  Widget _title(BuildContext context, String name) {
    return Text(name,
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(fontWeight: FontWeight.bold, fontSize: 16));
  }

  Widget _secondaryButton(BuildContext context,
      {required String label, required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.add_circle, color: PColors.primary, size: 17),
        label: Text(
          label,
          style: theme.textTheme.labelLarge!
              .copyWith(color: PColors.primary, fontWeight: FontWeight.bold),
        ));
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
        delegate: StudentSearch(list,
            Provider.of<CreateBatchStates>(context, listen: false), student));
  }

  void selectFromDeviceContact() async {
    final contacts = await Navigator.push(
        context, AllContactsPage.getRoute(deviceContact.value));
    if (contacts != null && contacts is List<Contact>) {
      deviceContact.value.clear();
      deviceContact.value = contacts;
    }
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
                    PTextField(type: Type.text, controller: _subject),
                    PFlatButton(
                      label: "Add",
                      isLoading: addSubjectLoading,
                      onPressed: saveSubject,
                    )
                  ],
                )).cornerRadius(10),
          );
        });
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
    // validate batch name and batch description
    final isTrue = _formKey.currentState?.validate() ?? false;
    //validate timeSlots
    var isValidTimeSlots = state.checkSlotsValidations();
    if (!isTrue) {
      return;
    }
    if (!isValidTimeSlots) {
      return;
    }
    //validate Subjects
    // if (state.selectedSubjects == null) {
    //   Utility.displaySnackbar(context,
    //       msg: "Please select a subject", key: scaffoldKey);
    //   return;
    // }
    // //validate Students
    // if (!(state.contactList != null && state.contactList.isNotEmpty) &&
    //     deviceContact.value.isEmpty) {
    //   if (state.studentsList.every((element) => !element.isSelected)) {
    //     Utility.displaySnackbar(context,
    //         msg: "Please Add students to batch", key: scaffoldKey);
    //     return;
    //   }
    // }

    isLoading.value = true;
    state.setBatchName = _name.text;
    state.setBatchdescription = _description.text;
    state.setDeviceSelectedContacts(deviceContact.value);
    final newBatch = await state.createBatch();
    isLoading.value = false;
    var message = state.isEditBatch
        ? "Batch updated successfully!!"
        : "Batch is successfully created!!";
    Alert.success(context, message: message, title: "Message", onPressed: () {
      Navigator.pop(context);
      if (state.isEditBatch) {
        Navigator.pop(context);
      }
    });
    final homeState = Provider.of<HomeState>(context, listen: false);
    homeState.getBatchList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar("Create Batch"),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 16),
                PTextField(
                  type: Type.text,
                  controller: _name,
                  label: "Batch Name",
                  hintText: "Enter batch name",
                ),
                PTextField(
                  type: Type.optional,
                  controller: _description,
                  label: "Description",
                  hintText: "Description",
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _title(context, "Pick Subject"),
                    _secondaryButton(context,
                        label: "Add Subject", onPressed: addSubjects),
                  ],
                ),
                _subjects(context),
                const SizedBox(height: 10),
                _title(context, "Add Class"),
                // const SizedBox(height: 10),
                // BatchTimeSlotWidget(model: BatchTimeSlotModel.initial()),
                const SizedBox(height: 10),
                Consumer<CreateBatchStates>(
                  builder: (context, state, child) {
                    return state.timeSlots.isEmpty
                        ? const SizedBox()
                        : Column(
                        children: state.timeSlots.map((e) {
                          var index = state.timeSlots.indexOf(e);
                          var model = state.timeSlots[index];
                          return Dismissible(
                            confirmDismiss: (val) async {
                              var isRemoved = context
                                  .read<CreateBatchStates>()
                                  .removeTimeSlot(model);
                              return Future.value(isRemoved);
                            },
                            key: UniqueKey(),
                            child: BatchTimeSlotWidget(
                              model: model,
                              indexValue: index,
                            ).vP5,
                          );
                        }).toList());
                  },
                ),
                _secondaryButton(context, label: "Add Class", onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Provider.of<CreateBatchStates>(context, listen: false)
                      .setTimeSlots(BatchTimeSlotModel.initial());
                }),
                const SizedBox(height: 10),
                _title(context, "Add Students"),
                const SizedBox(height: 10),
                AddStudentsWidget(
                  controller: _contactController,
                ),
                Text(
                  "An SMS & whatsapp invite will be sent to the above number",
                  style: theme.textTheme.bodyMedium!.copyWith(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: theme.textTheme.titleSmall!.color),
                ).vP8,
                const SizedBox(height: 4),
                _secondaryButton(context,
                    label: "Pick Institute Student",
                    onPressed: displayStudentsList),
                ValueListenableBuilder<List<ActorModel>>(
                    valueListenable: student,
                    builder: (context, listenableList, chils) {
                      return Wrap(
                          children: listenableList
                              .where((element) => element.isSelected)
                              .map((e) => CircleAvatar(
                              radius: 15,
                              child: Text(
                                e.name.substring(0, 2).toUpperCase(),
                                style: theme.textTheme.bodySmall!.copyWith(
                                    fontSize: 12,
                                    color: theme.colorScheme.onPrimary),
                              )).p(5))
                              .toList());
                    }),
                const SizedBox(height: 12),
                _secondaryButton(context,
                    label: "Select contact from device",
                    onPressed: selectFromDeviceContact),
                ValueListenableBuilder<List<Contact>>(
                    valueListenable: deviceContact,
                    builder: (context, listenableList, chils) {
                      return Wrap(
                          children: listenableList
                              .map((e) => CircleAvatar(
                              radius: 15,
                              child: Text(
                                e.displayName
                                    ?.substring(0, 2)
                                    .toUpperCase() ?? '',
                                style: theme.textTheme.bodySmall!.copyWith(
                                    fontSize: 12,
                                    color: theme.colorScheme.onPrimary),
                              )).p(5))
                              .toList());
                    }),
                const SizedBox(height: 10),
                Consumer<CreateBatchStates>(builder: (context, state, child) {
                  return PFlatButton(
                    label: state.isEditBatch ? "Update" : "Create",
                    isLoading: isLoading,
                    onPressed: createBatch,
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}