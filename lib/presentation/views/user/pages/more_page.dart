import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotravel/presentation/providers/sign_in_provider.dart';
import 'package:gotravel/presentation/views/user/pages/edit_profile_page.dart';
import 'package:gotravel/presentation/views/user/pages/saved_items_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Profile Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Center(
                        child: Text(
                          user?.email?.substring(0, 2).toUpperCase() ?? 'JD',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      user?.email?.split('@').first ?? 'John Doe',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    Text(
                      user?.email ?? 'user@example.com',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard('Trips', '3', theme),
                        _buildStatCard('Countries', '2', theme),
                        _buildStatCard('Reviews', '5', theme),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Menu Items
              _buildMenuSection('Account', [
                _buildMenuItem(
                  icon: CupertinoIcons.person_circle,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  },
                  theme: theme,
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.heart,
                  title: 'Saved Items',
                  subtitle: 'Your favorite places and packages',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SavedItemsPage(),
                      ),
                    );
                  },
                  theme: theme,
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.bell,
                  title: 'Notifications',
                  subtitle: 'Manage your notification preferences',
                  onTap: () {
                    // TODO: Navigate to notifications
                  },
                  theme: theme,
                ),
              ], theme),
              
              const SizedBox(height: 16),
              
              _buildMenuSection('Support', [
                _buildMenuItem(
                  icon: CupertinoIcons.question_circle,
                  title: 'Help & Support',
                  subtitle: 'Get help with your bookings',
                  onTap: () {
                    // TODO: Navigate to help
                  },
                  theme: theme,
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.doc_text,
                  title: 'Terms & Conditions',
                  subtitle: 'Read our terms and policies',
                  onTap: () {
                    // TODO: Navigate to terms
                  },
                  theme: theme,
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.star,
                  title: 'Rate Our App',
                  subtitle: 'Help us improve with your feedback',
                  onTap: () {
                    // TODO: Open app store rating
                  },
                  theme: theme,
                ),
              ], theme),
              
              const SizedBox(height: 16),
              
              _buildMenuSection('Settings', [
                _buildMenuItem(
                  icon: CupertinoIcons.settings,
                  title: 'App Settings',
                  subtitle: 'Customize your app experience',
                  onTap: () {
                    // TODO: Navigate to settings
                  },
                  theme: theme,
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.lock,
                  title: 'Privacy & Security',
                  subtitle: 'Manage your privacy settings',
                  onTap: () {
                    // TODO: Navigate to privacy
                  },
                  theme: theme,
                ),
              ], theme),
              
              const SizedBox(height: 24),
              
              // Logout Button
              Container(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
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
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.square_arrow_right,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // App Version
              Text(
                'Version 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        CupertinoIcons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
        size: 16,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }


}