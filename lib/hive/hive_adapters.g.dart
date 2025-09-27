// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class HistoryAdapter extends TypeAdapter<History> {
  @override
  final typeId = 1;

  @override
  History read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return History(
      uniqueKey: fields[1] as String,
      duration: (fields[2] as num).toInt(),
      position: (fields[3] as num).toInt(),
      url: fields[4] as String?,
      type: fields[6] as HistoriesType,
      storageKey: fields[10] as String?,
      updateTime: (fields[8] as num).toInt(),
      name: fields[11] as String,
      subtitle: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, History obj) {
    writer
      ..writeByte(9)
      ..writeByte(1)
      ..write(obj.uniqueKey)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.position)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.updateTime)
      ..writeByte(10)
      ..write(obj.storageKey)
      ..writeByte(11)
      ..write(obj.name)
      ..writeByte(12)
      ..write(obj.subtitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HistoriesTypeAdapter extends TypeAdapter<HistoriesType> {
  @override
  final typeId = 3;

  @override
  HistoriesType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 1:
        return HistoriesType.local;
      case 3:
        return HistoriesType.network;
      case 5:
        return HistoriesType.fileStorage;
      case 6:
        return HistoriesType.streamMediaStorage;
      default:
        return HistoriesType.local;
    }
  }

  @override
  void write(BinaryWriter writer, HistoriesType obj) {
    switch (obj) {
      case HistoriesType.local:
        writer.writeByte(1);
      case HistoriesType.network:
        writer.writeByte(3);
      case HistoriesType.fileStorage:
        writer.writeByte(5);
      case HistoriesType.streamMediaStorage:
        writer.writeByte(6);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoriesTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StorageAdapter extends TypeAdapter<Storage> {
  @override
  final typeId = 4;

  @override
  Storage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Storage(
      name: fields[0] as String,
      uniqueKey: fields[8] as String,
      url: fields[1] as String,
      port: (fields[2] as num?)?.toInt(),
      storageType: fields[4] as StorageType,
      account: fields[5] as String?,
      password: fields[6] as String?,
      isAnonymous: fields[7] as bool?,
      mediaLibraryId: fields[9] as String?,
      token: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Storage obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.port)
      ..writeByte(4)
      ..write(obj.storageType)
      ..writeByte(5)
      ..write(obj.account)
      ..writeByte(6)
      ..write(obj.password)
      ..writeByte(7)
      ..write(obj.isAnonymous)
      ..writeByte(8)
      ..write(obj.uniqueKey)
      ..writeByte(9)
      ..write(obj.mediaLibraryId)
      ..writeByte(10)
      ..write(obj.token);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StorageTypeAdapter extends TypeAdapter<StorageType> {
  @override
  final typeId = 5;

  @override
  StorageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StorageType.webdav;
      case 1:
        return StorageType.ftp;
      case 2:
        return StorageType.smb;
      case 3:
        return StorageType.local;
      case 4:
        return StorageType.jellyfin;
      default:
        return StorageType.webdav;
    }
  }

  @override
  void write(BinaryWriter writer, StorageType obj) {
    switch (obj) {
      case StorageType.webdav:
        writer.writeByte(0);
      case StorageType.ftp:
        writer.writeByte(1);
      case StorageType.smb:
        writer.writeByte(2);
      case StorageType.local:
        writer.writeByte(3);
      case StorageType.jellyfin:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
