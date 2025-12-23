import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../dashboard/models/pet.dart';
import 'package:uuid/uuid.dart';
import '../../../core/widgets/profile_image_picker.dart';
import '../../../core/services/storage_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';

class AddPetScreen extends ConsumerStatefulWidget {
  final Pet? petToEdit;
  const AddPetScreen({super.key, this.petToEdit});

  @override
  ConsumerState<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends ConsumerState<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();
  String _selectedSex = 'Male';
  
  // final _fileService = FileStorageService(); // Removed in favor of ProfileImagePicker
  String? _selectedImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.petToEdit != null) {
      final pet = widget.petToEdit!;
      _nameController.text = pet.name;
      _breedController.text = pet.breed;
      _ageController.text = pet.age.toString();
      _weightController.text = pet.weight.toString();
      _colorController.text = pet.color;
      _selectedSex = pet.sex;
      _selectedImagePath = pet.imagePath;
    }
  }

  // _pickImage removed, handled by widget

  void _savePet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final newPet = Pet(
        id: widget.petToEdit?.id ?? const Uuid().v4(),
        idNumber: widget.petToEdit?.idNumber ?? 'K9-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        name: _nameController.text,
        breed: _breedController.text,
        age: int.tryParse(_ageController.text) ?? 0,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        sex: _selectedSex,
        color: _colorController.text,
        imagePath: _selectedImagePath,
        chronicConditions: widget.petToEdit?.chronicConditions ?? [],
      );

      // Save to Hive
      await ref.read(storageServiceProvider).savePet(newPet);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context, newPet);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.petToEdit != null ? 'Edit Medical Record' : 'Add a New Pet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ProfileImagePicker(
                  initialImagePath: _selectedImagePath,
                  onImageSelected: (path) {
                    setState(() {
                      _selectedImagePath = path;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Breed',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a breed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age (yrs)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                         if (value == null || value.isEmpty) return 'Required';
                         return null;
                      },
                    ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                    child: TextFormField(
                      controller: _weightController, // Need to define this
                      decoration: const InputDecoration(
                        labelText: 'Weight (lbs)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monitor_weight),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                         if (value == null || value.isEmpty) return 'Required';
                         return null;
                      },
                    ),
                   ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSex,
                decoration: const InputDecoration(
                  labelText: 'Sex',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.transgender),
                ),
                items: ['Male', 'Female'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedSex = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color/Markings',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.palette),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isLoading ? null : _savePet,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
