/// 示例领域模型：一条条目。
///
/// 换成自己的业务模型时，同步改 [ItemsRepository] 里的存储版本号，
/// 并补一条 JSON 往返测试（见 test/item_test.dart）。
class Item {
  const Item({
    required this.id,
    required this.title,
    this.note = '',
    required this.createdAt,
  });

  final String id;
  final String title;
  final String note;
  final DateTime createdAt;

  Item copyWith({String? title, String? note}) {
    return Item(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'title': title,
    'note': note,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory Item.fromJson(Map<String, Object?> json) {
    return Item(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      note: json['note'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['createdAt'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}
