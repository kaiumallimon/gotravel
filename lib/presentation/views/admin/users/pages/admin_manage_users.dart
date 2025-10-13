import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gotravel/data/models/user_account.dart';
import 'package:gotravel/presentation/providers/admin_users_provider.dart';
import 'package:gotravel/presentation/views/admin/users/pages/admin_add_user_page.dart';
import 'package:gotravel/presentation/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class AdminManageUsers extends StatefulWidget {
  const AdminManageUsers({super.key});

  @override
  State<AdminManageUsers> createState() => _AdminManageUsersState();
}

class _AdminManageUsersState extends State<AdminManageUsers> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminUsersProvider>(context, listen: false).loadUsers(context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AdminUsersProvider>(context);
    final users = provider.search(_searchController.text);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomTextField(
                  height: 56,
                  prefixIcon: CupertinoIcons.search,
                  labelText: "Search users by name, email, or role...",
                  controller: _searchController,
                ),
              ),

              const SizedBox(height: 16),

              // Stats Grid (responsive)
              _buildStatsGrid(theme, provider),

              const SizedBox(height: 16),

              // Users List
              Expanded(
                child: provider.isLoading
                    ? _buildLoading()
                    : users.isEmpty
                        ? _buildEmpty(theme)
                        : _buildUsersList(users, theme, provider),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminAddUserPage(),
            ),
          );
          
          // Refresh users list if a user was created
          if (result == true && mounted) {
            Provider.of<AdminUsersProvider>(context, listen: false).refresh(context);
          }
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(CupertinoIcons.person_add),
        label: const Text('Add User'),
        elevation: 8,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme, AdminUsersProvider provider) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount;
    if (width >= 1200) {
      crossAxisCount = 4;
    } else if (width >= 900) {
      crossAxisCount = 4;
    } else if (width >= 600) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    final items = [
      _buildStatCard(theme, 'Total Users', provider.totalUsers, Icons.people_alt_outlined, theme.colorScheme.primary),
      _buildStatCard(theme, 'Admins', provider.adminsCount, Icons.verified_user_outlined, Colors.orange),
      _buildStatCard(theme, 'Moderators', provider.moderatorsCount, Icons.shield_moon_outlined, Colors.purple),
      _buildStatCard(theme, 'Regular', provider.regularUsersCount, Icons.person_outline, Colors.teal),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 100
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(.7))),
              const SizedBox(height: 4),
              Text('$value', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Loading users...'),
        ],
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () => Provider.of<AdminUsersProvider>(context, listen: false).refresh(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.people_outline, size: 64, color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Text('No users found', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Users will appear here once registered.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(List<UserAccountModel> users, ThemeData theme, AdminUsersProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.refresh(context),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final u = users[index];
          return _buildUserTile(u, theme, provider);
        },
      ),
    );
  }

  Widget _buildUserTile(UserAccountModel user, ThemeData theme, AdminUsersProvider provider) {
    final roleColor = () {
      switch ((user.role ?? '').toLowerCase()) {
        case 'admin':
          return Colors.orange;
        case 'moderator':
          return Colors.purple;
        default:
          return Colors.teal;
      }
    }();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.surfaceVariant,
            child: Text((user.name ?? user.email ?? 'U').trim().isEmpty ? 'U' : (user.name ?? user.email ?? 'U')[0].toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name ?? 'Unknown', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(user.email ?? 'N/A', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(.7))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: roleColor.withOpacity(.3)),
                      ),
                      child: Text((user.role ?? 'user').toUpperCase(), style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.calendar_today_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(.6)),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(user.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(.6)),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            tooltip: 'Actions',
            onSelected: (value) async {
              if (value.startsWith('role:')) {
                final newRole = value.split(':').last;
                await provider.changeRole(userId: user.id ?? '', newRole: newRole, context: context);
              } else if (value == 'delete') {
                await _showDeleteConfirmation(user, provider);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'role:admin', child: Text('Make Admin')),
              const PopupMenuItem(value: 'role:moderator', child: Text('Make Moderator')),
              const PopupMenuItem(value: 'role:user', child: Text('Make Regular User')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'delete', child: Text('Delete User')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.more_horiz, color: theme.colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(UserAccountModel user, AdminUsersProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this user?'),
            const SizedBox(height: 8),
            Text('Name: ${user.name ?? 'Unknown'}', style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('Email: ${user.email ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone. The user will be completely removed from both the application and authentication system.',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteUser(userId: user.id ?? '', context: context);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    // Keeping simple to avoid adding intl usage here since project already has intl dep if needed
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}