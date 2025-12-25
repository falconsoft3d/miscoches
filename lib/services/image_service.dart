import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Seleccionar imagen de la galería
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return await _saveImagePermanently(image);
      }
      return null;
    } catch (e) {
      print('Error seleccionando imagen: $e');
      return null;
    }
  }

  // Tomar foto con la cámara
  Future<String?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return await _saveImagePermanently(image);
      }
      return null;
    } catch (e) {
      print('Error tomando foto: $e');
      return null;
    }
  }

  // Seleccionar múltiples imágenes
  Future<List<String>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      List<String> savedPaths = [];
      for (var image in images) {
        final savedPath = await _saveImagePermanently(image);
        if (savedPath != null) {
          savedPaths.add(savedPath);
        }
      }
      return savedPaths;
    } catch (e) {
      print('Error seleccionando múltiples imágenes: $e');
      return [];
    }
  }

  // Guardar imagen permanentemente en el directorio de la app
  Future<String?> _saveImagePermanently(XFile image) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imageDir = path.join(appDir.path, 'coches_images');
      
      // Crear directorio si no existe
      final Directory dir = Directory(imageDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      // Generar nombre único para la imagen
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final String filePath = path.join(imageDir, fileName);
      
      // Copiar archivo
      final File imageFile = File(image.path);
      await imageFile.copy(filePath);
      
      return filePath;
    } catch (e) {
      print('Error guardando imagen: $e');
      return null;
    }
  }

  // Eliminar imagen del almacenamiento
  Future<bool> deleteImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error eliminando imagen: $e');
      return false;
    }
  }

  // Eliminar múltiples imágenes
  Future<void> deleteImages(List<String> imagePaths) async {
    for (var imagePath in imagePaths) {
      await deleteImage(imagePath);
    }
  }
}
