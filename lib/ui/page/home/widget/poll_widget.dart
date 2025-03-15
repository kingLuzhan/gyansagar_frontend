import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/model/poll_model.dart';
import 'package:gyansagar_frontend/states/home_state.dart';
import 'package:gyansagar_frontend/ui/kit/overlay_loader.dart';
import 'package:gyansagar_frontend/ui/page/batch/widget/tile_action_widget.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:provider/provider.dart';

class PollWidget extends StatelessWidget {
  const PollWidget({
    super.key,
    required this.model,
    required this.loader,
    this.hideFinishButton = true,
  });
  final PollModel model;
  final CustomLoader loader;
  final bool hideFinishButton;

  Widget _secondaryButton(BuildContext context,
      {required String label, required VoidCallback onPressed, bool isLoading = false}) {
    final theme = Theme.of(context);
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
        side: BorderSide(color: Theme.of(context).primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: isLoading
          ? const SizedBox(
        height: 25,
        width: 25,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      )
          : Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
            color: PColors.primary, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _option(BuildContext context, String e) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: model.selection?.choice == e
            ? AppTheme.outlineSucess(context)
            .copyWith(color: PColors.green.withOpacity(.3))
            : model.isMyVote(
            Provider.of<HomeState>(context).userId, e)
            ? AppTheme.outlineSucess(context)
            .copyWith(color: PColors.green.withOpacity(.3))
            : model.endTime.isAfter(DateTime.now())
            ? AppTheme.outlinePrimary(context)
            : AppTheme.outline(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(e).extended,
            Text('${model.percent(e).toStringAsFixed(1)}%'),
          ],
        ),
      ).ripple(() {
        final state = Provider.of<HomeState>(context, listen: false);

        if (state.isTeacher ||
            model.selection?.loading == true ||
            model.endTime.isBefore(DateTime.now())) {
          return;
        }

        final userId = Provider.of<HomeState>(context, listen: false).userId;
        if (model.isVoted(userId)) {
          print("Already voted");
          return;
        }
        model.selection = MySelection(choice: e, isSelected: true);
        state.savePollSelection(model);
      }),
    );
  }

  void submitVote(BuildContext context, String answer) {
    final state = Provider.of<HomeState>(context, listen: false);
    if (state.isBusy) {
      return;
    }

    state.castVoteOnPoll(model, answer);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<HomeState>(context, listen: false);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: AppTheme.decoration(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Text(model.question).pL(16).extended,
              if (context.watch<HomeState>().isTeacher)
                TileActionWidget(
                  list: const ["End Poll", "Delete"],
                  onCustomIconPressed: () async {
                    loader.showLoader(context);
                    await context.read<HomeState>().expirePoll(model.id);
                    loader.hideLoader();
                  },
                  onDelete: () async {
                    loader.showLoader(context);
                    await context.read<HomeState>().deletePoll(model.id);
                    loader.hideLoader();
                  },
                  onEdit: () {},
                )
              else
                const SizedBox(width: 16)
            ],
          ),
          const SizedBox(height: 10),
          Column(
              children: model.options.map((e) {
                return _option(context, e).hP16;
              }).toList()),
          if (!state.isTeacher &&
              !model.isVoted(state.userId) &&
              model.selection?.isSelected == true &&
              !model.endTime.isBefore(DateTime.now())) ...[
            const SizedBox(height: 10),
            _secondaryButton(context,
                isLoading: model.selection?.loading == true,
                label: "Submit", onPressed: () {
                  submitVote(context, model.selection?.choice ?? '');
                })
          ],
          const SizedBox(height: 16)
        ],
      ),
    );
  }
}