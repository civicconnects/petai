import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/models/pet.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class StorageService {
  static const String _petBoxName = 'pets';
  late Box<Pet> _petBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PetAdapter());
    _petBox = await Hive.openBox<Pet>(_petBoxName);
  }

  List<Pet> getPets() {
    return _petBox.values.toList();
  }

  Future<void> savePet(Pet pet) async {
    // ID is used as key for O(1) access if needed, or just put.
    // Since ID is in the object, put(key, val) works best.
    await _petBox.put(pet.id, pet);
  }

  Future<void> deletePet(String id) async {
    await _petBox.delete(id);
  }
}
