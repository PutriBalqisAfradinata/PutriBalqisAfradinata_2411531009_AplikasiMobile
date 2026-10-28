class AppUser {
  const AppUser({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
        id: map['id'] as int,
        name: map['name'] as String,
        email: map['email'] as String,
      );
}
