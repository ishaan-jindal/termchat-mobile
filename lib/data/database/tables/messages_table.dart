import 'package:drift/drift.dart';

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get roomId => text()();
  TextColumn get senderId => text()();
  TextColumn get senderNickname => text()();
  TextColumn get senderColorHex => text()();
  TextColumn get content => text()();
  IntColumn get timestamp => integer()();
  BoolColumn get isSystemMessage =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id, roomId};
}
