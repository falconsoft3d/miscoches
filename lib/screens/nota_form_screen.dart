import 'package:flutter/material.dart';
import '../models/nota.dart';
import '../services/nota_service.dart';

class NotaFormScreen extends StatefulWidget {
  final int cocheId;
  final Nota? nota;

  const NotaFormScreen({
    super.key,
    required this.cocheId,
    this.nota,
  });

  @override
  State<NotaFormScreen> createState() => _NotaFormScreenState();
}

class _NotaFormScreenState extends State<NotaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final NotaService _notaService = NotaService();

  late TextEditingController _tituloController;
  late TextEditingController _contenidoController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.nota?.titulo ?? '');
    _contenidoController = TextEditingController(text: widget.nota?.contenido ?? '');
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.nota != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Nota' : 'Nueva Nota'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'Ej: Cambio de aceite, Seguro, ITV',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un título';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contenidoController,
              decoration: const InputDecoration(
                labelText: 'Contenido *',
                hintText: 'Escribe aquí los detalles de la nota...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              minLines: 5,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el contenido';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _guardarNota,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(isEditing ? 'Actualizar Nota' : 'Guardar Nota'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarNota() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final nota = Nota(
      id: widget.nota?.id,
      cocheId: widget.cocheId,
      titulo: _tituloController.text.trim(),
      contenido: _contenidoController.text.trim(),
      fechaCreacion: widget.nota?.fechaCreacion,
    );

    bool success;
    if (widget.nota == null) {
      final id = await _notaService.crearNota(nota);
      success = id != null;
    } else {
      success = await _notaService.actualizarNota(widget.nota!.id!, nota);
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.nota == null
                ? 'Nota creada exitosamente'
                : 'Nota actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la nota'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
