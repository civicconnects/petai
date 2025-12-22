import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../models/pet.dart';
import 'add_pet_screen.dart';

class PetChartScreen extends StatefulWidget {
  final Pet pet;

  const PetChartScreen({super.key, required this.pet});

  @override
  State<PetChartScreen> createState() => _PetChartScreenState();
}

class _PetChartScreenState extends State<PetChartScreen> {
  late Pet _pet;

  @override
  void initState() {
     super.initState();
     _pet = widget.pet;
  }

  void _editRecord() async {
    final updatedPet = await Navigator.push<Pet>(
      context,
      MaterialPageRoute(
        builder: (context) => AddPetScreen(petToEdit: _pet),
      ),
    );

    if (updatedPet != null) {
      setState(() {
        _pet = updatedPet;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Medical Record', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, _pet), // Return updated pet
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildVitalsGrid(),
            const SizedBox(height: 24),
            _buildProblemList(),
             const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueGrey[50], 
              border: Border.all(color: Colors.blueGrey.shade100, width: 2),
              image: _pet.imagePath != null
                  ? DecorationImage(
                      image: FileImage(File(_pet.imagePath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _pet.imagePath == null
                ? Icon(Icons.pets, size: 40, color: Colors.blueGrey[300])
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pet.name,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                Text(
                  'ID: ${_pet.idNumber}',
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 14,
                    color: Colors.blueGrey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VITALS',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildVitalItem(Icons.monitor_weight, 'Weight', '${_pet.weight} lbs'),
                _buildVitalItem(Icons.cake, 'Age', '${_pet.age} yrs'),
                _buildVitalItem(Icons.category, 'Breed', _pet.breed), // Might truncate
                _buildVitalItem(Icons.transgender, 'Sex', _pet.sex),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4A90E2)), // Scrub Blue
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14, 
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[800],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProblemList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'PROBLEM LIST / CHRONIC CONDITIONS',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: _pet.chronicConditions.isEmpty
                ? Text('No known chronic conditions.', style: GoogleFonts.inter(color: Colors.grey[400]))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _pet.chronicConditions.map((condition) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orangeAccent),
                          const SizedBox(width: 8),
                          Text(condition, style: GoogleFonts.inter(fontSize: 14, color: Colors.blueGrey[700])),
                        ],
                      ),
                    )).toList(),
                  ),
          ),
        ],
      ),
    );
  }
  
    Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row( // Using Row for potential multiple buttons
        children: [
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: _editRecord,
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Record"),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.blueGrey,
                        side: BorderSide(color: Colors.blueGrey.shade200),
                    )
                )
            )
        ],
      ),
    );
  }
}
