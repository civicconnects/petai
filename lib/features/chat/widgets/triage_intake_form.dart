import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TriageIntakeForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const TriageIntakeForm({super.key, required this.onSubmit});

  @override
  State<TriageIntakeForm> createState() => _TriageIntakeFormState();
}

class _TriageIntakeFormState extends State<TriageIntakeForm> {
  String _selectedSpecies = 'Dog';
  String? _selectedBreed;
  String? _selectedSymptom;
  String _duration = '< 1 hour';

  // Mock Data
  final List<String> _dogBreeds = ['Golden Retriever', 'German Shepherd', 'Labrador', 'Bulldog', 'Poodle', 'Mixed'];
  final List<String> _catBreeds = ['Siamese', 'Persian', 'Maine Coon', 'Ragdoll', 'Mixed'];
  
  final List<String> _commonSymptoms = [
    'Vomiting', 'Diarrhea', 'Limping', 'Coughing', 'Scratching', 
    'Not Eating', 'Lethargy', 'Sneezing', 'Bleeding', 'Seizure'
  ];

  final List<String> _durations = ['< 1 hour', '1 - 12 hours', '24 hours', '> 2 days', '> 1 week'];

  @override
  Widget build(BuildContext context) {
    final breeds = _selectedSpecies == 'Dog' ? _dogBreeds : _catBreeds;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New Triage Case',
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF4A90E2)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Help us understand the situation faster.',
            style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Species Toggle
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Dog', label: Text('Dog'), icon: Icon(Icons.pets)),
              ButtonSegment(value: 'Cat', label: Text('Cat'), icon: Icon(Icons.cruelty_free)),
            ],
            selected: {_selectedSpecies},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedSpecies = newSelection.first;
                _selectedBreed = null; // Reset breed on species change
              });
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.selected)) {
                  return const Color(0xFF4A90E2).withOpacity(0.2);
                }
                return null;
              }),
            ),
          ),
          const SizedBox(height: 24),

          // Breed Dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Breed',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
            ),
            value: _selectedBreed,
            items: breeds.map((breed) => DropdownMenuItem(value: breed, child: Text(breed))).toList(),
            onChanged: (val) => setState(() => _selectedBreed = val),
          ),
          const SizedBox(height: 16),

          // Symptom Autocomplete (using Dropdown for MVP simplicity, or Autocomplete)
          // Using Dropdown for now as per plan Step 1
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Primary Symptom',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.medical_services),
            ),
            value: _selectedSymptom,
            items: _commonSymptoms.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) => setState(() => _selectedSymptom = val),
          ),
          const SizedBox(height: 16),

          // Duration Dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Duration',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.timer),
            ),
            value: _duration,
            items: _durations.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (val) => setState(() => _duration = val!),
          ),

          const SizedBox(height: 32),
          
          FilledButton(
            onPressed: (_selectedBreed != null && _selectedSymptom != null) 
              ? () {
                  widget.onSubmit({
                    'species': _selectedSpecies,
                    'breed': _selectedBreed,
                    'symptom': _selectedSymptom,
                    'duration': _duration,
                  });
                } 
              : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF4A90E2),
            ),
            child: const Text('Start Triage Analysis', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
