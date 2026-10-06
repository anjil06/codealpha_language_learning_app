import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/app_providers.dart';
import '../../core/widgets/custom_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.sendPasswordResetEmail(_emailController.text);
      if (mounted) {
        setState(() {
          _isSubmitted = true;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send reset link. Please check email address.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: _isSubmitted ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_rounded, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            'Forgot your password?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your registered email address and we will send you a secure link to reset your password.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.lightTextSecondary),
          ),
          const SizedBox(height: 32),
          const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Send Reset Link',
            isLoading: _isLoading,
            icon: Icons.send_rounded,
            onPressed: _handleReset,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.success.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, size: 56, color: AppColors.success),
        ),
        const SizedBox(height: 24),
        const Text(
          'Email Sent Successfully!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'We have sent password reset instructions to ${_emailController.text}. Please check your inbox.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.lightTextSecondary),
        ),
        const SizedBox(height: 32),
        CustomButton(
          label: 'Back to Login',
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}

