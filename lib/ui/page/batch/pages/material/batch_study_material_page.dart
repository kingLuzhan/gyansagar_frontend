import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/model/batch_model.dart';
import 'package:gyansagar_frontend/states/teacher/material/batch_material_state.dart';
import 'package:gyansagar_frontend/ui/kit/overlay_loader.dart';
import 'package:gyansagar_frontend/ui/page/batch/pages/material/widget/batch_material_card.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/p_loader.dart';
import 'package:provider/provider.dart';

class BatchStudyMaterialPage extends StatelessWidget {
  const BatchStudyMaterialPage({Key? key, required this.model, required this.loader})
      : super(key: key);
  final BatchModel model;
  final CustomLoader loader;

  static MaterialPageRoute getRoute(BatchModel model, CustomLoader loader) {
    return MaterialPageRoute(
        builder: (_) => BatchStudyMaterialPage(model: model, loader: loader));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<BatchMaterialState>(
        builder: (context, state, child) {
          if (state.isBusy) {
            return Ploader();
          }
          if (state.list.isEmpty) {
            return Center(
              child: Container(
                height: 100,
                margin: EdgeInsets.symmetric(horizontal: 16),
                width: AppTheme.fullWidth(context),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Nothing to see here",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: PColors.gray,
                        )),
                    SizedBox(height: 10),
                    Text("No study material uploaded yet for this batch!!",
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: state.list.length,
            itemBuilder: (_, index) {
              return BatchMaterialCard(
                model: state.list[index],
                loader: loader,
              );
            },
          );
        },
      ),
    );
  }
}