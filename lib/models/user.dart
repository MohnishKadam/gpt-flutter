import 'ai_model.dart';

class User {
  final String id;
  final String name;
  final String email;
  final AIModel preferredModel;
  final bool isDarkTheme;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.preferredModel = AIModel.gemini15Flash,
    this.isDarkTheme = true,
    required this.createdAt,
  });

  User copyWith({
    String? name,
    String? email,
    AIModel? preferredModel,
    bool? isDarkTheme,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      preferredModel: preferredModel ?? this.preferredModel,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferredModel': preferredModel.name,
      'isDarkTheme': isDarkTheme,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      preferredModel: AIModel.values.firstWhere(
        (e) => e.name == json['preferredModel'],
        orElse: () => AIModel.gemini15Flash,
      ),
      isDarkTheme: json['isDarkTheme'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
