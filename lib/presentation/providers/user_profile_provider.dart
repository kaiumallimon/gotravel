import 'package:flutter/material.dart';
import 'package:gotravel/data/models/user_account.dart';
import 'package:gotravel/data/services/local/hive_service.dart';
import 'package:gotravel/data/services/remote/supabase_auth_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final SupabaseAuthService _authService = SupabaseAuthService();
  
  UserAccountModel? _userAccount;
  bool _isLoading = false;
  String? _error;

  UserAccountModel? get userAccount => _userAccount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserProfileProvider() {
    loadUserProfile();
  }

  void loadUserProfile() {
    final userData = HiveService.getData(
      'user',
      'accountData',
      defaultValue: null,
    );
    
    _userAccount = userData == null
        ? null
        : UserAccountModel.fromJson(userData);
    notifyListeners();
  }

  Future<void> refreshProfile(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In a real app, you might want to fetch fresh data from the server
      loadUserProfile();
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing profile: $_error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      
      // Clear local data
      await HiveService.clearBox('user');
      _userAccount = null;
      
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/welcome',
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user statistics (could be extended with bookings, favorites, etc.)
  String get userInitials {
    if (_userAccount?.name != null && _userAccount!.name!.isNotEmpty) {
      final names = _userAccount!.name!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else {
        return names[0][0].toUpperCase();
      }
    } else if (_userAccount?.email != null && _userAccount!.email!.isNotEmpty) {
      return _userAccount!.email![0].toUpperCase();
    }
    return 'U';
  }

  String get displayName {
    return _userAccount?.name ?? _userAccount?.email ?? 'User';
  }

  String get memberSince {
    if (_userAccount?.createdAt != null) {
      final date = _userAccount!.createdAt!;
      return '${date.year}-${date.month.toString().padLeft(2, '0')}';
    }
    return 'Unknown';
  }
}