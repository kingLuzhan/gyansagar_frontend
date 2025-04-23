import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/states/teacher/create_batch_state.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/p_chiip.dart';
import 'package:provider/provider.dart';

class AddStudentsWidget extends StatelessWidget {
  const AddStudentsWidget({super.key, required this.controller});
  final TextEditingController controller;

  Widget _enterContactNo(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress, // Changed to email address
      keyboardAppearance: Brightness.light,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: "Enter email address..",
      ), // Updated hint text
      onSubmitted: (contact) {
        Provider.of<CreateBatchStates>(
          context,
          listen: false,
        ).addContact(contact);
        controller.clear();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
      width: AppTheme.fullWidth(context),
      decoration: AppTheme.outline(context),
      child: Consumer<CreateBatchStates>(
        builder: (context, state, child) {
          return Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children:
                state.contactList.isEmpty
                      ? <Widget>[const SizedBox.shrink()]
                      : state.contactList
                          .map(
                            (e) => PChip(
                              label: e,
                              onDeleted: () {
                                Provider.of<CreateBatchStates>(
                                  context,
                                  listen: false,
                                ).removeContact(e);
                              },
                            ).p(3),
                          )
                          .toList()
                  ..add(
                    SizedBox(width: 120, child: _enterContactNo(context)).hP8,
                  ),
          );
        },
      ),
    );
  }
}
