import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mantenimiento.dart';
import '../services/mantenimiento_service.dart';

class MantenimientoFormScreen extends StatefulWidget {
  final int cocheId;
  final Mantenimiento? mantenimiento;

  const MantenimientoFormScreen({
    super.key,
    required this.cocheId,
    this.mantenimiento,
  });

  @override
  State<MantenimientoFormScreen> createState() =>
      _MantenimientoFormScreenState();
}

class _MantenimientoFormScreenState extends State<MantenimientoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final MantenimientoService _mantenimientoService = MantenimientoService();

  late TextEditingController _descripcionController;
  late TextEditingController _kilometrajeController;
  late TextEditingController _costoController;
  late TextEditingController _tallerController;
  late TextEditingController _notasController;
  late TextEditingController _proximoKilometrajeController;

  late TipoMantenimiento _tipoSeleccionado;
  late DateTime _fecha;
  DateTime? _proximoMantenimiento;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descripcionController =
        TextEditingController(text: widget.mantenimiento?.descripcion ?? '');
    _kilometrajeController = TextEditingController(
        text: widget.mantenimiento?.kilometraje.toString() ?? '');
    _costoController = TextEditingController(
        text: widget.mantenimiento?.costo?.toString() ?? '');
    _tallerController =
        TextEditingController(text: widget.mantenimiento?.taller ?? '');
    _notasController =
        TextEditingController(text: widget.mantenimiento?.notas ?? '');
    _proximoKilometrajeController = TextEditingController(
        text: widget.mantenimiento?.proximoKilometraje?.toString() ?? '');

    _tipoSeleccionado =
        widget.mantenimiento?.tipo ?? TipoMantenimiento.cambioAceite;
    _fecha = widget.mantenimiento?.fecha ?? DateTime.now();
    _proximoMantenimiento = widget.mantenimiento?.proximoMantenimiento;
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _kilometrajeController.dispose();
    _costoController.dispose();
    _tallerController.dispose();
    _notasController.dispose();
    _proximoKilometrajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.mantenimiento != null;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(isEditing ? 'Editar Mantenimiento' : 'Agregar Mantenimiento'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<TipoMantenimiento>(
              value: _tipoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Tipo de Mantenimiento *',
                border: OutlineInputBorder(),
              ),
              items: TipoMantenimiento.values.map((tipo) {
                String nombre;
                switch (tipo) {
                  case TipoMantenimiento.cambioAceite:
                    nombre = 'Cambio de Aceite';
                    break;
                  case TipoMantenimiento.revisionGeneral:
                    nombre = 'Revisión General';
                    break;
                  case TipoMantenimiento.cambioFrenos:
                    nombre = 'Cambio de Frenos';
                    break;
                  case TipoMantenimiento.cambioNeumaticos:
                    nombre = 'Cambio de Neumáticos';
                    break;
                  case TipoMantenimiento.reparacion:
                    nombre = 'Reparación';
                    break;
                  case TipoMantenimiento.inspeccionTecnica:
                    nombre = 'Inspección Técnica';
                    break;
                  case TipoMantenimiento.otros:
                    nombre = 'Otros';
                    break;
                }
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(nombre),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _tipoSeleccionado = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                hintText: 'Descripción del mantenimiento',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa una descripción';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha *'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_fecha)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _fecha,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _fecha = date;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _kilometrajeController,
              decoration: const InputDecoration(
                labelText: 'Kilometraje',
                hintText: 'Kilometraje al momento del servicio',
                border: OutlineInputBorder(),
                suffixText: 'km',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costoController,
              decoration: const InputDecoration(
                labelText: 'Costo',
                hintText: 'Costo del servicio',
                border: OutlineInputBorder(),
                prefixText: '€ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tallerController,
              decoration: const InputDecoration(
                labelText: 'Taller',
                hintText: 'Nombre del taller o mecánico',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notasController,
              decoration: const InputDecoration(
                labelText: 'Notas',
                hintText: 'Notas adicionales',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'Próximo Mantenimiento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha estimada'),
              subtitle: Text(_proximoMantenimiento != null
                  ? DateFormat('dd/MM/yyyy').format(_proximoMantenimiento!)
                  : 'No configurado'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_proximoMantenimiento != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _proximoMantenimiento = null;
                        });
                      },
                    ),
                  const Icon(Icons.calendar_today),
                ],
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _proximoMantenimiento ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                );
                if (date != null) {
                  setState(() {
                    _proximoMantenimiento = date;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _proximoKilometrajeController,
              decoration: const InputDecoration(
                labelText: 'Kilometraje estimado',
                hintText: 'Kilometraje para el próximo servicio',
                border: OutlineInputBorder(),
                suffixText: 'km',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _guardarMantenimiento,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(isEditing
                      ? 'Actualizar Mantenimiento'
                      : 'Guardar Mantenimiento'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarMantenimiento() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final mantenimiento = Mantenimiento(
      id: widget.mantenimiento?.id,
      cocheId: widget.cocheId,
      tipo: _tipoSeleccionado,
      descripcion: _descripcionController.text.trim(),
      fecha: _fecha,
      kilometraje: double.parse(_kilometrajeController.text.trim()),
      costo: _costoController.text.trim().isNotEmpty
          ? double.parse(_costoController.text.trim())
          : null,
      taller: _tallerController.text.trim().isNotEmpty
          ? _tallerController.text.trim()
          : null,
      notas: _notasController.text.trim().isNotEmpty
          ? _notasController.text.trim()
          : null,
      proximoMantenimiento: _proximoMantenimiento,
      proximoKilometraje: _proximoKilometrajeController.text.trim().isNotEmpty
          ? double.parse(_proximoKilometrajeController.text.trim())
          : null,
      fechaCreacion: widget.mantenimiento?.fechaCreacion,
    );

    bool success;
    if (widget.mantenimiento == null) {
      final id = await _mantenimientoService.crearMantenimiento(mantenimiento);
      success = id != null;
    } else {
      success = await _mantenimientoService.actualizarMantenimiento(
          widget.mantenimiento!.id!, mantenimiento);
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.mantenimiento == null
                ? 'Mantenimiento creado exitosamente'
                : 'Mantenimiento actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el mantenimiento'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
