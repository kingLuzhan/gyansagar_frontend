import 'package:flutter/material.dart';

class TileActionWidget extends StatelessWidget {
  const TileActionWidget(
      {Key? key,
        required this.onDelete,
        required this.onEdit,
        required this.onCustomIconPressed,
        this.list = const ["Edit", "Delete"]})
      : super(key: key);
  final Function onDelete;
  final Function onEdit;
  final Function onCustomIconPressed;
  final List<String> list;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (action) {
        switch (action) {
          case "Delete":
            onDelete();
            break;
          case "Edit":
            onEdit();
            break;
          default:
            onCustomIconPressed();
        }
      },
      padding: EdgeInsets.zero,
      offset: Offset(0, 0),
      color: Colors.white,
      itemBuilder: (BuildContext context) {
        return list.map((String choice) {
          return PopupMenuItem<String>(value: choice, child: Text(choice));
        }).toList();
      },
    );
  }
}