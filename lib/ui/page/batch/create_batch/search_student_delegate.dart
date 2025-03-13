import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/states/teacher/create_batch_state.dart';

class StudentSearch extends SearchDelegate<ActorModel?> {
  final List<ActorModel> list;
  late List<ActorModel> templist;
  CreateBatchStates state;
  StudentSearch(this.list, this.state, this.student) {
    student.value = list;
  }

  ValueNotifier<List<ActorModel>> student;
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(
        Icons.arrow_back,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    templist = state.studentsList;
    return _result(context);
  }

  Widget _result(BuildContext context) {
    return ValueListenableBuilder<List<ActorModel>>(
      valueListenable: student,
      builder: (context, listenableList, chils) {
        return ListView.builder(
          itemCount: templist.length,
          itemBuilder: (context, index) => Container(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).cardColor,
            ),
            child: ListTile(
              title: Text(
                templist[index].name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.start,
              ),
              subtitle: Text(templist[index].mobile ?? "N/A"),
              trailing: isSelected(templist[index], listenableList)
                  ? Icon(Icons.check_box)
                  : null,
              onTap: () {
                var model = templist[index];
                var selected = listenableList
                    .firstWhere((element) => compare(element, model))
                    .isSelected;
                listenableList
                    .firstWhere((element) => compare(element, model))
                    .isSelected = !selected;
                student.value = List.from(listenableList);
                student.notifyListeners();
              },
            ),
          ),
        );
      },
    );
  }

  bool isSelected(ActorModel model, List<ActorModel> list) {
    var data = list.firstWhere((element) => compare(element, model));
    return data.isSelected;
  }

  bool compare(ActorModel value1, ActorModel value2) {
    return value1.name == value2.name && value1.mobile == value2.mobile;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    templist = list
        .where((x) =>
    x.name.toLowerCase().contains(query.toLowerCase()) ||
        x.mobile.toLowerCase().contains(query.toLowerCase()) == true)
        .toList();
    return _result(context);
  }
}