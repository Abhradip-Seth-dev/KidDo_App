class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final int iq;
  final int coins;
  final int streak;
  final int age;
  final String gradeClass;
  final bool hasCompletedOnboarding;

  const UserModel({
    required this.id,
    required this.name,
    this.email = '',
    required this.avatarUrl,
    required this.iq,
    required this.coins,
    required this.streak,
    this.age = 8,
    this.gradeClass = 'Class 3',
    this.hasCompletedOnboarding = false,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    int? iq,
    int? coins,
    int? streak,
    int? age,
    String? gradeClass,
    bool? hasCompletedOnboarding,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      iq: iq ?? this.iq,
      coins: coins ?? this.coins,
      streak: streak ?? this.streak,
      age: age ?? this.age,
      gradeClass: gradeClass ?? this.gradeClass,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}
