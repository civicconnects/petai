class Pet {
  final String id;
  final String name;
  final String breed;
  final int age;
  final String idNumber; // Auto-generated ID, e.g., "K9-1234"
  final double weight; // in lbs
  final String sex; // 'Male', 'Female'
  final String color;
  final List<String> chronicConditions;
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
