import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/model/poll_model.dart';
import 'package:gyansagar_frontend/states/home_state.dart';
import 'package:gyansagar_frontend/ui/kit/overlay_loader.dart';
import 'package:gyansagar_frontend/ui/page/batch/widget/tile_action_widget.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:provider/provider.dart';

class PollWidget extends StatefulWidget {
  const PollWidget({
    super.key,
    required this.model,
    required this.loader,
    this.hideFinishButton = true,
  });
  final PollModel model;
  final CustomLoader loader;
  final bool hideFinishButton;

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
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
        decoration: widget.model.selection?.choice == e
            ? AppTheme.outlineSucess(context)
                .copyWith(color: PColors.green.withOpacity(.3))
            : widget.model.isMyVote(Provider.of<HomeState>(context).userId, e)
                ? AppTheme.outlineSucess(context)
                    .copyWith(color: PColors.green.withOpacity(.3))
                : widget.model.endTime.isAfter(DateTime.now())
                    ? AppTheme.outlinePrimary(context)
                    : AppTheme.outline(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(e).extended,
            Text('${widget.model.percent(e).toStringAsFixed(1)}%'),
          ],
        ),
      ).ripple(() {
        final state = Provider.of<HomeState>(context, listen: false);

        if (state.isTeacher ||
            widget.model.selection?.loading == true ||
            widget.model.endTime.isBefore(DateTime.now())) {
          return;
        }

        final userId = state.userId;
        if (widget.model.isVoted(userId)) {
          print("Already voted");
          return;
        }

        setState(() {
          widget.model.selection = MySelection(
            choice: e,
            isSelected: true,
            loading: false,
          );
        });
      }),
    );
  }

  void submitVote(BuildContext context, String answer) {
    final state = Provider.of<HomeState>(context, listen: false);
    if (state.isBusy) {
      return;
    }
    state.castVoteOnPoll(widget.model, answer);
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
              Text(widget.model.question).pL(16).extended,
              if (context.watch<HomeState>().isTeacher)
                TileActionWidget(
                  list: const ["End Poll", "Delete"],
                  onCustomIconPressed: () async {
                    widget.loader.showLoader(context);
                    await context.read<HomeState>().expirePoll(widget.model.id);
                    widget.loader.hideLoader();
                  },
                  onDelete: () async {
                    widget.loader.showLoader(context);
                    await context.read<HomeState>().deletePoll(widget.model.id);
                    widget.loader.hideLoader();
                  },
                  onEdit: () {},
                )
              else
                const SizedBox(width: 16)
            ],
          ),
          const SizedBox(height: 10),
          Column(
              children: widget.model.options.map((e) {
                return _option(context, e).hP16;
              }).toList()),
          if (!state.isTeacher &&
              !widget.model.isVoted(state.userId) &&
              widget.model.selection?.isSelected == true &&
              !widget.model.endTime.isBefore(DateTime.now())) ...[
            const SizedBox(height: 10),
            _secondaryButton(context,
                isLoading: widget.model.selection?.loading == true,
                label: "Submit", onPressed: () {
                  submitVote(context, widget.model.selection?.choice ?? '');
                })
          ],
          const SizedBox(height: 16)
        ],
      ),
    );
  }
}