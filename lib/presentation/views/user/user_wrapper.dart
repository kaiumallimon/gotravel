import 'package:flutter/material.dart';

class UserWrapper extends StatelessWidget {
  const UserWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Wrapper')),
      body: Center(child: Text('User Wrapper Content')),
    );
  }
}
