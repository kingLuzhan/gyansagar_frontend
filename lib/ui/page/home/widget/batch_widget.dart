import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/model/batch_model.dart';
// Import BatchTimeSlotModel
import 'package:gyansagar_frontend/ui/page/batch/batch_master_page.dart';
import 'package:gyansagar_frontend/ui/page/home/student_list_preview.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/p_chiip.dart'; // Corrected import

class BatchWidget extends StatelessWidget {
  const BatchWidget(
      this.model, {
        this.isTeacher = true,
        super.key,
      });
  final BatchModel model;
  final bool isTeacher;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: AppTheme.fullWidth(context) * .7,
      margin: const EdgeInsets.only(left: 16),
      decoration: AppTheme.outline(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(model.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle())
                  .copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          PChip(
            label: model.subject,
            backgroundColor: const Color(0xffF67619),
            borderColor: Colors.transparent,
            style: (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
                fontSize: 14, color: theme.colorScheme.onSecondary),
            isCrossIcon: false, // Added isCrossIcon parameter
            onDeleted: () {}, // Added onDeleted parameter
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: Iterable.generate(model.classes.length, (index) {
                  final e = model.classes[index];
                  return Text(e.toShortDay() +
                      (model.classes.length == index + 1 ? "" : ","))
                      .hP4;
                }).toList(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StudentListPreview(list: model.studentModel),
            ],
          ),
        ],
      ).p16.ripple(() {
        Navigator.push(context,
            BatchMasterDetailPage.getRoute(model, isTeacher: isTeacher));
      }),
    );
  }
}