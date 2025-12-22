import 'package:image_picker/image_picker.dart';

class FileStorageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      
      return image?.path;
    } catch (e) {
      // Handle permission errors or cancellation
      return null;
    }
  }
}
