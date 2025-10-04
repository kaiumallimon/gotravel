import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/core/routes/app_routes.dart';
import 'package:gotravel/presentation/widgets/custom_text_field.dart';

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
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 13, vertical: 10),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: CustomTextField(
                height: 50,
                prefixIcon: CupertinoIcons.search,
                labelText: "Search Hotel",
                controller: TextEditingController(),
              ),
            )
          ],
        ),
      ),

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
