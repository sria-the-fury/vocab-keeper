// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'VocabularyModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VocabularyModelAdapter extends TypeAdapter<VocabularyModel> {
  @override
  final int typeId = 0;

  @override
  VocabularyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VocabularyModel()
      ..word = fields[0] as String
      ..englishMeaning = fields[1] as String
      ..nativeMeaning = fields[2] as String
      ..sentences = fields[3] as String
      ..createdAt = fields[4] as DateTime
      ..id = fields[5] as String
      ..dayMonthYear = fields[6] as String;
  }

  @override
  void write(BinaryWriter writer, VocabularyModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.word)
      ..writeByte(1)
      ..write(obj.englishMeaning)
      ..writeByte(2)
      ..write(obj.nativeMeaning)
      ..writeByte(3)
      ..write(obj.sentences)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.id)
      ..writeByte(6)
      ..write(obj.dayMonthYear);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabularyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
