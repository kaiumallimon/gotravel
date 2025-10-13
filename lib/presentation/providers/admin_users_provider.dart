import 'package:flutter/material.dart';
import 'package:gotravel/data/models/user_account.dart';
import 'package:gotravel/data/services/remote/admin_manage_users.dart';

class AdminUsersProvider extends ChangeNotifier {
  final AdminUsersService _service = AdminUsersService();

  List<UserAccountModel> _users = [];
  bool _isLoading = false;
  String? _error;

  List<UserAccountModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsers(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _service.fetchUsers();
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $_error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(BuildContext context) async {
    await loadUsers(context);
  }

  // Stats
  int get totalUsers => _users.length;
  int get adminsCount => _users.where((u) => (u.role ?? '').toLowerCase() == 'admin').length;
  int get moderatorsCount => _users.where((u) => (u.role ?? '').toLowerCase() == 'moderator').length;
  int get regularUsersCount => _users.where((u) => (u.role ?? '').toLowerCase() == 'user').length;

  List<UserAccountModel> search(String query) {
    if (query.trim().isEmpty) return _users;
    final q = query.toLowerCase();
    return _users.where((u) {
      final email = (u.email ?? '').toLowerCase();
      final name = (u.name ?? '').toLowerCase();
      final role = (u.role ?? '').toLowerCase();
      return email.contains(q) || name.contains(q) || role.contains(q);
    }).toList();
  }

  Future<void> changeRole({required String userId, required String newRole, required BuildContext context}) async {
    try {
      await _service.updateUserRole(userId: userId, role: newRole);
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        final current = _users[idx];
        _users[idx] = UserAccountModel(
          id: current.id,
          email: current.email,
          name: current.name,
          role: newRole,
          createdAt: current.createdAt,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role updated'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update role: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> deleteUser({required String userId, required BuildContext context}) async {
    try {
      await _service.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
