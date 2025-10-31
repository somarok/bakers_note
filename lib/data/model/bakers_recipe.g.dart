// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bakers_recipe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BakersRecipeAdapter extends TypeAdapter<BakersRecipe> {
  @override
  final int typeId = 1;

  @override
  BakersRecipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BakersRecipe(
      name: fields[0] as String?,
      ingredients: (fields[1] as List).cast<Ingredient>(),
      createdAt: fields[2] as DateTime,
      imagePath: fields[3] as String?,
      description: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BakersRecipe obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.ingredients)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BakersRecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
