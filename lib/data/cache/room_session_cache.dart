import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../../core/models/room_session.dart';

class RoomSessionCache {
  final AppDatabase _db;

  RoomSessionCache(this._db);

  Future<List<RoomSession>> getAll() async {
    final query = _db.select(_db.roomSessions)
      ..orderBy([(t) => OrderingTerm.desc(t.lastAccessedAt)]);
    final entries = await query.get();
    return entries.map(_toModel).toList();
  }

  Future<RoomSession?> get(String roomId) async {
    final entry = await (_db.select(
      _db.roomSessions,
    )..where((t) => t.roomId.equals(roomId))).getSingleOrNull();
    return entry != null ? _toModel(entry) : null;
  }

  Future<void> save(RoomSession session) async {
    await _db
        .into(_db.roomSessions)
        .insertOnConflictUpdate(
          RoomSessionsCompanion(
            roomId: Value(session.roomId),
            roomName: Value(session.roomName),
            isLocked: Value(session.isLocked),
            unreadCount: Value(session.unreadCount),
            lastAccessedAt: Value(session.lastAccessedAt),
            createdAt: Value(session.createdAt),
          ),
        );
  }

  Future<void> delete(String roomId) async {
    await (_db.delete(
      _db.roomSessions,
    )..where((t) => t.roomId.equals(roomId))).go();
  }

  Future<void> incrementUnread(String roomId) async {
    await _db.customUpdate(
      'UPDATE room_sessions SET unread_count = unread_count + 1'
      ' WHERE room_id = ?',
      variables: [Variable.withString(roomId)],
    );
  }

  Future<void> clearUnread(String roomId) async {
    await (_db.update(_db.roomSessions)..where((t) => t.roomId.equals(roomId)))
        .write(const RoomSessionsCompanion(unreadCount: Value(0)));
  }

  Future<void> clearAll() async {
    await _db.delete(_db.roomSessions).go();
  }

  Future<void> updateLastAccessed(String roomId) async {
    await (_db.update(
      _db.roomSessions,
    )..where((t) => t.roomId.equals(roomId))).write(
      RoomSessionsCompanion(
        lastAccessedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  RoomSession _toModel(RoomSessionEntry entry) {
    return RoomSession(
      roomId: entry.roomId,
      roomName: entry.roomName,
      isLocked: entry.isLocked,
      unreadCount: entry.unreadCount,
      lastAccessedAt: entry.lastAccessedAt,
      createdAt: entry.createdAt,
    );
  }
}
