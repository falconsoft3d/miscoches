import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tarea.dart';
import '../services/tarea_service.dart';

class TareaFormScreen extends StatefulWidget {
  final int cocheId;
  final Tarea? tarea;

  const TareaFormScreen({
    Key? key,
    required this.cocheId,
    this.tarea,
  }) : super(key: key);

  @override
  State<TareaFormScreen> createState() => _TareaFormScreenState();
}

class _TareaFormScreenState extends State<TareaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tareaService = TareaService();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime? _fechaLimite;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    if (widget.tarea != null) {
      _tituloController.text = widget.tarea!.titulo;
      _descripcionController.text = widget.tarea!.descripcion ?? '';
      _fechaLimite = widget.tarea!.fechaLimite;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaLimite ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 años
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && picked != _fechaLimite) {
      setState(() {
        _fechaLimite = picked;
      });
    }
  }

  Future<void> _guardarTarea() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final tarea = Tarea(
        id: widget.tarea?.id,
        cocheId: widget.cocheId,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        completada: widget.tarea?.completada ?? false,
        fechaLimite: _fechaLimite,
        fechaCreacion: widget.tarea?.fechaCreacion ?? DateTime.now(),
      );

      if (widget.tarea == null) {
        await _tareaService.crearTarea(tarea);
      } else {
        await _tareaService.actualizarTarea(widget.tarea!.id!, tarea);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la tarea: $e'),
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
        title: Text(widget.tarea == null ? 'Nueva Tarea' : 'Editar Tarea'),
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
              onPressed: _guardarTarea,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej: Cambiar aceite',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El título es obligatorio';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
              enabled: !_guardando,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Detalles de la tarea...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              enabled: !_guardando,
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha límite (opcional)'),
                subtitle: _fechaLimite != null
                    ? Text(DateFormat('dd/MM/yyyy').format(_fechaLimite!))
                    : const Text('Sin fecha límite'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_fechaLimite != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _guardando
                            ? null
                            : () {
                                setState(() {
                                  _fechaLimite = null;
                                });
                              },
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _guardando ? null : _seleccionarFecha,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _guardando ? null : _guardarTarea,
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
              label: Text(widget.tarea == null ? 'Crear Tarea' : 'Guardar Cambios'),
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
