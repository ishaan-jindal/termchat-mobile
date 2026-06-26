import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/room_sessions_table.dart';
import 'tables/messages_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [RoomSessions, Messages])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  static Future<AppDatabase> create() async {
    return AppDatabase(_openConnection());
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'termchat.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
