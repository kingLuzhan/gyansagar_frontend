import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/states/teacher/poll_state.dart';
import 'package:gyansagar_frontend/ui/widget/form/p_textfield.dart';
import 'package:provider/provider.dart';

class PollOption extends StatefulWidget {
  const PollOption({
    super.key,
    required this.index,
    required this.value,
  });
  final int index;
  final String value;

  @override
  _PollOptionState createState() => _PollOptionState();
}

class _PollOptionState extends State<PollOption> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value)
      ..addListener(writeData);
  }

  @override
  void didUpdateWidget(PollOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.text = widget.value;
      });
    }
  }

  void writeData() {
    Provider.of<PollState>(context, listen: false)
        .addValueToPollOption(controller.text, widget.index);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: PTextField(
        type: FieldType.text,
        controller: controller,
        hintText: "Enter option ${widget.index}",
        maxLines: 1,  // Change from 0 to 1
        height: 50.0,  // Change to an appropriate height
        suffixIcon: widget.index < 2
            ? null
            : IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () {
            controller.removeListener(writeData);
            Provider.of<PollState>(context, listen: false)
                .removePollOption(widget.index);
          },
        ),
      ),
    );
  }
}