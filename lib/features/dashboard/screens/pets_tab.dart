import 'package:flutter/material.dart';
import '../../dashboard/models/pet.dart';
import 'add_pet_screen.dart';

class PetsTab extends StatefulWidget {
  const PetsTab({super.key});

  @override
  State<PetsTab> createState() => _PetsTabState();
}

class _PetsTabState extends State<PetsTab> {
  // Mock data initially
  final List<Pet> _pets = [
    Pet(
      id: '1',
      name: 'Buddy',
      breed: 'Golden Retriever',
      age: 2,
      color: 'Golden',
    ),
    Pet(
      id: '2',
      name: 'Max',
      breed: 'German Shepherd',
      age: 3,
      color: 'Black & Tan',
    ),
  ];

  void _addPet() async {
    final newPet = await Navigator.push<Pet>(
      context,
      MaterialPageRoute(builder: (context) => const AddPetScreen()),
    );

    if (newPet != null) {
      setState(() {
        _pets.add(newPet);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No pets yet!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Add your furry friend to get started.'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pets.length,
              itemBuilder: (context, index) {
                final pet = _pets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pets, color: Colors.deepPurple),
                    ),
                    title: Text(
                      pet.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${pet.breed} • ${pet.age} years old'),
                        Text(
                          pet.color,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Navigate to pet details
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPet,
        icon: const Icon(Icons.add),
        label: const Text('Add Pet'),
        tooltip: 'Add a new pet',
      ),
    );
  }
}
