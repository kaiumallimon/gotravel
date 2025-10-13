import 'package:flutter/material.dart';
import 'package:gotravel/data/services/remote/supabase_auth_service.dart';

class AdminAddUserProvider extends ChangeNotifier {
  final SupabaseAuthService _authService = SupabaseAuthService();

  bool _isLoading = false;
  String _selectedRole = 'user';
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  bool get isLoading => _isLoading;
  String get selectedRole => _selectedRole;
  bool get showPassword => _showPassword;
  bool get showConfirmPassword => _showConfirmPassword;

  void setRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _showConfirmPassword = !_showConfirmPassword;
    notifyListeners();
  }

  Future<bool> createUser({
    required String name,
    required String email, 
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Create user with auth service (which also creates entry in public.users table)
      final response = await _authService.signUp(
        email: email,
        password: password,
        fullName: name,
        role: _selectedRole,
      );

      if (response?.user != null) {

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } else {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      String errorMessage = 'Error creating user: $e';
      
      // Handle specific error cases
      if (e.toString().toLowerCase().contains('user already registered')) {
        errorMessage = 'A user with this email address already exists.';
      } else if (e.toString().toLowerCase().contains('invalid email')) {
        errorMessage = 'Please enter a valid email address.';
      } else if (e.toString().toLowerCase().contains('weak password')) {
        errorMessage = 'Password is too weak. Please choose a stronger password.';
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  void reset() {
    _selectedRole = 'user';
    _showPassword = false;
    _showConfirmPassword = false;
    _isLoading = false;
    notifyListeners();
  }
}