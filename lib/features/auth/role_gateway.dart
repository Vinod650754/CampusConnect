import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import 'auth_controller.dart';

class RoleGateway extends GetView<AuthController> {
  const RoleGateway({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser.value;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          Get.offAllNamed(
            AppRoutes.login,
          );
        },
      );

      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    switch (user.role) {
      case 'SUPER_ADMIN':
        return _redirect(
          AppRoutes.superAdmin,
        );

      case 'ADMIN':
        return _redirect(
          AppRoutes.admin,
        );

      case 'CORE_TEAM':
        return _redirect(
          AppRoutes.coreTeam,
        );

      case 'MEMBER':
        return _redirect(
          AppRoutes.member,
        );

      case 'STUDENT':
        return _redirect(
          AppRoutes.student,
        );

      default:
        return const Scaffold(
          body: Center(
            child: Text(
              'Unknown account role.',
            ),
          ),
        );
    }
  }

  Widget _redirect(
    String route,
  ) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (Get.currentRoute != route) {
          Get.offNamed(route);
        }
      },
    );

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
