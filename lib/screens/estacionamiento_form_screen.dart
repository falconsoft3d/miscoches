import 'package:flutter/material.dart';
import '../models/estacionamiento.dart';
import '../services/estacionamiento_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class EstacionamientoFormScreen extends StatefulWidget {
  final int cocheId;
  final Estacionamiento? estacionamiento;

  const EstacionamientoFormScreen({
    super.key,
    required this.cocheId,
    this.estacionamiento,
  });

  @override
  State<EstacionamientoFormScreen> createState() => _EstacionamientoFormScreenState();
}

class _EstacionamientoFormScreenState extends State<EstacionamientoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pisoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _notasController = TextEditingController();
  
  double? _latitud;
  double? _longitud;
  String? _direccion;
  bool _obteniendoUbicacion = false;

  @override
  void initState() {
    super.initState();
    if (widget.estacionamiento != null) {
      _pisoController.text = widget.estacionamiento!.piso ?? '';
      _numeroController.text = widget.estacionamiento!.numero ?? '';
      _notasController.text = widget.estacionamiento!.notas ?? '';
      _latitud = widget.estacionamiento!.latitud;
      _longitud = widget.estacionamiento!.longitud;
      _direccion = widget.estacionamiento!.direccion;
    }
  }

  @override
  void dispose() {
    _pisoController.dispose();
    _numeroController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _obtenerUbicacionActual() async {
    setState(() => _obteniendoUbicacion = true);

    try {
      // Verificar permisos
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Los servicios de ubicación están desactivados')),
        );
        setState(() => _obteniendoUbicacion = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permisos de ubicación denegados')),
          );
          setState(() => _obteniendoUbicacion = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permisos de ubicación denegados permanentemente')),
        );
        setState(() => _obteniendoUbicacion = false);
        return;
      }

      // Obtener ubicación
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Obtener dirección
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String direccion = '';
          if (place.street != null && place.street!.isNotEmpty) {
            direccion = place.street!;
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            if (direccion.isNotEmpty) direccion += ', ';
            direccion += place.locality!;
          }
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            if (direccion.isNotEmpty) direccion += ', ';
            direccion += place.administrativeArea!;
          }
          setState(() {
            _direccion = direccion.isNotEmpty ? direccion : 'Ubicación capturada';
          });
        } else {
          setState(() {
            _direccion = 'Ubicación capturada';
          });
        }
      } catch (e) {
        setState(() {
          _direccion = 'Ubicación capturada';
        });
      }

      setState(() {
        _latitud = position.latitude;
        _longitud = position.longitude;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación capturada'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener ubicación: $e')),
      );
    } finally {
      setState(() => _obteniendoUbicacion = false);
    }
  }

  Future<void> _abrirEnMapa() async {
    if (_latitud == null || _longitud == null) return;
    
    final url = Uri.parse('https://maps.apple.com/?q=$_latitud,$_longitud');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final estacionamiento = Estacionamiento(
      id: widget.estacionamiento?.id,
      cocheId: widget.cocheId,
      latitud: _latitud,
      longitud: _longitud,
      direccion: _direccion,
      piso: _pisoController.text.isEmpty ? null : _pisoController.text,
      numero: _numeroController.text.isEmpty ? null : _numeroController.text,
      notas: _notasController.text.isEmpty ? null : _notasController.text,
      fechaCreacion: widget.estacionamiento?.fechaCreacion ?? DateTime.now(),
    );

    try {
      if (widget.estacionamiento == null) {
        await EstacionamientoService.instance.registrarEstacionamiento(estacionamiento);
      } else {
        await EstacionamientoService.instance.actualizarEstacionamiento(
          estacionamiento.id!,
          estacionamiento,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esNuevo = widget.estacionamiento == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esNuevo ? 'Registrar Estacionamiento' : 'Editar Estacionamiento'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Ubicación GPS
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ubicación GPS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_latitud != null && _longitud != null) ...[
                      Text(_direccion ?? 'Ubicación capturada'),
                      const SizedBox(height: 4),
                      Text(
                        'Lat: ${_latitud!.toStringAsFixed(6)}, Lon: ${_longitud!.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _obteniendoUbicacion ? null : _obtenerUbicacionActual,
                            icon: _obteniendoUbicacion
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.my_location, size: 20),
                            label: const Text('Actualizar'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _abrirEnMapa,
                            icon: const Icon(Icons.map, size: 20),
                            label: const Text('Ver en mapa'),
                          ),
                        ],
                      ),
                    ] else ...[
                      const Text('No se ha capturado la ubicación'),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _obteniendoUbicacion ? null : _obtenerUbicacionActual,
                        icon: _obteniendoUbicacion
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location),
                        label: const Text('Capturar ubicación actual'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Piso
            TextFormField(
              controller: _pisoController,
              decoration: const InputDecoration(
                labelText: 'Piso (opcional)',
                hintText: 'Ej: 2, P1, Planta baja',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Número
            TextFormField(
              controller: _numeroController,
              decoration: const InputDecoration(
                labelText: 'Número (opcional)',
                hintText: 'Ej: 45, A12',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Notas
            TextFormField(
              controller: _notasController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Información adicional del estacionamiento',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            
            // Botón guardar
            ElevatedButton(
              onPressed: _guardar,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(esNuevo ? 'Guardar Estacionamiento' : 'Actualizar Estacionamiento'),
            ),
          ],
        ),
      ),
    );
  }
}
