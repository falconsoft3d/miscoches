import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_service.dart';

class ImageGalleryWidget extends StatefulWidget {
  final List<String> images;
  final String? favoriteImage;
  final Function(List<String> images, String? favoriteImage) onImagesChanged;

  const ImageGalleryWidget({
    super.key,
    required this.images,
    this.favoriteImage,
    required this.onImagesChanged,
  });

  @override
  State<ImageGalleryWidget> createState() => _ImageGalleryWidgetState();
}

class _ImageGalleryWidgetState extends State<ImageGalleryWidget> {
  final ImageService _imageService = ImageService();
  late List<String> _images;
  late String? _favoriteImage;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.images);
    _favoriteImage = widget.favoriteImage;
    // Limpiar imágenes que no existen
    _limpiarImagenesInvalidas();
  }

  Future<void> _limpiarImagenesInvalidas() async {
    bool cambios = false;
    final imagenesValidas = <String>[];

    for (final imagePath in _images) {
      final file = File(imagePath);
      if (await file.exists()) {
        imagenesValidas.add(imagePath);
      } else {
        cambios = true;
      }
    }

    if (cambios) {
      setState(() {
        _images = imagenesValidas;
        // Si la imagen favorita ya no existe, seleccionar otra
        if (_favoriteImage != null && !_images.contains(_favoriteImage)) {
          _favoriteImage = _images.isNotEmpty ? _images.first : null;
        }
      });
      widget.onImagesChanged(_images, _favoriteImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Galería de fotos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                if (_images.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    onPressed: _limpiarGaleria,
                    tooltip: 'Limpiar galería',
                    color: Colors.red,
                  ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _tomarFoto,
                  tooltip: 'Tomar foto',
                ),
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: _seleccionarImagenes,
                  tooltip: 'Seleccionar de galería',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_images.isEmpty)
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No hay fotos',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final imagePath = _images[index];
                final isFavorite = imagePath == _favoriteImage;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _verImagenCompleta(imagePath),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(imagePath),
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 150,
                                height: 150,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        // Indicador de favorito
                        if (isFavorite)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        // Botones de acción
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            children: [
                              if (!isFavorite)
                                GestureDetector(
                                  onTap: () => _marcarComoFavorita(imagePath),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.star_border,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _eliminarImagen(imagePath),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _tomarFoto() async {
    final imagePath = await _imageService.takePhoto();
    if (imagePath != null) {
      setState(() {
        _images.add(imagePath);
        // Si es la primera imagen, marcarla como favorita
        if (_images.length == 1) {
          _favoriteImage = imagePath;
        }
      });
      widget.onImagesChanged(_images, _favoriteImage);
    }
  }

  Future<void> _seleccionarImagenes() async {
    final imagePaths = await _imageService.pickMultipleImages();
    if (imagePaths.isNotEmpty) {
      setState(() {
        _images.addAll(imagePaths);
        // Si es la primera imagen, marcar la primera como favorita
        if (_favoriteImage == null && _images.isNotEmpty) {
          _favoriteImage = _images.first;
        }
      });
      widget.onImagesChanged(_images, _favoriteImage);
    }
  }

  void _marcarComoFavorita(String imagePath) {
    setState(() {
      _favoriteImage = imagePath;
    });
    widget.onImagesChanged(_images, _favoriteImage);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marcada como favorita'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _eliminarImagen(String imagePath) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar imagen'),
        content: const Text('¿Estás seguro de que deseas eliminar esta imagen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _imageService.deleteImage(imagePath);
      setState(() {
        _images.remove(imagePath);
        // Si la imagen eliminada era la favorita, seleccionar otra
        if (_favoriteImage == imagePath) {
          _favoriteImage = _images.isNotEmpty ? _images.first : null;
        }
      });
      widget.onImagesChanged(_images, _favoriteImage);
    }
  }

  Future<void> _limpiarGaleria() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar galería'),
        content: Text(
          '¿Estás seguro de que deseas eliminar todas las ${_images.length} fotos de la galería?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar todas'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Eliminar todas las imágenes del almacenamiento
      for (final imagePath in _images) {
        await _imageService.deleteImage(imagePath);
      }
      
      setState(() {
        _images.clear();
        _favoriteImage = null;
      });
      
      widget.onImagesChanged(_images, _favoriteImage);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Galería limpiada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _verImagenCompleta(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(File(imagePath)),
            ),
          ),
        ),
      ),
    );
  }
}
