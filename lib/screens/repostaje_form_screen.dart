import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/repostaje.dart';
import '../services/repostaje_service.dart';
import '../services/coche_service.dart';

class RepostajeFormScreen extends StatefulWidget {
  final int cocheId;
  final double kilometrajeActual;
  final Repostaje? repostaje;

  const RepostajeFormScreen({
    super.key,
    required this.cocheId,
    required this.kilometrajeActual,
    this.repostaje,
  });

  @override
  State<RepostajeFormScreen> createState() => _RepostajeFormScreenState();
}

class _RepostajeFormScreenState extends State<RepostajeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final RepostajeService _repostajeService = RepostajeService();
  final CocheService _cocheService = CocheService();

  late TextEditingController _litrosController;
  late TextEditingController _precioLitroController;
  late TextEditingController _kilometrajeController;
  late TextEditingController _estacionController;
  late TextEditingController _notasController;

  late TipoCombustible _tipoCombustibleSeleccionado;
  late DateTime _fecha;
  bool _tanqueLleno = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _litrosController =
        TextEditingController(text: widget.repostaje?.litros.toString() ?? '');
    _precioLitroController = TextEditingController(
        text: widget.repostaje?.precioPorLitro?.toString() ?? '');
    _kilometrajeController = TextEditingController(
        text: widget.repostaje?.kilometraje.toString() ??
            widget.kilometrajeActual.toString());
    _estacionController =
        TextEditingController(text: widget.repostaje?.gasolinera ?? '');
    _notasController =
        TextEditingController(text: widget.repostaje?.notas ?? '');

    _tipoCombustibleSeleccionado =
        widget.repostaje?.tipoCombustible ?? TipoCombustible.gasolina95;
    _fecha = widget.repostaje?.fecha ?? DateTime.now();
    _tanqueLleno = widget.repostaje?.tanqueLleno ?? false;
  }

  @override
  void dispose() {
    _litrosController.dispose();
    _precioLitroController.dispose();
    _kilometrajeController.dispose();
    _estacionController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  double get _costoTotal {
    final litros = double.tryParse(_litrosController.text) ?? 0;
    final precioLitro = double.tryParse(_precioLitroController.text) ?? 0;
    return litros * precioLitro;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.repostaje != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Repostaje' : 'Agregar Repostaje'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha *'),
              subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(_fecha)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _fecha,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null && mounted) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_fecha),
                  );
                  if (time != null) {
                    setState(() {
                      _fecha = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TipoCombustible>(
              value: _tipoCombustibleSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Tipo de Combustible *',
                border: OutlineInputBorder(),
              ),
              items: TipoCombustible.values.map((tipo) {
                String nombre;
                switch (tipo) {
                  case TipoCombustible.gasolina95:
                    nombre = 'Gasolina 95';
                    break;
                  case TipoCombustible.gasolina98:
                    nombre = 'Gasolina 98';
                    break;
                  case TipoCombustible.diesel:
                    nombre = 'Diesel';
                    break;
                  case TipoCombustible.electrico:
                    nombre = 'Eléctrico';
                    break;
                  case TipoCombustible.hibrido:
                    nombre = 'Híbrido';
                    break;
                  case TipoCombustible.glp:
                    nombre = 'GLP';
                    break;
                  case TipoCombustible.gnc:
                    nombre = 'GNC';
                    break;
                }
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(nombre),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _tipoCombustibleSeleccionado = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _litrosController,
              decoration: const InputDecoration(
                labelText: 'Litros *',
                hintText: '0.00',
                border: OutlineInputBorder(),
                suffixText: 'L',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa los litros';
                }
                final litros = double.tryParse(value);
                if (litros == null || litros <= 0) {
                  return 'Por favor ingresa un valor válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _precioLitroController,
              decoration: const InputDecoration(
                labelText: 'Precio por Litro *',
                hintText: '0.00',
                border: OutlineInputBorder(),
                prefixText: '€ ',
                suffixText: '/L',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el precio por litro';
                }
                final precio = double.tryParse(value);
                if (precio == null || precio <= 0) {
                  return 'Por favor ingresa un valor válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Costo Total:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '€ ${_costoTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _kilometrajeController,
              decoration: const InputDecoration(
                labelText: 'Kilometraje *',
                hintText: 'Kilometraje actual',
                border: OutlineInputBorder(),
                suffixText: 'km',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el kilometraje';
                }
                final km = double.tryParse(value);
                if (km == null || km < 0) {
                  return 'Por favor ingresa un valor válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Tanque Lleno'),
              subtitle: const Text(
                  'Marca esta opción si llenaste el tanque completamente'),
              value: _tanqueLleno,
              onChanged: (value) {
                setState(() {
                  _tanqueLleno = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _estacionController,
              decoration: const InputDecoration(
                labelText: 'Estación de Servicio',
                hintText: 'Nombre de la estación',
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
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _guardarRepostaje,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      isEditing ? 'Actualizar Repostaje' : 'Guardar Repostaje'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarRepostaje() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final kilometraje = double.parse(_kilometrajeController.text.trim());

    final repostaje = Repostaje(
      id: widget.repostaje?.id,
      cocheId: widget.cocheId,
      fecha: _fecha,
      litros: double.parse(_litrosController.text.trim()),
      precioPorLitro: _precioLitroController.text.trim().isNotEmpty
          ? double.parse(_precioLitroController.text.trim())
          : null,
      costoTotal: _costoTotal,
      kilometraje: kilometraje,
      tipoCombustible: _tipoCombustibleSeleccionado,
      tanqueLleno: _tanqueLleno,
      gasolinera: _estacionController.text.trim().isNotEmpty
          ? _estacionController.text.trim()
          : null,
      notas: _notasController.text.trim().isNotEmpty
          ? _notasController.text.trim()
          : null,
      fechaCreacion: widget.repostaje?.fechaCreacion,
    );

    bool success;
    if (widget.repostaje == null) {
      final id = await _repostajeService.crearRepostaje(repostaje);
      success = id != null;
    } else {
      success = await _repostajeService.actualizarRepostaje(
          widget.repostaje!.id!, repostaje);
    }

    // Actualizar el kilometraje del coche
    if (success) {
      await _cocheService.actualizarKilometraje(widget.cocheId, kilometraje);
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.repostaje == null
                ? 'Repostaje creado exitosamente'
                : 'Repostaje actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el repostaje'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
