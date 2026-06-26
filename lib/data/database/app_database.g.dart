// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RoomSessionsTable extends RoomSessions
    with TableInfo<$RoomSessionsTable, RoomSessionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomNameMeta = const VerificationMeta(
    'roomName',
  );
  @override
  late final GeneratedColumn<String> roomName = GeneratedColumn<String>(
    'room_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<int> lastAccessedAt = GeneratedColumn<int>(
    'last_accessed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    roomId,
    roomName,
    isLocked,
    unreadCount,
    lastAccessedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'room_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoomSessionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('room_name')) {
      context.handle(
        _roomNameMeta,
        roomName.isAcceptableOrUnknown(data['room_name']!, _roomNameMeta),
      );
    } else if (isInserting) {
      context.missing(_roomNameMeta);
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {roomId};
  @override
  RoomSessionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomSessionEntry(
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      )!,
      roomName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_name'],
      )!,
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_accessed_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RoomSessionsTable createAlias(String alias) {
    return $RoomSessionsTable(attachedDatabase, alias);
  }
}

class RoomSessionEntry extends DataClass
    implements Insertable<RoomSessionEntry> {
  final String roomId;
  final String roomName;
  final bool isLocked;
  final int unreadCount;
  final int lastAccessedAt;
  final int createdAt;
  const RoomSessionEntry({
    required this.roomId,
    required this.roomName,
    required this.isLocked,
    required this.unreadCount,
    required this.lastAccessedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['room_id'] = Variable<String>(roomId);
    map['room_name'] = Variable<String>(roomName);
    map['is_locked'] = Variable<bool>(isLocked);
    map['unread_count'] = Variable<int>(unreadCount);
    map['last_accessed_at'] = Variable<int>(lastAccessedAt);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  RoomSessionsCompanion toCompanion(bool nullToAbsent) {
    return RoomSessionsCompanion(
      roomId: Value(roomId),
      roomName: Value(roomName),
      isLocked: Value(isLocked),
      unreadCount: Value(unreadCount),
      lastAccessedAt: Value(lastAccessedAt),
      createdAt: Value(createdAt),
    );
  }

  factory RoomSessionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomSessionEntry(
      roomId: serializer.fromJson<String>(json['roomId']),
      roomName: serializer.fromJson<String>(json['roomName']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      lastAccessedAt: serializer.fromJson<int>(json['lastAccessedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roomId': serializer.toJson<String>(roomId),
      'roomName': serializer.toJson<String>(roomName),
      'isLocked': serializer.toJson<bool>(isLocked),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'lastAccessedAt': serializer.toJson<int>(lastAccessedAt),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  RoomSessionEntry copyWith({
    String? roomId,
    String? roomName,
    bool? isLocked,
    int? unreadCount,
    int? lastAccessedAt,
    int? createdAt,
  }) => RoomSessionEntry(
    roomId: roomId ?? this.roomId,
    roomName: roomName ?? this.roomName,
    isLocked: isLocked ?? this.isLocked,
    unreadCount: unreadCount ?? this.unreadCount,
    lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  RoomSessionEntry copyWithCompanion(RoomSessionsCompanion data) {
    return RoomSessionEntry(
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      roomName: data.roomName.present ? data.roomName.value : this.roomName,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoomSessionEntry(')
          ..write('roomId: $roomId, ')
          ..write('roomName: $roomName, ')
          ..write('isLocked: $isLocked, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    roomId,
    roomName,
    isLocked,
    unreadCount,
    lastAccessedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomSessionEntry &&
          other.roomId == this.roomId &&
          other.roomName == this.roomName &&
          other.isLocked == this.isLocked &&
          other.unreadCount == this.unreadCount &&
          other.lastAccessedAt == this.lastAccessedAt &&
          other.createdAt == this.createdAt);
}

class RoomSessionsCompanion extends UpdateCompanion<RoomSessionEntry> {
  final Value<String> roomId;
  final Value<String> roomName;
  final Value<bool> isLocked;
  final Value<int> unreadCount;
  final Value<int> lastAccessedAt;
  final Value<int> createdAt;
  final Value<int> rowid;
  const RoomSessionsCompanion({
    this.roomId = const Value.absent(),
    this.roomName = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomSessionsCompanion.insert({
    required String roomId,
    required String roomName,
    this.isLocked = const Value.absent(),
    this.unreadCount = const Value.absent(),
    required int lastAccessedAt,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : roomId = Value(roomId),
       roomName = Value(roomName),
       lastAccessedAt = Value(lastAccessedAt),
       createdAt = Value(createdAt);
  static Insertable<RoomSessionEntry> custom({
    Expression<String>? roomId,
    Expression<String>? roomName,
    Expression<bool>? isLocked,
    Expression<int>? unreadCount,
    Expression<int>? lastAccessedAt,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (roomId != null) 'room_id': roomId,
      if (roomName != null) 'room_name': roomName,
      if (isLocked != null) 'is_locked': isLocked,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomSessionsCompanion copyWith({
    Value<String>? roomId,
    Value<String>? roomName,
    Value<bool>? isLocked,
    Value<int>? unreadCount,
    Value<int>? lastAccessedAt,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return RoomSessionsCompanion(
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      isLocked: isLocked ?? this.isLocked,
      unreadCount: unreadCount ?? this.unreadCount,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (roomName.present) {
      map['room_name'] = Variable<String>(roomName.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<int>(lastAccessedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomSessionsCompanion(')
          ..write('roomId: $roomId, ')
          ..write('roomName: $roomName, ')
          ..write('isLocked: $isLocked, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderNicknameMeta = const VerificationMeta(
    'senderNickname',
  );
  @override
  late final GeneratedColumn<String> senderNickname = GeneratedColumn<String>(
    'sender_nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderColorHexMeta = const VerificationMeta(
    'senderColorHex',
  );
  @override
  late final GeneratedColumn<String> senderColorHex = GeneratedColumn<String>(
    'sender_color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMessageMeta = const VerificationMeta(
    'isSystemMessage',
  );
  @override
  late final GeneratedColumn<bool> isSystemMessage = GeneratedColumn<bool>(
    'is_system_message',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system_message" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roomId,
    senderId,
    senderNickname,
    senderColorHex,
    content,
    timestamp,
    isSystemMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('sender_nickname')) {
      context.handle(
        _senderNicknameMeta,
        senderNickname.isAcceptableOrUnknown(
          data['sender_nickname']!,
          _senderNicknameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_senderNicknameMeta);
    }
    if (data.containsKey('sender_color_hex')) {
      context.handle(
        _senderColorHexMeta,
        senderColorHex.isAcceptableOrUnknown(
          data['sender_color_hex']!,
          _senderColorHexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_senderColorHexMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('is_system_message')) {
      context.handle(
        _isSystemMessageMeta,
        isSystemMessage.isAcceptableOrUnknown(
          data['is_system_message']!,
          _isSystemMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, roomId};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      senderNickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_nickname'],
      )!,
      senderColorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_color_hex'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
      isSystemMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system_message'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String roomId;
  final String senderId;
  final String senderNickname;
  final String senderColorHex;
  final String content;
  final int timestamp;
  final bool isSystemMessage;
  const Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderNickname,
    required this.senderColorHex,
    required this.content,
    required this.timestamp,
    required this.isSystemMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['room_id'] = Variable<String>(roomId);
    map['sender_id'] = Variable<String>(senderId);
    map['sender_nickname'] = Variable<String>(senderNickname);
    map['sender_color_hex'] = Variable<String>(senderColorHex);
    map['content'] = Variable<String>(content);
    map['timestamp'] = Variable<int>(timestamp);
    map['is_system_message'] = Variable<bool>(isSystemMessage);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      roomId: Value(roomId),
      senderId: Value(senderId),
      senderNickname: Value(senderNickname),
      senderColorHex: Value(senderColorHex),
      content: Value(content),
      timestamp: Value(timestamp),
      isSystemMessage: Value(isSystemMessage),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      roomId: serializer.fromJson<String>(json['roomId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      senderNickname: serializer.fromJson<String>(json['senderNickname']),
      senderColorHex: serializer.fromJson<String>(json['senderColorHex']),
      content: serializer.fromJson<String>(json['content']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      isSystemMessage: serializer.fromJson<bool>(json['isSystemMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'roomId': serializer.toJson<String>(roomId),
      'senderId': serializer.toJson<String>(senderId),
      'senderNickname': serializer.toJson<String>(senderNickname),
      'senderColorHex': serializer.toJson<String>(senderColorHex),
      'content': serializer.toJson<String>(content),
      'timestamp': serializer.toJson<int>(timestamp),
      'isSystemMessage': serializer.toJson<bool>(isSystemMessage),
    };
  }

  Message copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? senderNickname,
    String? senderColorHex,
    String? content,
    int? timestamp,
    bool? isSystemMessage,
  }) => Message(
    id: id ?? this.id,
    roomId: roomId ?? this.roomId,
    senderId: senderId ?? this.senderId,
    senderNickname: senderNickname ?? this.senderNickname,
    senderColorHex: senderColorHex ?? this.senderColorHex,
    content: content ?? this.content,
    timestamp: timestamp ?? this.timestamp,
    isSystemMessage: isSystemMessage ?? this.isSystemMessage,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      senderNickname: data.senderNickname.present
          ? data.senderNickname.value
          : this.senderNickname,
      senderColorHex: data.senderColorHex.present
          ? data.senderColorHex.value
          : this.senderColorHex,
      content: data.content.present ? data.content.value : this.content,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isSystemMessage: data.isSystemMessage.present
          ? data.isSystemMessage.value
          : this.isSystemMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('senderId: $senderId, ')
          ..write('senderNickname: $senderNickname, ')
          ..write('senderColorHex: $senderColorHex, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('isSystemMessage: $isSystemMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    roomId,
    senderId,
    senderNickname,
    senderColorHex,
    content,
    timestamp,
    isSystemMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.roomId == this.roomId &&
          other.senderId == this.senderId &&
          other.senderNickname == this.senderNickname &&
          other.senderColorHex == this.senderColorHex &&
          other.content == this.content &&
          other.timestamp == this.timestamp &&
          other.isSystemMessage == this.isSystemMessage);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> roomId;
  final Value<String> senderId;
  final Value<String> senderNickname;
  final Value<String> senderColorHex;
  final Value<String> content;
  final Value<int> timestamp;
  final Value<bool> isSystemMessage;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.senderNickname = const Value.absent(),
    this.senderColorHex = const Value.absent(),
    this.content = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isSystemMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String roomId,
    required String senderId,
    required String senderNickname,
    required String senderColorHex,
    required String content,
    required int timestamp,
    this.isSystemMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       roomId = Value(roomId),
       senderId = Value(senderId),
       senderNickname = Value(senderNickname),
       senderColorHex = Value(senderColorHex),
       content = Value(content),
       timestamp = Value(timestamp);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? roomId,
    Expression<String>? senderId,
    Expression<String>? senderNickname,
    Expression<String>? senderColorHex,
    Expression<String>? content,
    Expression<int>? timestamp,
    Expression<bool>? isSystemMessage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (senderId != null) 'sender_id': senderId,
      if (senderNickname != null) 'sender_nickname': senderNickname,
      if (senderColorHex != null) 'sender_color_hex': senderColorHex,
      if (content != null) 'content': content,
      if (timestamp != null) 'timestamp': timestamp,
      if (isSystemMessage != null) 'is_system_message': isSystemMessage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? roomId,
    Value<String>? senderId,
    Value<String>? senderNickname,
    Value<String>? senderColorHex,
    Value<String>? content,
    Value<int>? timestamp,
    Value<bool>? isSystemMessage,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderNickname: senderNickname ?? this.senderNickname,
      senderColorHex: senderColorHex ?? this.senderColorHex,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (senderNickname.present) {
      map['sender_nickname'] = Variable<String>(senderNickname.value);
    }
    if (senderColorHex.present) {
      map['sender_color_hex'] = Variable<String>(senderColorHex.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (isSystemMessage.present) {
      map['is_system_message'] = Variable<bool>(isSystemMessage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('senderId: $senderId, ')
          ..write('senderNickname: $senderNickname, ')
          ..write('senderColorHex: $senderColorHex, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('isSystemMessage: $isSystemMessage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RoomSessionsTable roomSessions = $RoomSessionsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [roomSessions, messages];
}

typedef $$RoomSessionsTableCreateCompanionBuilder =
    RoomSessionsCompanion Function({
      required String roomId,
      required String roomName,
      Value<bool> isLocked,
      Value<int> unreadCount,
      required int lastAccessedAt,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$RoomSessionsTableUpdateCompanionBuilder =
    RoomSessionsCompanion Function({
      Value<String> roomId,
      Value<String> roomName,
      Value<bool> isLocked,
      Value<int> unreadCount,
      Value<int> lastAccessedAt,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$RoomSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $RoomSessionsTable> {
  $$RoomSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomName => $composableBuilder(
    column: $table.roomName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoomSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomSessionsTable> {
  $$RoomSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomName => $composableBuilder(
    column: $table.roomName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoomSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomSessionsTable> {
  $$RoomSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get roomName =>
      $composableBuilder(column: $table.roomName, builder: (column) => column);

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RoomSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoomSessionsTable,
          RoomSessionEntry,
          $$RoomSessionsTableFilterComposer,
          $$RoomSessionsTableOrderingComposer,
          $$RoomSessionsTableAnnotationComposer,
          $$RoomSessionsTableCreateCompanionBuilder,
          $$RoomSessionsTableUpdateCompanionBuilder,
          (
            RoomSessionEntry,
            BaseReferences<_$AppDatabase, $RoomSessionsTable, RoomSessionEntry>,
          ),
          RoomSessionEntry,
          PrefetchHooks Function()
        > {
  $$RoomSessionsTableTableManager(_$AppDatabase db, $RoomSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> roomId = const Value.absent(),
                Value<String> roomName = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<int> lastAccessedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomSessionsCompanion(
                roomId: roomId,
                roomName: roomName,
                isLocked: isLocked,
                unreadCount: unreadCount,
                lastAccessedAt: lastAccessedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String roomId,
                required String roomName,
                Value<bool> isLocked = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                required int lastAccessedAt,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RoomSessionsCompanion.insert(
                roomId: roomId,
                roomName: roomName,
                isLocked: isLocked,
                unreadCount: unreadCount,
                lastAccessedAt: lastAccessedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoomSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoomSessionsTable,
      RoomSessionEntry,
      $$RoomSessionsTableFilterComposer,
      $$RoomSessionsTableOrderingComposer,
      $$RoomSessionsTableAnnotationComposer,
      $$RoomSessionsTableCreateCompanionBuilder,
      $$RoomSessionsTableUpdateCompanionBuilder,
      (
        RoomSessionEntry,
        BaseReferences<_$AppDatabase, $RoomSessionsTable, RoomSessionEntry>,
      ),
      RoomSessionEntry,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required String id,
      required String roomId,
      required String senderId,
      required String senderNickname,
      required String senderColorHex,
      required String content,
      required int timestamp,
      Value<bool> isSystemMessage,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<String> roomId,
      Value<String> senderId,
      Value<String> senderNickname,
      Value<String> senderColorHex,
      Value<String> content,
      Value<int> timestamp,
      Value<bool> isSystemMessage,
      Value<int> rowid,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderNickname => $composableBuilder(
    column: $table.senderNickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderColorHex => $composableBuilder(
    column: $table.senderColorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystemMessage => $composableBuilder(
    column: $table.isSystemMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderNickname => $composableBuilder(
    column: $table.senderNickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderColorHex => $composableBuilder(
    column: $table.senderColorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystemMessage => $composableBuilder(
    column: $table.isSystemMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get senderNickname => $composableBuilder(
    column: $table.senderNickname,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderColorHex => $composableBuilder(
    column: $table.senderColorHex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get isSystemMessage => $composableBuilder(
    column: $table.isSystemMessage,
    builder: (column) => column,
  );
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
          Message,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> senderNickname = const Value.absent(),
                Value<String> senderColorHex = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<bool> isSystemMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                roomId: roomId,
                senderId: senderId,
                senderNickname: senderNickname,
                senderColorHex: senderColorHex,
                content: content,
                timestamp: timestamp,
                isSystemMessage: isSystemMessage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String roomId,
                required String senderId,
                required String senderNickname,
                required String senderColorHex,
                required String content,
                required int timestamp,
                Value<bool> isSystemMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                roomId: roomId,
                senderId: senderId,
                senderNickname: senderNickname,
                senderColorHex: senderColorHex,
                content: content,
                timestamp: timestamp,
                isSystemMessage: isSystemMessage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
      Message,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RoomSessionsTableTableManager get roomSessions =>
      $$RoomSessionsTableTableManager(_db, _db.roomSessions);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
}
