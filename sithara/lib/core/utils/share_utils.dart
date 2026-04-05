import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/share_tray/models/share_item.dart';
import '../../features/upload/data/storage_repository.dart';

Future<void> shareItems(
  BuildContext context,
  List<ShareItem> items,
  StorageRepository storageRepo,
) async {
  final tempDir = Directory.systemTemp;
  final xFiles = <XFile>[];
  final textParts = <String>[];

  for (int i = 0; i < items.length; i++) {
    final item = items[i];
    try {
      final bytes = await storageRepo.downloadFile(item.imageFileId);
      final tempFile = File('${tempDir.path}/share_${item.productId}_$i.jpg');
      await tempFile.writeAsBytes(bytes);
      xFiles.add(XFile(tempFile.path));
      if (item.description.isNotEmpty) {
        textParts.add(item.description);
      }
    } catch (e) {
      // Skip failed downloads — share the rest
    }
  }

  if (xFiles.isEmpty) return;

  await Share.shareXFiles(
    xFiles,
    text: textParts.join('\n\n'),
  );

  // Clean up temp files after sharing
  for (final xFile in xFiles) {
    try {
      await File(xFile.path).delete();
    } catch (_) {}
  }
}
