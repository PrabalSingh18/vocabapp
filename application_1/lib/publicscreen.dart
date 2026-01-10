import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  // FIX: Added a const constructor with the key parameter.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Daily Streak: 7 days'),
            const SizedBox(height: 16),
            const Text('User Name: John Doe'),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Start Quiz'),
              onPressed: () {
                // Implement quiz functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}