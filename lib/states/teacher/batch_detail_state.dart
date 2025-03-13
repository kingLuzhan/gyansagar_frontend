import 'package:gyansagar_frontend/model/batch_timeline_model.dart';
import 'package:gyansagar_frontend/resources/repository/batch_repository.dart';
import 'package:gyansagar_frontend/states/base_state.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

class BatchDetailState extends BaseState {
  final String batchId;
  List<BatchTimeline>? timeLineList = [];

  BatchDetailState({required this.batchId});

  Future<void> getBatchTimeLine() async {
    await execute(() async {
      try {
        setBusy(true); // ✅ Use setBusy instead of modifying isBusy directly
        final repo = getIt.get<BatchRepository>();
        timeLineList = await repo.getBatchDetailTimeLine(batchId);
        notifyListeners();
      } catch (e) {
        log("getBatchTimeLine Error", error: e);
      } finally {
        setBusy(false);
      }
    }, label: "getBatchTimeLine");
  }
}