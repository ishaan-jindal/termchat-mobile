import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../../core/models/message.dart' as model;

class MessageCache {
  final AppDatabase _db;

  MessageCache(this._db);

  Future<List<model.Message>> getMessages(String roomId) async {
    final rows =
        await (_db.select(_db.messages)
              ..where((t) => t.roomId.equals(roomId))
              ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
            .get();
    return rows.map(_toModel).toList();
  }

  Future<void> insertMessage(model.Message message) async {
    await _db
        .into(_db.messages)
        .insert(_toCompanion(message), mode: InsertMode.replace);
  }

  Future<void> insertMessages(List<model.Message> messages) async {
    await _db.batch((b) {
      for (final msg in messages) {
        b.insert(_db.messages, _toCompanion(msg), mode: InsertMode.replace);
      }
    });
  }

  Future<void> replaceRoomMessages(
    String roomId,
    List<model.Message> messages,
  ) async {
    await (_db.delete(
      _db.messages,
    )..where((t) => t.roomId.equals(roomId))).go();
    if (messages.isNotEmpty) {
      await insertMessages(messages);
    }
  }

  Future<int> getMessageCount(String roomId) async {
    final rows = await (_db.select(
      _db.messages,
    )..where((t) => t.roomId.equals(roomId))).get();
    return rows.length;
  }

  Future<void> clearAll() async {
    await _db.delete(_db.messages).go();
  }

  Future<void> trimRoom(String roomId, {int keep = 500}) async {
    final count = await getMessageCount(roomId);
    if (count <= keep) return;

    final rows =
        await (_db.select(_db.messages)
              ..where((t) => t.roomId.equals(roomId))
              ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
              ..limit(1, offset: keep - 1))
            .get();

    if (rows.isEmpty) return;

    final cutoffTimestamp = rows.first.timestamp;
    await (_db.delete(_db.messages)..where(
          (t) =>
              t.roomId.equals(roomId) &
              t.timestamp.isSmallerThan(Constant(cutoffTimestamp)),
        ))
        .go();
  }

  model.Message _toModel(Message row) {
    return model.Message(
      id: row.id,
      roomId: row.roomId,
      senderId: row.senderId,
      senderNickname: row.senderNickname,
      senderColorHex: row.senderColorHex,
      content: row.content,
      timestamp: DateTime.fromMillisecondsSinceEpoch(row.timestamp),
      isSystemMessage: row.isSystemMessage,
    );
  }

  MessagesCompanion _toCompanion(model.Message msg) {
    return MessagesCompanion(
      id: Value(msg.id),
      roomId: Value(msg.roomId),
      senderId: Value(msg.senderId),
      senderNickname: Value(msg.senderNickname),
      senderColorHex: Value(msg.senderColorHex),
      content: Value(msg.content),
      timestamp: Value(msg.timestamp.millisecondsSinceEpoch),
      isSystemMessage: Value(msg.isSystemMessage),
    );
  }
}
