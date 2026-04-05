import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BgRemovalScreen extends ConsumerWidget {
  const BgRemovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Background Removal')),
      body: const Center(child: Text('Background Removal')),
    );
  }
}
