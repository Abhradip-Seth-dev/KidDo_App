enum LevelStatus { locked, current, completed }

class LevelModel {
  final String id;
  final int number;
  final String title;
  final LevelStatus status;
  final int stars; // 0-3

  const LevelModel({
    required this.id,
    required this.number,
    required this.title,
    this.status = LevelStatus.locked,
    this.stars = 0,
  });

  LevelModel copyWith({
    String? id,
    int? number,
    String? title,
    LevelStatus? status,
    int? stars,
  }) {
    return LevelModel(
      id: id ?? this.id,
      number: number ?? this.number,
      title: title ?? this.title,
      status: status ?? this.status,
      stars: stars ?? this.stars,
    );
  }
}
