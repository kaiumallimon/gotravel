import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/core/routes/app_routes.dart';
import 'package:gotravel/data/services/local/hive_service.dart';
import 'package:gotravel/data/services/remote/supabase_auth_service.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class SignInProvider extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }

  final service = SupabaseAuthService();

  Future<void> signIn(BuildContext context) async {
    setLoading(true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final response = await service.signIn(
        email,
        password,
      );

      if (response==null || response.id == null) {
        _showError(context, "Something went wrong, Please try again later!");
        service.signOut();
        return;
      }

      clearAllControllers();
      // Store user data in a local storage:

      HiveService.saveData('user', 'accountData', response.toJson());
      response.role == 'admin'
          ? context.go(AppRoutes.adminWrapper)
          : context.go(AppRoutes.userWrapper);
    } catch (error) {
      _showError(context, error.toString());
    } finally {
      setLoading(false);
    }
  }

  void _showError(BuildContext context, String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: "Sign In Failed",
      text: message,
    );
  }

  void clearAllControllers() {
    emailController.clear();
    passwordController.clear();
  }


  Future<void> signOut(BuildContext context) async {
    await service.signOut();
    await HiveService.clearBox('user');
    context.go(AppRoutes.login);
  }
}
