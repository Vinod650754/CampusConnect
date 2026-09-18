import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../repositories/certificate_repository.dart';
import 'certificate_model.dart';

class CertificateController extends GetxController {
  final CertificateRepository _repository;
  CertificateController({CertificateRepository? repository}) : _repository = repository ?? CertificateRepository(Get.find<ApiClient>());
  final RxList<CertificateModel> certificates = <CertificateModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  @override void onInit() { super.onInit(); loadCertificates(); }
  Future<void> loadCertificates() async { isLoading.value = true; try { certificates.assignAll(await _repository.my()); } on Exception catch (e) { errorMessage.value = e.toString(); } finally { isLoading.value = false; } }
  Future<bool> addCertificate(CertificateModel draft) async { try { final c = await _repository.issue(userId: draft.userId, eventId: draft.eventId, title: draft.title, certificateUrl: draft.certificateUrl); certificates.insert(0, c); return true; } on Exception catch (e) { errorMessage.value = e.toString(); return false; } }
  Future<bool> revokeCertificate(String id) async { try { final c = await _repository.revoke(id); final i = certificates.indexWhere((e) => e.id == id); if (i >= 0) certificates[i] = c; return true; } on Exception catch (e) { errorMessage.value = e.toString(); return false; } }
}
