import 'package:gyansagar_frontend/model/batch_model.dart';
import 'package:gyansagar_frontend/model/batch_timeline_model.dart';
import 'package:gyansagar_frontend/resources/repository/batch_repository.dart';
import 'package:gyansagar_frontend/states/base_state.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

class BatchDetailState extends BaseState {
  final String batchId;
  List<BatchTimeline>? timeLineList = [];
  BatchModel? batchDetails; // Add this to store batch details

  BatchDetailState({required this.batchId});

  Future<void> getBatchDetails() async {
    await execute(() async {
      try {
        setBusy(true);
        final repo = getIt.get<BatchRepository>();
        batchDetails = await repo.getBatchDetails(batchId);
        print("BatchDetails fetched - studentModel length: ${batchDetails?.studentModel.length}");
        print("Students: ${batchDetails?.studentModel.map((s) => '${s.name} (${s.email})').toList()}");
        notifyListeners();
      } catch (e) {
        log("getBatchDetails Error", error: e);
      } finally {
        setBusy(false);
      }
    }, label: "getBatchDetails");
  }

  Future<void> getBatchTimeLine() async {
    await execute(() async {
      try {
        setBusy(true);
        final repo = getIt.get<BatchRepository>();
        timeLineList = await repo.getBatchDetailTimeLine(batchId);
        await getBatchDetails(); // Also fetch batch details
        notifyListeners();
      } catch (e) {
        log("getBatchTimeLine Error", error: e);
      } finally {
        setBusy(false);
      }
    }, label: "getBatchTimeLine");
  }
}
