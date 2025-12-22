class Pet {
  final String id;
  final String name;
  final String breed;
  final int age;
  final String color;
  final String imageUrl; // For future use, e.g., if we add image picking

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.color,
    this.imageUrl = '',
  });
}
