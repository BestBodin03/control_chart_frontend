class Profile {
  final String id;
  final String name;
  final String summary;
  final DateTime createdAt;
  bool active;
  Profile({
    required this.id,
    required this.name,
    required this.summary,
    required this.createdAt,
    required this.active,
  });
}