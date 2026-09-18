import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../repositories/attendance_repository.dart';
import 'attendance_model.dart';

class AttendanceController extends GetxController {
  final AttendanceRepository _repository;
  AttendanceController({AttendanceRepository? repository}) : _repository = repository ?? AttendanceRepository(Get.find<ApiClient>());

  final RxList<AttendanceModel> records = <AttendanceModel>[].obs;
  final Rxn<AttendanceStatus> statusFilter = Rxn<AttendanceStatus>();
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool scannerReady = false.obs;
  final RxnString lastScanMessage = RxnString();
  final Rxn<AttendanceOwnResult> ownResult = Rxn<AttendanceOwnResult>();

  List<AttendanceModel> get filteredRecords => records.where((record) {
    final query = searchQuery.value.trim().toLowerCase();
    final matchesSearch = query.isEmpty || record.userName.toLowerCase().contains(query) || record.userEmail.toLowerCase().contains(query);
    final matchesStatus = statusFilter.value == null || record.status == statusFilter.value;
    return matchesSearch && matchesStatus;
  }).toList();

  int get presentCount => records.where((e) => e.status == AttendanceStatus.present).length;
  int get absentCount => records.where((e) => e.status == AttendanceStatus.absent).length;
  int get lateCount => records.where((e) => e.status == AttendanceStatus.late).length;

  Future<void> loadEventAttendance(String eventId) async {
    isLoading.value = true;
    try { final result = await _repository.event(eventId); records.assignAll(result.records); }
    on Exception catch (e) { lastScanMessage.value = e.toString(); }
    finally { isLoading.value = false; }
  }

  Future<void> loadOwnAttendance(String eventId) async {
    isLoading.value = true;
    try { ownResult.value = await _repository.own(eventId); }
    on Exception catch (e) { lastScanMessage.value = e.toString(); }
    finally { isLoading.value = false; }
  }

  Future<bool> scanDemoQr(String token) async {
    lastScanMessage.value = null;
    scannerReady.value = false;
    try {
      final result = await _repository.scan(token);
      lastScanMessage.value = '${result.eventTitle}: attendance recorded successfully (${result.qrType}).';
      return true;
    } on Exception catch (e) {
      lastScanMessage.value = e.toString();
      return false;
    } finally { scannerReady.value = true; }
  }

  Future<void> updateStatus(String attendanceId, AttendanceStatus status) async {
    try {
      final updated = await _repository.update(attendanceId, status.name.toUpperCase());
      final index = records.indexWhere((e) => e.id == attendanceId);
      if (index >= 0) records[index] = updated;
    } on Exception catch (e) { lastScanMessage.value = e.toString(); }
  }
  Future<AttendanceOwnResult> ownForUi(String eventId) => _repository.own(eventId);

}
