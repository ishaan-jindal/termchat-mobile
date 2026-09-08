class BackendReaction {
  final String name;
  final int count;

  BackendReaction({required this.name, required this.count});

  factory BackendReaction.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw const FormatException('missing reaction name');
    }
    return BackendReaction(name: name, count: json['count'] as int? ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'count': count};
  }
}
