import 'package:flutter/material.dart';

// Voice cart screen removed - placeholder.
// The voice cart screen was added earlier but has been reverted per user request.
// Keep this placeholder to avoid import errors from other parts of the app.

class VoiceCartScreen extends StatelessWidget {
  const VoiceCartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Cart (Removed)')),
      body: const Center(child: Text('Voice cart feature has been removed.')),
    );
  }
}
