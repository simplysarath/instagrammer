import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagReviewScreen extends ConsumerWidget {
  const TagReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tag Review')),
      body: const Center(child: Text('Tag Review')),
    );
  }
}
