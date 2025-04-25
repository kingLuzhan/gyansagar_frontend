import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/ui/widget/secondary_app_bar.dart';

class StudentListPage extends StatelessWidget {
  final List<ActorModel> list; // Add this field

  const StudentListPage({
    super.key,
    required this.list, // Add constructor parameter
  });

  static MaterialPageRoute getRoute(List<ActorModel> list) {
    print("StudentListPage.getRoute - Received ${list.length} students");
    print(
      "StudentListPage.getRoute - Students: ${list.map((s) => '${s.name} (${s.email})').toList()}",
    );
    return MaterialPageRoute(builder: (_) => StudentListPage(list: list));
  }

  @override
  Widget build(BuildContext context) {
    print("StudentListPage.build - Rendering ${list.length} students");
    print(
      "StudentListPage.build - Students: ${list.map((s) => '${s.name} (${s.email})').toList()}",
    );

    return Scaffold(
      appBar: const CustomAppBar("Batch Students"),
      body:
          list.isEmpty
              ? const Center(child: Text("No students in this batch"))
              : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final student = list[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 10,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).cardColor,
                    ),
                    child: ListTile(
                      title: Text(
                        student.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      subtitle: Text(
                        student.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
