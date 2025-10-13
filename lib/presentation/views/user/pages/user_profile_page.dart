import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gotravel/presentation/providers/sign_in_provider.dart';
import 'package:gotravel/presentation/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<UserProfileProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: provider.isLoading
            ? _buildLoading()
            : RefreshIndicator(
                onRefresh: () => provider.refreshProfile(context),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Profile Header
                    SliverToBoxAdapter(
                      child: _buildProfileHeader(theme, provider),
                    ),

                    // Profile Options
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildOptionTile(
                              icon: CupertinoIcons.person_circle,
                              title: 'Edit Profile',
                              subtitle: 'Update your personal information',
                              onTap: () {
                                // TODO: Navigate to edit profile
                              },
                              theme: theme,
                            ),
                            _buildOptionTile(
                              icon: CupertinoIcons.bell,
                              title: 'Notifications',
                              subtitle: 'Manage your notification preferences',
                              onTap: () {
                                // TODO: Navigate to notifications settings
                              },
                              theme: theme,
                            ),
                            _buildOptionTile(
                              icon: CupertinoIcons.heart,
                              title: 'Favorites',
                              subtitle: 'View your saved packages and hotels',
                              onTap: () {
                                // TODO: Navigate to favorites
                              },
                              theme: theme,
                            ),
                            _buildOptionTile(
                              icon: CupertinoIcons.book,
                              title: 'My Bookings',
                              subtitle: 'View your travel history',
                              onTap: () {
                                // TODO: Navigate to bookings
                              },
                              theme: theme,
                            ),

                            const SizedBox(height: 32),

                            Text(
                              'Support',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildOptionTile(
                              icon: CupertinoIcons.question_circle,
                              title: 'Help & Support',
                              subtitle: 'Get help with your account',
                              onTap: () {
                                // TODO: Navigate to help
                              },
                              theme: theme,
                            ),
                            _buildOptionTile(
                              icon: CupertinoIcons.doc_text,
                              title: 'Terms & Conditions',
                              subtitle: 'Read our terms and policies',
                              onTap: () {
                                // TODO: Navigate to terms
                              },
                              theme: theme,
                            ),
                            _buildOptionTile(
                              icon: CupertinoIcons.info_circle,
                              title: 'About',
                              subtitle: 'Learn more about GoTravel',
                              onTap: () {
                                // TODO: Navigate to about
                              },
                              theme: theme,
                            ),

                            const SizedBox(height: 32),

                            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showSignOutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer,
                  foregroundColor: theme.colorScheme.onErrorContainer,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.square_arrow_right),
                    const SizedBox(width: 8),
                    const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading profile...'),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, UserProfileProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                provider.userInitials,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            provider.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          // Email
          if (provider.userAccount?.email != null)
            Text(
              provider.userAccount!.email!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),

          const SizedBox(height: 16),

          // Stats Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Member Since', provider.memberSince),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStatItem('Role', provider.userAccount?.role?.toUpperCase() ?? 'USER'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Icon(
          CupertinoIcons.chevron_right,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          size: 16,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: "Sign Out",
      text: "Are you sure you want to sign out?",
      confirmBtnText: "Yes",
      cancelBtnText: "No",
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        Provider.of<SignInProvider>(
          context,
          listen: false,
        ).signOut(context);
      },
    );
  }
}