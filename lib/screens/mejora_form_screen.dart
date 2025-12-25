import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/mejora.dart';
import '../services/mejora_service.dart';

class MejoraFormScreen extends StatefulWidget {
  final int cocheId;
  final Mejora? mejora;

  const MejoraFormScreen({
    Key? key,
    required this.cocheId,
    this.mejora,
  }) : super(key: key);

  @override
  State<MejoraFormScreen> createState() => _MejoraFormScreenState();
}

class _MejoraFormScreenState extends State<MejoraFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mejoraService = MejoraService();
  final _nombreController = TextEditingController();
  final _linkController = TextEditingController();
  final _notasController = TextEditingController();
  
  String? _imagenPath;
  bool _guardando = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.mejora != null) {
      _nombreController.text = widget.mejora!.nombre;
      _linkController.text = widget.mejora!.linkCompra ?? '';
      _notasController.text = widget.mejora!.notas ?? '';
      _imagenPath = widget.mejora!.imagenPath;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _linkController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = 'mejora_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String newPath = '${appDir.path}/$fileName';
        
        await File(image.path).copy(newPath);
        
        setState(() {
          _imagenPath = newPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
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
                  _seleccionarImagen(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagen(ImageSource.gallery);
                },
              ),
              if (_imagenPath != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Eliminar imagen'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _imagenPath = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _guardarMejora() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final mejora = Mejora(
        id: widget.mejora?.id,
        cocheId: widget.cocheId,
        nombre: _nombreController.text.trim(),
        imagenPath: _imagenPath,
        linkCompra: _linkController.text.trim().isEmpty 
            ? null 
            : _linkController.text.trim(),
        notas: _notasController.text.trim().isEmpty 
            ? null 
            : _notasController.text.trim(),
        fechaCreacion: widget.mejora?.fechaCreacion ?? DateTime.now(),
      );

      if (widget.mejora == null) {
        await _mejoraService.crearMejora(mejora);
      } else {
        await _mejoraService.actualizarMejora(widget.mejora!.id!, mejora);
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
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mejora == null ? 'Nueva Idea de Mejora' : 'Editar Mejora'),
        actions: [
          if (_guardando)
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
              onPressed: _guardarMejora,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Imagen
            GestureDetector(
              onTap: _guardando ? null : _mostrarOpcionesImagen,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _imagenPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_imagenPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 60,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toca para agregar imagen',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la pieza',
                hintText: 'Ej: Tapetes deportivos',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.build),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
              enabled: !_guardando,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _linkController,
              decoration: const InputDecoration(
                labelText: 'Link de compra (opcional)',
                hintText: 'https://...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              enabled: !_guardando,
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
              enabled: !_guardando,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _guardando ? null : _guardarMejora,
              icon: _guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(widget.mejora == null ? 'Guardar Mejora' : 'Actualizar'),
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
