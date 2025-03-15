import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';

class StudentListPreview extends StatelessWidget {
  const StudentListPreview({super.key, required this.list});
  final List<ActorModel> list;

  Positioned _wrapper(BuildContext context, {required Widget child, required int index}) {
    return Positioned(
      right: 20 * index * 1.0,
      child: Container(
          height: 25,
          width: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.red,
              border: Border.all(
                  color: Theme.of(context).colorScheme.onPrimary, width: 2),
              borderRadius: BorderRadius.circular(40)),
          child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 150,
      height: 30,
      alignment: Alignment.centerRight,
      child: Stack(
        children: List.generate(list.length > 3 ? 4 : list.length, (index) {
          if (list.length > 3 && index == 0) {
            return _wrapper(context,
                index: index,
                child: Text("+${list.length - 3}",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onPrimary)));
          }
          return _wrapper(
            context,
            index: index,
            child: Text(
              list[index].name.substring(0, 2).toUpperCase(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 10, color: Theme.of(context).colorScheme.onPrimary),
            ),
          );
        }),
      ),
    );
  }
}