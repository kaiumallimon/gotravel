import 'package:flutter/material.dart';

class AdminWrapper extends StatelessWidget {
  const AdminWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Wrapper')),
      body: Center(child: Text('Admin Wrapper Content')),
    );
  }
}
