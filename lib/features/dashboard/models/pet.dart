import 'package:hive/hive.dart';

part 'pet.g.dart';

@HiveType(typeId: 0)
class Pet {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String breed;

  @HiveField(3)
  final int age;

  @HiveField(4)
  final String idNumber; // Auto-generated ID, e.g., "K9-1234"

  @HiveField(5)
  final double weight; // in lbs

  @HiveField(6)
  final String sex; // 'Male', 'Female'

  @HiveField(7)
  final String color;

  @HiveField(8)
  final List<String> chronicConditions;

  @HiveField(9)
  final String? imagePath;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.color,
    required this.idNumber,
    required this.weight,
    required this.sex,
    this.chronicConditions = const [],
    this.imagePath,
  });
}
