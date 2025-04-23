import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/ui/widget/secondary_app_bar.dart';

class StudentListPage extends StatelessWidget {
  static MaterialPageRoute getRoute(List<ActorModel> list) {
    return MaterialPageRoute(builder: (_) => StudentListPage(list: list));
  }

  const StudentListPage({super.key, required this.list});
  final List<ActorModel> list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar("Batch Students"),
      body: Container(
        child: ListView.builder(
          itemCount: list.length,
          itemBuilder:
              (context, index) => Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
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
                    list[index].name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  // Removed mobile field from subtitle
                  subtitle: Text("N/A"),
                  onTap: () {},
                ),
              ),
        ),
      ),
    );
  }
}
