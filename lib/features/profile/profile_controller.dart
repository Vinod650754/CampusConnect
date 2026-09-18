import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../models/user_model.dart';
import '../../repositories/profile_repository.dart';
import '../auth/auth_controller.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository;
  ProfileController({ProfileRepository? repository}) : _repository = repository ?? ProfileRepository(Get.find<ApiClient>());
  final Rxn<UserModel> profile = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  @override void onInit() { super.onInit(); loadProfile(); }
  Future<void> loadProfile() async { isLoading.value = true; try { final loaded = await _repository.get(); profile.value = loaded; if (Get.isRegistered<AuthController>()) { Get.find<AuthController>().currentUser.value = loaded; } } on Exception catch (e) { errorMessage.value = e.toString(); } finally { isLoading.value = false; } }
  Future<bool> updateProfile({required String fullName, required String phone, required String email, String? avatarUrl, String? bio}) async { try { await _repository.update(fullName: fullName, phone: phone, email: email, avatarUrl: avatarUrl, bio: bio); await loadProfile(); return true; } on Exception catch (e) { errorMessage.value = e.toString(); return false; } }
  Future<bool> changePassword({required String currentPassword, required String newPassword}) async { try { await _repository.changePassword(currentPassword: currentPassword, newPassword: newPassword); return true; } on Exception catch (e) { errorMessage.value = e.toString(); return false; } }
}
