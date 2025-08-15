import 'package:flutter/material.dart';

import 'package:gotravel/presentation/widgets/custom_button.dart';
import 'package:gotravel/presentation/widgets/custom_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/core/constants/app_assets.dart';
import 'package:provider/provider.dart';
import 'package:gotravel/presentation/providers/sign_up_provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Consumer<SignUpProvider>(
              builder: (context, provider, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(AppAssets.logo),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      'Sign Up',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your account to get started.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: provider.nameController,
                            labelText: 'Full Name',
                            prefixIcon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: provider.emailController,
                            labelText: 'Email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: provider.passwordController,
                            labelText: 'Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: provider.obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                provider.obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: provider.toggleObscurePassword,
                            ),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: provider.isLoading
                                ? 'Signing Up...'
                                : 'Sign Up',
                            height: 50,
                            width: double.infinity,
                            onPressed: provider.isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      provider.setLoading(true);
                                      Future.delayed(
                                        const Duration(seconds: 1),
                                        () {
                                          provider.setLoading(false);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Account created (mock)!',
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 8,
                            children: [
                              Text(
                                "Already have an account?",
                                style: theme.textTheme.bodyMedium,
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.go('/login');
                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }, // end builder
            ), // end Consumer
          ), // end SingleChildScrollView
        ), // end Center
      ), // end SafeArea
    );
  }
}
