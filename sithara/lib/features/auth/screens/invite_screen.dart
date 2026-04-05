import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InviteScreen extends ConsumerWidget {
  final String token;

  const InviteScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invite')),
      body: const Center(child: Text('Invite')),
    );
  }
}
