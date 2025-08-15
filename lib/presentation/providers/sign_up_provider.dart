import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/core/routes/app_routes.dart';
import 'package:gotravel/data/services/remote/supabase_auth_service.dart';
import 'package:quickalert/quickalert.dart';

class SignUpProvider extends ChangeNotifier {
  final nameController = TextEditingController();
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  final service = SupabaseAuthService();

  Future<void> signUp(BuildContext context) async {
    setLoading(true);

    try {
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final response = await service.signUp(
        email: email,
        password: password,
        fullName: name,
      );

      if (response?.user == null) {
        _showError(context, "Please try again later.");
        return;
      }

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Sign Up Successful",
        text: "Welcome ${response!.user!.email}!",
        onConfirmBtnTap: () {
          clearAllControllers();
          Navigator.of(context).pop();
          context.push(AppRoutes.login);
        },
      );
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
      title: "Sign Up Failed",
      text: message,
    );
  }

  void clearAllControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }
}
