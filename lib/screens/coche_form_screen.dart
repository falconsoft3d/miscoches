import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/coche.dart';
import '../services/coche_service.dart';
import '../widgets/image_gallery_widget.dart';

class CocheFormScreen extends StatefulWidget {
  final Coche? coche;

  const CocheFormScreen({super.key, this.coche});

  @override
  State<CocheFormScreen> createState() => _CocheFormScreenState();
}

class _CocheFormScreenState extends State<CocheFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final CocheService _cocheService = CocheService();

  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _matriculaController;
  late TextEditingController _yearController;
  late TextEditingController _colorController;
  late TextEditingController _vinController;
  late TextEditingController _kilometrajeController;
  late TextEditingController _propietarioController;
  late TextEditingController _cuotaMensualController;
  late TextEditingController _totalPendienteController;
  late DateTime _fechaCompra;
  late List<String> _imagenes;
  late String? _imagenFavorita;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _marcaController = TextEditingController(text: widget.coche?.marca ?? '');
    _modeloController = TextEditingController(text: widget.coche?.modelo ?? '');
    _matriculaController =
        TextEditingController(text: widget.coche?.matricula ?? '');
    _yearController =
        TextEditingController(text: widget.coche?.year.toString() ?? '');
    _colorController = TextEditingController(text: widget.coche?.color ?? '');
    _vinController = TextEditingController(text: widget.coche?.vin ?? '');
    _kilometrajeController = TextEditingController(
        text: widget.coche?.kilometraje?.toString() ?? '');
    _propietarioController =
        TextEditingController(text: widget.coche?.propietario ?? '');
    _cuotaMensualController = TextEditingController(
        text: widget.coche?.cuotaMensual?.toString() ?? '');
    _totalPendienteController = TextEditingController(
        text: widget.coche?.totalPendiente?.toString() ?? '');
    _fechaCompra = widget.coche?.fechaCompra ?? DateTime.now();
    _imagenes = widget.coche?.imagenes ?? [];
    _imagenFavorita = widget.coche?.imagenFavorita;
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _matriculaController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _vinController.dispose();
    _kilometrajeController.dispose();
    _propietarioController.dispose();
    _cuotaMensualController.dispose();
    _totalPendienteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.coche != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Coche' : 'Agregar Coche'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _marcaController,
              decoration: const InputDecoration(
                labelText: 'Marca *',
                hintText: 'Ej: Toyota, Ford, BMW',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la marca';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _modeloController,
              decoration: const InputDecoration(
                labelText: 'Modelo *',
                hintText: 'Ej: Corolla, Focus, Serie 3',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el modelo';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _matriculaController,
              decoration: const InputDecoration(
                labelText: 'Matrícula *',
                hintText: 'Ej: ABC1234',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la matrícula';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Año *',
                hintText: 'Ej: 2020',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el año';
                }
                final year = int.tryParse(value);
                if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                  return 'Por favor ingresa un año válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Color',
                hintText: 'Ej: Rojo, Azul, Negro',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _vinController,
              decoration: const InputDecoration(
                labelText: 'VIN / Número de Chasis',
                hintText: 'Número de identificación del vehículo',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _kilometrajeController,
              decoration: const InputDecoration(
                labelText: 'Kilometraje',
                hintText: 'Ej: 50000',
                border: OutlineInputBorder(),
                suffixText: 'km',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha de Compra *'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_fechaCompra)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _fechaCompra,
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _fechaCompra = date;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _propietarioController,
              decoration: const InputDecoration(
                labelText: 'Propietario',
                hintText: 'Nombre del propietario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cuotaMensualController,
              decoration: const InputDecoration(
                labelText: 'Cuota Mensual',
                hintText: 'Ej: 500',
                border: OutlineInputBorder(),
                prefixText: '€ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalPendienteController,
              decoration: const InputDecoration(
                labelText: 'Total Pendiente',
                hintText: 'Ej: 10000',
                border: OutlineInputBorder(),
                prefixText: '€ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),
            ImageGalleryWidget(
              images: _imagenes,
              favoriteImage: _imagenFavorita,
              onImagesChanged: (images, favorite) {
                setState(() {
                  _imagenes = images;
                  _imagenFavorita = favorite;
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _guardarCoche,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(isEditing ? 'Actualizar Coche' : 'Guardar Coche'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarCoche() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final coche = Coche(
      id: widget.coche?.id,
      marca: _marcaController.text.trim(),
      modelo: _modeloController.text.trim(),
      matricula: _matriculaController.text.trim().toUpperCase(),
      year: int.parse(_yearController.text.trim()),
      color: _colorController.text.trim().isNotEmpty
          ? _colorController.text.trim()
          : null,
      vin: _vinController.text.trim().isNotEmpty
          ? _vinController.text.trim().toUpperCase()
          : null,
      kilometraje: _kilometrajeController.text.trim().isNotEmpty
          ? double.parse(_kilometrajeController.text.trim())
          : null,
      fechaCompra: _fechaCompra,
      propietario: _propietarioController.text.trim().isNotEmpty
          ? _propietarioController.text.trim()
          : null,
      cuotaMensual: _cuotaMensualController.text.trim().isNotEmpty
          ? double.parse(_cuotaMensualController.text.trim())
          : null,
      totalPendiente: _totalPendienteController.text.trim().isNotEmpty
          ? double.parse(_totalPendienteController.text.trim())
          : null,
      imagenes: _imagenes,
      imagenFavorita: _imagenFavorita,
      fechaCreacion: widget.coche?.fechaCreacion,
    );

    bool success;
    if (widget.coche == null) {
      final id = await _cocheService.crearCoche(coche);
      success = id != null;
    } else {
      success = await _cocheService.actualizarCoche(widget.coche!.id!, coche);
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.coche == null
                ? 'Coche creado exitosamente'
                : 'Coche actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el coche'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
