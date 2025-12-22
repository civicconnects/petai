import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/file_storage_service.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? initialImagePath;
  final Function(String) onImageSelected;
  final double radius;

  const ProfileImagePicker({
    super.key,
    this.initialImagePath,
    required this.onImageSelected,
    this.radius = 60,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  String? _imagePath;
  final FileStorageService _fileService = FileStorageService();

  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImagePath;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedPath = await _fileService.pickImage(source);
    if (pickedPath != null) {
      setState(() {
        _imagePath = pickedPath;
      });
      widget.onImageSelected(pickedPath);
    }
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPickerOptions(context),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: Colors.grey[200],
            backgroundImage: _imagePath != null
                ? FileImage(File(_imagePath!))
                : null,
            child: _imagePath == null
                ? Icon(Icons.person, size: widget.radius, color: Colors.grey)
                : null,
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF4A90E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
