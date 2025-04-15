import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/model/batch_time_slot_model.dart';
import 'package:gyansagar_frontend/states/teacher/create_batch_state.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:provider/provider.dart';

class BatchTimeSlotWidget extends StatelessWidget {
  final BatchTimeSlotModel model;
  final int indexValue;

  const BatchTimeSlotWidget({
    super.key,
    required this.model,
    required this.indexValue,
  });

  Widget _addClass(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: AppTheme.outline(context),
              child: SizedBox(
                width: (AppTheme.fullWidth(context) / 3) - 60,
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
                                  child: const Icon(Icons.arrow_drop_up, size: 30).pB(10),
                                )),
                            Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  width: 15,
                                  child: const Icon(Icons.arrow_drop_down, size: 30).pT(10),
                                ))
                          ],
                        )),
                    isExpanded: true,
                    underline: const SizedBox(),
                    value: model.day,
                    items: <String>['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        model.day = val;
                        model.dayOfWeek = BatchTimeSlotModel.dayToIndex(val);
                        Provider.of<CreateBatchStates>(context, listen: false)
                            .updateTimeSlots(model, indexValue);
                      }
                    },
                  ),
                ),
              ),
            )),
        const SizedBox(width: 5),
        Expanded(
          child: _day(context, model.startTime, isStartTime: true,
              onPressed: () async {
                final time = await getTime(context);
                model.startTime = time;
                Provider.of<CreateBatchStates>(context, listen: false)
                    .updateTimeSlots(model, indexValue);
              }),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: _day(context, model.endTime, isStartTime: false,
              onPressed: () async {
                final time = await getTime(context);
                model.endTime = time;
                Provider.of<CreateBatchStates>(context, listen: false)
                    .updateTimeSlots(model, indexValue);
              }),
        ),
        const SizedBox(
          height: 40,
        )
      ],
    );
  }

  Widget _day(BuildContext context, String text,
      {required VoidCallback onPressed, Widget? child, required bool isStartTime}) {
    final theme = Theme.of(context);
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: decoration(context, isStartTime),
      child: child ?? Row(
        children: <Widget>[
          Text(text),
          const Spacer(),
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
                      child: const Icon(Icons.arrow_drop_up, size: 30).pB(10),
                    )),
                Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 15,
                      child: const Icon(Icons.arrow_drop_down, size: 30).pT(10),
                    ))
              ],
            ),
          ),
          const SizedBox(width: 4)
        ],
      ),
    ).ripple(onPressed);
  }

  Decoration decoration(BuildContext context, bool isStartTime) {
    if (isStartTime) {
      return model.isValidStartEntry
          ? AppTheme.outline(context)
          : AppTheme.outlineError(context);
    } else {
      return model.isValidEndEntry
          ? AppTheme.outline(context)
          : AppTheme.outlineError(context);
    }
  }

  Future<String> getTime(BuildContext context) async {
    final time =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) {
      return "Start time"; // Or return "End time" based on the context
    }
    TimeOfDay selectedTime = time;
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    String formattedTime = localizations.formatTimeOfDay(selectedTime,
        alwaysUse24HourFormat: true);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return _addClass(context);
  }
}