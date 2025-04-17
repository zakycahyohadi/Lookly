import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'history_item.g.dart';

@HiveType(typeId: 0)
class HistoryItem extends HiveObject {
  @HiveField(0)
  final String? imagePath; // Untuk Mobile

  @HiveField(1)
  final Uint8List? webImageBytes; // Untuk Web

  @HiveField(2)
  final String result;

  @HiveField(3)
  final DateTime createdAt;

  HistoryItem({
    this.imagePath,
    this.webImageBytes,
    required this.result,
    required this.createdAt,
  });
}
