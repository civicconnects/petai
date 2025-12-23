import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../dashboard/models/pet.dart';
import 'add_pet_screen.dart';
import 'pet_chart_screen.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../main.dart';

class PetsTab extends ConsumerStatefulWidget {
  const PetsTab({super.key});

  @override
  ConsumerState<PetsTab> createState() => _PetsTabState();
}

class _PetsTabState extends ConsumerState<PetsTab> {
  List<Pet> _pets = [];

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  void _loadPets() {
    final storage = ref.read(storageServiceProvider);
    setState(() {
      _pets = storage.getPets();
    });
  }

  void _addPet() async {
    await Navigator.push<Pet>(
      context,
      MaterialPageRoute(builder: (context) => const AddPetScreen()),
    );
    _loadPets(); // Refresh list after returning
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
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        shape: BoxShape.circle,
                        image: pet.imagePath != null
                            ? DecorationImage(
                                image: FileImage(File(pet.imagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: pet.imagePath == null
                          ? const Icon(Icons.pets, color: Colors.deepPurple, size: 30)
                          : null,
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetChartScreen(pet: pet),
                        ),
                      );
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
