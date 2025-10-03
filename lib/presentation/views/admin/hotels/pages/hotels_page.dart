import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/core/routes/app_routes.dart';

class AdminHotelsPage extends StatefulWidget {
  const AdminHotelsPage({super.key});

  @override
  State<AdminHotelsPage> createState() => _AdminHotelsPageState();
}

class _AdminHotelsPageState extends State<AdminHotelsPage> {
  @override
  Widget build(BuildContext context) {
    
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('${AppRoutes.adminWrapper}${AppRoutes.addHotel}');
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        tooltip: "Add Hotel",
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }
}
