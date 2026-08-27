class BackendReaction {
  final String name;
  final int count;

  BackendReaction({required this.name, required this.count});

  factory BackendReaction.fromJson(Map<String, dynamic> json) {
    return BackendReaction(
      name: json['name'] as String,
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'count': count};
  }
}
