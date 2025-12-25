import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/coche.dart';
import '../services/coche_service.dart';

class CocheConfigScreen extends StatefulWidget {
  final Coche coche;

  const CocheConfigScreen({super.key, required this.coche});

  @override
  State<CocheConfigScreen> createState() => _CocheConfigScreenState();
}

class _CocheConfigScreenState extends State<CocheConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final CocheService _cocheService = CocheService();

  late TextEditingController _intervaloKmController;
  DateTime? _proximoMantenimientoFecha;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _intervaloKmController = TextEditingController(
      text: widget.coche.intervaloMantenimientoKm?.toString() ?? '',
    );
    _proximoMantenimientoFecha = widget.coche.proximoMantenimientoFecha;
  }

  @override
  void dispose() {
    _intervaloKmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Mantenimiento'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.directions_car, 
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${widget.coche.marca} ${widget.coche.modelo}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.coche.matricula,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recordatorio de Mantenimiento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configura cada cuántos kilómetros o en qué fecha debes hacer el próximo mantenimiento',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _intervaloKmController,
              decoration: InputDecoration(
                labelText: 'Intervalo de Mantenimiento',
                hintText: 'Ej: 5000, 10000, 15000',
                helperText: 'Cada cuántos kilómetros hacer mantenimiento',
                border: const OutlineInputBorder(),
                suffixText: 'km',
                prefixIcon: const Icon(Icons.build),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final km = int.tryParse(value);
                  if (km == null || km <= 0) {
                    return 'Ingresa un valor válido';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'O configura por fecha:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.calendar_today,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text('Próximo Mantenimiento'),
              subtitle: Text(
                _proximoMantenimientoFecha != null
                    ? DateFormat('dd/MM/yyyy').format(_proximoMantenimientoFecha!)
                    : 'No configurado',
              ),
              trailing: _proximoMantenimientoFecha != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _proximoMantenimientoFecha = null;
                        });
                      },
                    )
                  : null,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _proximoMantenimientoFecha ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) {
                  setState(() {
                    _proximoMantenimientoFecha = date;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, 
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Información',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Cuando repostes, el kilometraje se actualizará automáticamente\n'
                      '• En la lista de coches verás cuántos días faltan para el mantenimiento\n'
                      '• Si configuras ambos (km y fecha), se usará el que esté más próximo',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _guardarConfiguracion,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Guardar Configuración'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarConfiguracion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final intervaloKm = _intervaloKmController.text.trim().isNotEmpty
        ? int.tryParse(_intervaloKmController.text.trim())
        : null;

    final cocheActualizado = widget.coche.copyWith(
      intervaloMantenimientoKm: intervaloKm,
      proximoMantenimientoFecha: _proximoMantenimientoFecha,
    );

    final success = await _cocheService.actualizarCoche(
      widget.coche.id!,
      cocheActualizado,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuración guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la configuración'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
