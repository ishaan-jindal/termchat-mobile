class Reaction {
  final String name;
  final int count;

  const Reaction({required this.name, required this.count});

  Reaction copyWith({String? name, int? count}) {
    return Reaction(name: name ?? this.name, count: count ?? this.count);
  }
}

const List<String> reactionNames = <String>[
  '+1',
  '-1',
  'laugh',
  'heart',
  'wow',
  'eyes',
  'fire',
  'clap',
];
