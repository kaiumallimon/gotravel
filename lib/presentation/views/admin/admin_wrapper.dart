import 'package:flutter/material.dart';
import 'package:gotravel/presentation/providers/admin_wrapper_provider.dart';
import 'package:gotravel/presentation/providers/sign_in_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AdminWrapper extends StatefulWidget {
  const AdminWrapper({super.key});

  @override
  State<AdminWrapper> createState() => _AdminWrapperState();
}

class _AdminWrapperState extends State<AdminWrapper> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final adminWrapperProvider = Provider.of<AdminWrapperProvider>(context, listen: false);
    _tabController = TabController(length: adminWrapperProvider.tabs.length, vsync: this);
    
    // Use post-frame callback to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adminWrapperProvider.setTabController(_tabController);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminWrapperProvider = Provider.of<AdminWrapperProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          toolbarHeight: 80,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
          title: Text.rich(
            TextSpan(
              text: "Welcome\n",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(.5),
              ),
              children: [
                TextSpan(
                  text: adminWrapperProvider.accountData?.name ?? "Admin",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
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
              icon: Icon(Icons.logout, color: theme.colorScheme.primary),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.textTheme.bodyLarge?.color,
            indicatorColor: theme.colorScheme.primary,
            dividerColor: theme.colorScheme.primary.withAlpha(30),
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            tabAlignment: TabAlignment.start,
            tabs: adminWrapperProvider.tabs
                .map((tab) => Tab(text: tab['title'] as String))
                .toList(),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          // physics: const NeverScrollableScrollPhysics(), // optional: control swipe
          children: adminWrapperProvider.tabs
              .map((tab) => tab['child'] as Widget)
              .toList(),
        ),
      
    );
  }
}
