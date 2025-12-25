import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/coche_deseado.dart';
import '../services/coche_deseado_service.dart';

class CocheDeseadoFormScreen extends StatefulWidget {
  final CocheDeseado? coche;

  const CocheDeseadoFormScreen({super.key, this.coche});

  @override
  State<CocheDeseadoFormScreen> createState() => _CocheDeseadoFormScreenState();
}

class _CocheDeseadoFormScreenState extends State<CocheDeseadoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final CocheDeseadoService _cocheService = CocheDeseadoService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _anioController;
  late TextEditingController _dondeLoViController;
  late TextEditingController _notasController;

  List<String> _imagenes = [];
  String? _imagenFavorita;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _marcaController = TextEditingController(text: widget.coche?.marca ?? '');
    _modeloController = TextEditingController(text: widget.coche?.modelo ?? '');
    _anioController = TextEditingController(
        text: widget.coche?.anio?.toString() ?? '');
    _dondeLoViController =
        TextEditingController(text: widget.coche?.dondeLoVi ?? '');
    _notasController = TextEditingController(text: widget.coche?.notas ?? '');
    _imagenes = List.from(widget.coche?.imagenes ?? []);
    _imagenFavorita = widget.coche?.imagenFavorita;
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _dondeLoViController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _agregarImagen(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName =
            'coche_deseado_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String newPath = '${appDir.path}/$fileName';

        await File(image.path).copy(newPath);

        setState(() {
          _imagenes.add(newPath);
          if (_imagenFavorita == null) {
            _imagenFavorita = newPath;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _agregarImagen(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _agregarImagen(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _guardarCoche() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final coche = CocheDeseado(
        id: widget.coche?.id,
        marca: _marcaController.text.trim(),
        modelo: _modeloController.text.trim(),
        anio: _anioController.text.isEmpty
            ? null
            : int.tryParse(_anioController.text),
        imagenes: _imagenes,
        imagenFavorita: _imagenFavorita,
        dondeLoVi: _dondeLoViController.text.trim().isEmpty
            ? null
            : _dondeLoViController.text.trim(),
        notas: _notasController.text.trim().isEmpty
            ? null
            : _notasController.text.trim(),
        fechaCreacion: widget.coche?.fechaCreacion ?? DateTime.now(),
      );

      if (widget.coche == null) {
        await _cocheService.crearCocheDeseado(coche);
      } else {
        await _cocheService.actualizarCocheDeseado(widget.coche!.id!, coche);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coche == null
            ? 'Agregar Coche Deseado'
            : 'Editar Coche Deseado'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _guardarCoche,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Galería de imágenes
            if (_imagenes.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagenes.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _imagenes.length) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: _mostrarOpcionesImagen,
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate,
                                    size: 50, color: Colors.grey[600]),
                                const SizedBox(height: 8),
                                Text(
                                  'Agregar',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final imagePath = _imagenes[index];
                    final isFavorite = imagePath == _imagenFavorita;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(imagePath),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (isFavorite)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.star,
                                    color: Colors.white, size: 24),
                              ),
                            ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Row(
                              children: [
                                if (!isFavorite)
                                  IconButton(
                                    icon: const Icon(Icons.star_border,
                                        color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _imagenFavorita = imagePath;
                                      });
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _imagenes.remove(imagePath);
                                      if (_imagenFavorita == imagePath) {
                                        _imagenFavorita =
                                            _imagenes.isNotEmpty ? _imagenes[0] : null;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (_imagenes.isEmpty)
              GestureDetector(
                onTap: _mostrarOpcionesImagen,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate,
                          size: 60, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text(
                        'Toca para agregar fotos',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _marcaController,
              decoration: const InputDecoration(
                labelText: 'Marca',
                hintText: 'Ej: BMW',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La marca es obligatoria';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _modeloController,
              decoration: const InputDecoration(
                labelText: 'Modelo',
                hintText: 'Ej: M3',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.car_rental),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El modelo es obligatorio';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _anioController,
              decoration: const InputDecoration(
                labelText: 'Año (opcional)',
                hintText: 'Ej: 2024',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dondeLoViController,
              decoration: const InputDecoration(
                labelText: 'Dónde lo vi (opcional)',
                hintText: 'Ej: Concesionario BMW Madrid',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              textCapitalization: TextCapitalization.sentences,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notasController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Información adicional...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _guardarCoche,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(widget.coche == null ? 'Guardar' : 'Actualizar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
