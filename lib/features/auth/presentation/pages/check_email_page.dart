import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckEmailPage extends StatelessWidget {
  const CheckEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Successful'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_unread_outlined,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                'Check Your Email',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'We have sent a confirmation link to your email address. Please click the link to verify your account and complete the registration.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
