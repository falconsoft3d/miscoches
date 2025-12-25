import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/direccion.dart';
import '../services/direccion_service.dart';

class DireccionFormScreen extends StatefulWidget {
  final int cocheId;
  final Direccion? direccion;

  const DireccionFormScreen({
    Key? key,
    required this.cocheId,
    this.direccion,
  }) : super(key: key);

  @override
  State<DireccionFormScreen> createState() => _DireccionFormScreenState();
}

class _DireccionFormScreenState extends State<DireccionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _direccionService = DireccionService();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _notasController = TextEditingController();
  
  String? _tipoSeleccionado;
  bool _guardando = false;

  final List<String> _tipos = [
    'Concesionario',
    'Taller',
    'Gasolinera',
    'Estacionamiento',
    'Lavado',
    'ITV',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.direccion != null) {
      _nombreController.text = widget.direccion!.nombre;
      _direccionController.text = widget.direccion!.direccion;
      _latitudController.text = widget.direccion!.latitud?.toString() ?? '';
      _longitudController.text = widget.direccion!.longitud?.toString() ?? '';
      _tipoSeleccionado = widget.direccion!.tipo;
      _telefonoController.text = widget.direccion!.telefono ?? '';
      _notasController.text = widget.direccion!.notas ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _telefonoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _abrirMapa() async {
    final direccion = Uri.encodeComponent(_direccionController.text);
    final url = 'https://www.google.com/maps/search/?api=1&query=$direccion';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el mapa')),
        );
      }
    }
  }

  Future<void> _obtenerUbicacionActual() async {
    try {
      // Verificar si los servicios de ubicación están habilitados
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Los servicios de ubicación están desactivados'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permiso de ubicación denegado'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permiso de ubicación denegado permanentemente. Actívalo en Configuración'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text('Obteniendo ubicación...'),
              ],
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }

      // Obtener posición actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Obtener dirección desde coordenadas
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String direccion = '';
        
        if (place.street != null && place.street!.isNotEmpty) {
          direccion += place.street!;
        }
        if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
          direccion += ' ${place.subThoroughfare}';
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          if (direccion.isNotEmpty) direccion += ', ';
          direccion += place.locality!;
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          direccion += ' ${place.postalCode}';
        }
        if (place.country != null && place.country!.isNotEmpty) {
          if (direccion.isNotEmpty) direccion += ', ';
          direccion += place.country!;
        }

        setState(() {
          _direccionController.text = direccion.isNotEmpty ? direccion : 'Ubicación actual';
          _latitudController.text = position.latitude.toString();
          _longitudController.text = position.longitude.toString();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ubicación obtenida correctamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener ubicación: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _guardarDireccion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final direccion = Direccion(
        id: widget.direccion?.id,
        cocheId: widget.cocheId,
        nombre: _nombreController.text.trim(),
        direccion: _direccionController.text.trim(),
        latitud: _latitudController.text.isEmpty 
            ? null 
            : double.tryParse(_latitudController.text),
        longitud: _longitudController.text.isEmpty 
            ? null 
            : double.tryParse(_longitudController.text),
        tipo: _tipoSeleccionado,
        telefono: _telefonoController.text.trim().isEmpty 
            ? null 
            : _telefonoController.text.trim(),
        notas: _notasController.text.trim().isEmpty 
            ? null 
            : _notasController.text.trim(),
        fechaCreacion: widget.direccion?.fechaCreacion ?? DateTime.now(),
      );

      if (widget.direccion == null) {
        await _direccionService.crearDireccion(direccion);
      } else {
        await _direccionService.actualizarDireccion(widget.direccion!.id!, direccion);
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
        title: Text(widget.direccion == null ? 'Nuevo Lugar' : 'Editar Lugar'),
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
              onPressed: _guardarDireccion,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Tipo de lugar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              value: _tipoSeleccionado,
              items: _tipos.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(tipo),
                );
              }).toList(),
              onChanged: _guardando ? null : (value) {
                setState(() {
                  _tipoSeleccionado = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ej: Concesionario Mercedes Madrid',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
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
              controller: _direccionController,
              decoration: InputDecoration(
                labelText: 'Dirección',
                hintText: 'Calle, número, ciudad...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: _direccionController.text.isEmpty || _guardando
                      ? null
                      : _abrirMapa,
                  tooltip: 'Abrir en mapa',
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La dirección es obligatoria';
                }
                return null;
              },
              maxLines: 2,
              textCapitalization: TextCapitalization.words,
              enabled: !_guardando,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _guardando ? null : _obtenerUbicacionActual,
              icon: const Icon(Icons.my_location),
              label: const Text('Usar mi ubicación actual'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudController,
                    decoration: const InputDecoration(
                      labelText: 'Latitud (opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.navigation),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: !_guardando,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _longitudController,
                    decoration: const InputDecoration(
                      labelText: 'Longitud (opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.navigation),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: !_guardando,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
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
              onPressed: _guardando ? null : _guardarDireccion,
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
              label: Text(widget.direccion == null ? 'Guardar Lugar' : 'Actualizar'),
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
