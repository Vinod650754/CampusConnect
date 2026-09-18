import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../repositories/registration_repository.dart';
import 'registration_model.dart';

class RegistrationController extends GetxController {
  final RegistrationRepository _repository;
  RegistrationController({RegistrationRepository? repository}) : _repository = repository ?? RegistrationRepository(Get.find<ApiClient>());

  final RxList<RegistrationModel> registrations = <RegistrationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  List<RegistrationModel> get activeRegistrations => registrations.where((e) => e.status != RegistrationStatus.cancelled).toList();
  List<RegistrationModel> get upcomingRegistrations => activeRegistrations.where((e) => e.eventStartAt.isAfter(DateTime.now())).toList();

  @override
  void onInit() { super.onInit(); loadRegistrations(); }

  Future<void> loadRegistrations() async {
    isLoading.value = true;
    try {
      final result = await _repository.my();
      registrations.assignAll(result.registrations);
    } on Exception catch (e) { errorMessage.value = e.toString(); }
    finally { isLoading.value = false; }
  }

  Future<void> refresh() async => loadRegistrations();

  Future<bool> registerForEvent(String eventId) async {
    try {
      await _repository.register(eventId);
      await loadRegistrations();
      return true;
    } on Exception catch (e) { errorMessage.value = e.toString(); return false; }
  }

  Future<bool> cancelRegistration(String registrationId) async {
    try {
      await _repository.cancel(registrationId);
      await loadRegistrations();
      return true;
    } on Exception catch (e) { errorMessage.value = e.toString(); return false; }
  }

  Future<bool> updateStatus(String registrationId, RegistrationStatus status) async {
    try {
      await _repository.updateStatus(registrationId, status.name.toUpperCase());
      await loadRegistrations();
      return true;
    } on Exception catch (e) { errorMessage.value = e.toString(); return false; }
  }
}
