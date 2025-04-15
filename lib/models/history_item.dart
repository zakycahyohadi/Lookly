import 'package:hive/hive.dart';

part 'history_item.g.dart';

@HiveType(typeId: 0)
class HistoryItem extends HiveObject {
  @HiveField(0)
  final String imagePath;

  @HiveField(1)
  final String result;

  @HiveField(2)
  final DateTime createdAt;

  HistoryItem({
    required this.imagePath,
    required this.result,
    required this.createdAt,
  });
}
