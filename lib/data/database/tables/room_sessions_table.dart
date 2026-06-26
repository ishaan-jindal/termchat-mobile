import 'package:drift/drift.dart';

@DataClassName('RoomSessionEntry')
class RoomSessions extends Table {
  TextColumn get roomId => text()();
  TextColumn get roomName => text()();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  IntColumn get lastAccessedAt => integer()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {roomId};
}
