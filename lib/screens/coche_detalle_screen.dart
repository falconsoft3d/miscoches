import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/coche.dart';
import '../models/mantenimiento.dart';
import '../models/repostaje.dart';
import '../models/nota.dart';
import '../models/tarea.dart';
import '../models/direccion.dart';
import '../models/mejora.dart';
import '../models/estacionamiento.dart';
import '../services/coche_service.dart';
import '../services/mantenimiento_service.dart';
import '../services/repostaje_service.dart';
import '../services/nota_service.dart';
import '../services/tarea_service.dart';
import '../services/direccion_service.dart';
import '../services/mejora_service.dart';
import '../services/estacionamiento_service.dart';
import 'coche_form_screen.dart';
import 'coche_config_screen.dart';
import 'mantenimiento_form_screen.dart';
import 'repostaje_form_screen.dart';
import 'nota_form_screen.dart';
import 'tarea_form_screen.dart';
import 'direccion_form_screen.dart';
import 'mejora_form_screen.dart';
import 'estacionamiento_form_screen.dart';
import 'kpi_screen.dart';

class CocheDetalleScreen extends StatefulWidget {
  final int cocheId;

  const CocheDetalleScreen({super.key, required this.cocheId});

  @override
  State<CocheDetalleScreen> createState() => _CocheDetalleScreenState();
}

class _CocheDetalleScreenState extends State<CocheDetalleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CocheService _cocheService = CocheService();
  final MantenimientoService _mantenimientoService = MantenimientoService();
  final RepostajeService _repostajeService = RepostajeService();
  final NotaService _notaService = NotaService();
  final TareaService _tareaService = TareaService();
  final DireccionService _direccionService = DireccionService();
  final MejoraService _mejoraService = MejoraService();
  final EstacionamientoService _estacionamientoService = EstacionamientoService.instance;

  Coche? _coche;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this); // Incrementar a 9 pestañas
    _cargarCoche();
  }

  Future<void> _cargarCoche() async {
    setState(() => _isLoading = true);
    _coche = await _cocheService.getCoche(widget.cocheId);
    setState(() => _isLoading = false);
  }

  Future<List<String>> _obtenerImagenesValidas(List<String> imagenes) async {
    final imagenesValidas = <String>[];
    
    for (final imagePath in imagenes) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          imagenesValidas.add(imagePath);
        }
      } catch (e) {
        // Ignorar imágenes inválidas
      }
    }
    
    return imagenesValidas;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_coche == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Coche no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_coche!.marca} ${_coche!.modelo}'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuración de mantenimiento',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CocheConfigScreen(coche: _coche!),
                ),
              );
              if (result == true) {
                _cargarCoche();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CocheFormScreen(coche: _coche),
                ),
              );
              _cargarCoche();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmarEliminar(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline)),
            Tab(icon: Icon(Icons.local_parking_outlined)), // Nueva pestaña de estacionamiento
            Tab(icon: Icon(Icons.build_outlined)),
            Tab(icon: Icon(Icons.local_gas_station_outlined)),
            Tab(icon: Icon(Icons.note_outlined)),
            Tab(icon: Icon(Icons.task_outlined)),
            Tab(icon: Icon(Icons.place_outlined)),
            Tab(icon: Icon(Icons.lightbulb_outline)),
            Tab(icon: Icon(Icons.analytics_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetallesTab(_coche!),
          _buildEstacionamientoTab(_coche!), // Nueva pestaña de estacionamiento
          _buildMantenimientoTab(_coche!),
          _buildRepostajesTab(_coche!),
          _buildNotasTab(_coche!),
          _buildTareasTab(_coche!),
          _buildLugaresTab(_coche!),
          _buildMejorasTab(_coche!),
          KpiScreen(cocheId: widget.cocheId),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este coche? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await _cocheService.eliminarCoche(widget.cocheId);
      if (mounted) {
        if (success) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar el coche'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildDetallesTab(Coche coche) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Galería de fotos
          FutureBuilder<List<String>>(
            future: _obtenerImagenesValidas(coche.imagenes),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              final imagenesValidas = snapshot.data!;
              
              return Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Galería de fotos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: imagenesValidas.length,
                              itemBuilder: (context, index) {
                                final imagePath = imagenesValidas[index];
                                final isFavorite = imagePath == coche.imagenFavorita;
                                
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => _verImagenCompleta(imagePath),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(
                                            File(imagePath),
                                            width: 200,
                                            height: 200,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: 200,
                                                height: 200,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
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
                                        child: const Icon(
                                          Icons.star,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información General',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('Marca', coche.marca),
                  _buildInfoRow('Modelo', coche.modelo),
                  _buildInfoRow('Matrícula', coche.matricula),
                  _buildInfoRow('Año', coche.year.toString()),
                  if (coche.color != null)
                    _buildInfoRow('Color', coche.color!),
                  if (coche.vin != null)
                    _buildInfoRow('VIN', coche.vin!),
                  if (coche.kilometraje != null)
                    _buildInfoRow(
                      'Kilometraje',
                      '${coche.kilometraje!.toStringAsFixed(0)} km',
                    ),
                  _buildInfoRow(
                    'Fecha de compra',
                    dateFormat.format(coche.fechaCompra),
                  ),
                  if (coche.propietario != null)
                    _buildInfoRow('Propietario', coche.propietario!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _verImagenCompleta(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(File(imagePath)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstacionamientoTab(Coche coche) {
    return FutureBuilder<Estacionamiento?>(
      future: _estacionamientoService.getEstacionamientoActual(widget.cocheId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final estacionamientoActual = snapshot.data;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _registrarEstacionamiento(context, coche),
                      icon: const Icon(Icons.add_location),
                      label: Text(estacionamientoActual == null
                          ? 'Registrar Ubicación'
                          : 'Actualizar Ubicación'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (estacionamientoActual != null) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _verHistorialEstacionamientos(context, coche),
                      child: const Icon(Icons.history),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Estacionamiento actual
              if (estacionamientoActual != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_parking,
                                size: 32, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Estacionamiento Actual',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm')
                                        .format(estacionamientoActual.fechaCreacion),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'editar',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'eliminar',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 20),
                                      SizedBox(width: 8),
                                      Text('Eliminar'),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'editar') {
                                  _editarEstacionamiento(context, coche, estacionamientoActual);
                                } else if (value == 'eliminar') {
                                  _eliminarEstacionamiento(context, estacionamientoActual);
                                }
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // Ubicación GPS
                        if (estacionamientoActual.latitud != null &&
                            estacionamientoActual.longitud != null) ...[
                          ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(estacionamientoActual.direccion ?? 'Ubicación GPS'),
                            subtitle: Text(
                              'Lat: ${estacionamientoActual.latitud!.toStringAsFixed(6)}, '
                              'Lon: ${estacionamientoActual.longitud!.toStringAsFixed(6)}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.map),
                              onPressed: () => _abrirUbicacionEnMapa(
                                estacionamientoActual.latitud!,
                                estacionamientoActual.longitud!,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],

                        // Piso
                        if (estacionamientoActual.piso != null) ...[
                          ListTile(
                            leading: const Icon(Icons.layers),
                            title: const Text('Piso'),
                            subtitle: Text(estacionamientoActual.piso!),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],

                        // Número
                        if (estacionamientoActual.numero != null) ...[
                          ListTile(
                            leading: const Icon(Icons.pin),
                            title: const Text('Número'),
                            subtitle: Text(estacionamientoActual.numero!),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],

                        // Notas
                        if (estacionamientoActual.notas != null) ...[
                          ListTile(
                            leading: const Icon(Icons.note),
                            title: const Text('Notas'),
                            subtitle: Text(estacionamientoActual.notas!),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // No hay estacionamiento registrado
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_parking_outlined,
                          size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay estacionamiento registrado',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Registra dónde estacionaste tu coche',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }


  Widget _buildMantenimientoTab(Coche coche) {
    return FutureBuilder<List<Mantenimiento>>(
      future: _mantenimientoService.getMantenimientos(widget.cocheId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final mantenimientos = snapshot.data!;

        if (mantenimientos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.build_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No hay mantenimientos registrados',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _agregarMantenimiento(context, coche),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Mantenimiento'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: mantenimientos.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _agregarMantenimiento(context, coche),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Mantenimiento'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              );
            }

            final mantenimiento = mantenimientos[index - 1];
            return _buildMantenimientoCard(mantenimiento);
          },
        );
      },
    );
  }

  Widget _buildMantenimientoCard(Mantenimiento mantenimiento) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange[100],
          child: Icon(Icons.build, color: Colors.orange[700]),
        ),
        title: Text(mantenimiento.tipoNombre),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mantenimiento.descripcion != null)
              Text(mantenimiento.descripcion!),
            Text(dateFormat.format(mantenimiento.fecha)),
            if (mantenimiento.costo != null)
              Text('€${mantenimiento.costo!.toStringAsFixed(2)}'),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editarMantenimiento(mantenimiento),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => _eliminarMantenimiento(mantenimiento),
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepostajesTab(Coche coche) {
    return FutureBuilder<List<Repostaje>>(
      future: _repostajeService.getRepostajes(widget.cocheId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final repostajes = snapshot.data!;

        if (repostajes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_gas_station_outlined,
                    size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No hay repostajes registrados',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _agregarRepostaje(context, coche),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Repostaje'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: repostajes.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _agregarRepostaje(context, coche),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Repostaje'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              );
            }

            final repostaje = repostajes[index - 1];
            return _buildRepostajeCard(repostaje);
          },
        );
      },
    );
  }

  Widget _buildRepostajeCard(Repostaje repostaje) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(Icons.local_gas_station, color: Colors.green[700]),
        ),
        title: Text('${repostaje.litros.toStringAsFixed(2)} L'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(repostaje.tipoCombustibleNombre),
            Text(dateFormat.format(repostaje.fecha)),
            Text('€${repostaje.costoTotal.toStringAsFixed(2)}'),
            Text('${repostaje.kilometraje.toStringAsFixed(0)} km'),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editarRepostaje(repostaje),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => _eliminarRepostaje(repostaje),
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }

  void _agregarMantenimiento(BuildContext context, Coche coche) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MantenimientoFormScreen(cocheId: coche.id!),
      ),
    );
    _cargarCoche();
  }

  void _editarMantenimiento(Mantenimiento mantenimiento) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MantenimientoFormScreen(
          cocheId: widget.cocheId,
          mantenimiento: mantenimiento,
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _eliminarMantenimiento(Mantenimiento mantenimiento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar el mantenimiento "${mantenimiento.tipoNombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _mantenimientoService.eliminarMantenimiento(mantenimiento.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mantenimiento eliminado')),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _agregarRepostaje(BuildContext context, Coche coche) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RepostajeFormScreen(
          cocheId: coche.id!,
          kilometrajeActual: coche.kilometraje ?? 0,
        ),
      ),
    );
    _cargarCoche();
  }

  void _editarRepostaje(Repostaje repostaje) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RepostajeFormScreen(
          cocheId: widget.cocheId,
          kilometrajeActual: _coche?.kilometraje ?? 0,
          repostaje: repostaje,
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _eliminarRepostaje(Repostaje repostaje) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar el repostaje de ${repostaje.litros.toStringAsFixed(2)}L?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _repostajeService.eliminarRepostaje(repostaje.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Repostaje eliminado')),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildNotasTab(Coche coche) {
    return FutureBuilder<List<Nota>>(
      future: _notaService.getNotas(widget.cocheId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final notas = snapshot.data!;

        if (notas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No hay notas registradas',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _agregarNota(context, coche),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Nota'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notas.length,
              itemBuilder: (context, index) {
                final nota = notas[index];
                return _buildNotaCard(nota);
              },
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () => _agregarNota(context, coche),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotaCard(Nota nota) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _editarNota(nota),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.note, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nota.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editarNota(nota);
                      } else if (value == 'delete') {
                        _eliminarNota(nota);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                nota.contenido,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                dateFormat.format(nota.fechaCreacion),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _agregarNota(BuildContext context, Coche coche) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotaFormScreen(cocheId: coche.id!),
      ),
    );
    if (result == true) {
      _cargarCoche();
    }
  }

  void _editarNota(Nota nota) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotaFormScreen(
          cocheId: widget.cocheId,
          nota: nota,
        ),
      ),
    );
    if (result == true) {
      _cargarCoche();
    }
  }

  Future<void> _eliminarNota(Nota nota) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar la nota "${nota.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _notaService.eliminarNota(nota.id!);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nota eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _cargarCoche();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar la nota'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ==================== PESTAÑA DE TAREAS ====================

  Widget _buildTareasTab(Coche coche) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _agregarTarea(coche),
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva Tarea'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Tarea>>(
            future: _tareaService.getTareas(coche.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final tareas = snapshot.data ?? [];

              if (tareas.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay tareas registradas',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              final tareasPendientes = tareas.where((t) => !t.completada).toList();
              final tareasCompletadas = tareas.where((t) => t.completada).toList();

              return ListView(
                children: [
                  if (tareasPendientes.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Pendientes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...tareasPendientes.map((tarea) => _buildTareaItem(tarea)),
                  ],
                  if (tareasCompletadas.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Completadas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ...tareasCompletadas.map((tarea) => _buildTareaItem(tarea)),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTareaItem(Tarea tarea) {
    final bool vencida = tarea.fechaLimite != null &&
        !tarea.completada &&
        tarea.fechaLimite!.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: vencida ? Colors.red.shade50 : null,
      child: ListTile(
        leading: Checkbox(
          value: tarea.completada,
          onChanged: (value) async {
            await _tareaService.toggleCompletada(tarea.id!, value ?? false);
            _cargarCoche();
          },
        ),
        title: Text(
          tarea.titulo,
          style: TextStyle(
            decoration: tarea.completada ? TextDecoration.lineThrough : null,
            color: tarea.completada ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tarea.descripcion != null && tarea.descripcion!.isNotEmpty)
              Text(
                tarea.descripcion!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tarea.completada ? Colors.grey : null,
                ),
              ),
            if (tarea.fechaLimite != null)
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 14,
                    color: vencida ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(tarea.fechaLimite!),
                    style: TextStyle(
                      fontSize: 12,
                      color: vencida ? Colors.red : Colors.grey,
                      fontWeight: vencida ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (vencida)
                    const Text(
                      ' (Vencida)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'editar') {
              _editarTarea(tarea);
            } else if (value == 'eliminar') {
              _eliminarTarea(tarea);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'editar',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'eliminar',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _agregarTarea(Coche coche) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TareaFormScreen(
          cocheId: coche.id!,
        ),
      ),
    );
    if (result == true) {
      _cargarCoche();
    }
  }

  Future<void> _editarTarea(Tarea tarea) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TareaFormScreen(
          cocheId: widget.cocheId,
          tarea: tarea,
        ),
      ),
    );
    if (result == true) {
      _cargarCoche();
    }
  }

  Future<void> _eliminarTarea(Tarea tarea) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar la tarea "${tarea.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _tareaService.eliminarTarea(tarea.id!);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarea eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _cargarCoche();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar la tarea'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ==================== PESTAÑA DE LUGARES ====================

  Widget _buildLugaresTab(Coche coche) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _agregarLugar(coche),
                  icon: const Icon(Icons.add_location),
                  label: const Text('Nuevo Lugar'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Direccion>>(
            future: _direccionService.getDirecciones(coche.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final direcciones = snapshot.data ?? [];

              if (direcciones.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay lugares guardados',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: direcciones.length,
                itemBuilder: (context, index) {
                  final direccion = direcciones[index];
                  return _buildDireccionItem(direccion);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDireccionItem(Direccion direccion) {
    IconData icono;
    Color colorIcono;

    switch (direccion.tipo) {
      case 'Concesionario':
        icono = Icons.store;
        colorIcono = Colors.blue;
        break;
      case 'Taller':
        icono = Icons.build;
        colorIcono = Colors.orange;
        break;
      case 'Gasolinera':
        icono = Icons.local_gas_station;
        colorIcono = Colors.green;
        break;
      case 'Estacionamiento':
        icono = Icons.local_parking;
        colorIcono = Colors.purple;
        break;
      case 'Lavado':
        icono = Icons.local_car_wash;
        colorIcono = Colors.cyan;
        break;
      case 'ITV':
        icono = Icons.fact_check;
        colorIcono = Colors.red;
        break;
      default:
        icono = Icons.place;
        colorIcono = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorIcono.withOpacity(0.2),
          child: Icon(icono, color: colorIcono),
        ),
        title: Text(direccion.nombre),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              direccion.direccion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (direccion.telefono != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    direccion.telefono!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'mapa') {
              _abrirEnMapa(direccion);
            } else if (value == 'editar') {
              _editarLugar(direccion);
            } else if (value == 'eliminar') {
              _eliminarLugar(direccion);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'mapa',
              child: Row(
                children: [
                  Icon(Icons.map, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Ver en mapa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'editar',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'eliminar',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirEnMapa(Direccion direccion) async {
    try {
      String url;
      if (direccion.latitud != null && direccion.longitud != null) {
        url = 'https://www.google.com/maps/search/?api=1&query=${direccion.latitud},${direccion.longitud}';
      } else {
        final direccionEncoded = Uri.encodeComponent(direccion.direccion);
        url = 'https://www.google.com/maps/search/?api=1&query=$direccionEncoded';
      }
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el mapa')),
        );
      }
    }
  }

  Future<void> _agregarLugar(Coche coche) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DireccionFormScreen(
          cocheId: coche.id!,
        ),
      ),
    );
    if (result == true) {
      _cargarCoche();
    }
  }

  Future<void> _editarLugar(Direccion direccion) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DireccionFormScreen(
          cocheId: widget.cocheId,
          direccion: direccion,
        ),
      ),
    );
    if (result == true) {
      _cargarCoche();
    }
  }

  Future<void> _eliminarLugar(Direccion direccion) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar "${direccion.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _direccionService.eliminarDireccion(direccion.id!);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lugar eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _cargarCoche();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar el lugar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildMejorasTab(Coche coche) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _agregarMejora(coche),
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva Idea de Mejora'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Mejora>>(
            future: _mejoraService.getMejoras(coche.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final mejoras = snapshot.data ?? [];

              if (mejoras.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay ideas de mejoras',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: mejoras.length,
                itemBuilder: (context, index) {
                  final mejora = mejoras[index];
                  return _buildMejoraCard(mejora);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMejoraCard(Mejora mejora) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _verDetalleMejora(mejora),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: mejora.imagenPath != null
                  ? Image.file(
                      File(mejora.imagenPath!),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.lightbulb_outline,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mejora.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (mejora.linkCompra != null)
                    const SizedBox(height: 4),
                  if (mejora.linkCompra != null)
                    Row(
                      children: [
                        Icon(Icons.link, size: 14, color: Colors.blue[700]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Link disponible',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verDetalleMejora(Mejora mejora) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mejora.imagenPath != null)
                Image.file(
                  File(mejora.imagenPath!),
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mejora.nombre,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (mejora.linkCompra != null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _abrirLink(mejora.linkCompra!),
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Ver donde comprar'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                    if (mejora.notas != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Notas:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(mejora.notas!),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _eliminarMejora(mejora);
                          },
                          child: const Text('Eliminar'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _editarMejora(mejora);
                          },
                          child: const Text('Editar'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirLink(String url) async {
    try {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el link')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir link: $e')),
        );
      }
    }
  }

  Future<void> _agregarMejora(Coche coche) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MejoraFormScreen(cocheId: coche.id!),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _editarMejora(Mejora mejora) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MejoraFormScreen(
          cocheId: widget.cocheId,
          mejora: mejora,
        ),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _eliminarMejora(Mejora mejora) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar "${mejora.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _mejoraService.eliminarMejora(mejora.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mejora eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Métodos para Estacionamiento
  Future<void> _registrarEstacionamiento(BuildContext context, Coche coche) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EstacionamientoFormScreen(cocheId: widget.cocheId),
      ),
    );

    if (resultado == true) {
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estacionamiento registrado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _editarEstacionamiento(
      BuildContext context, Coche coche, Estacionamiento estacionamiento) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EstacionamientoFormScreen(
          cocheId: widget.cocheId,
          estacionamiento: estacionamiento,
        ),
      ),
    );

    if (resultado == true) {
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estacionamiento actualizado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _eliminarEstacionamiento(
      BuildContext context, Estacionamiento estacionamiento) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Eliminar este registro de estacionamiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _estacionamientoService.eliminarEstacionamiento(estacionamiento.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Estacionamiento eliminado'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _verHistorialEstacionamientos(BuildContext context, Coche coche) async {
    final historial = await _estacionamientoService.getHistorialEstacionamientos(widget.cocheId);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Historial de Estacionamientos'),
        content: SizedBox(
          width: double.maxFinite,
          child: historial.isEmpty
              ? const Text('No hay historial de estacionamientos')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: historial.length,
                  itemBuilder: (context, index) {
                    final est = historial[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.local_parking),
                        title: Text(est.direccion ?? 'Ubicación GPS'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(est.fechaCreacion),
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (est.piso != null || est.numero != null)
                              Text(
                                '${est.piso ?? ''} ${est.numero ?? ''}'.trim(),
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: est.latitud != null && est.longitud != null
                            ? IconButton(
                                icon: const Icon(Icons.map),
                                onPressed: () => _abrirUbicacionEnMapa(
                                  est.latitud!,
                                  est.longitud!,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirUbicacionEnMapa(double latitud, double longitud) async {
    final url = Uri.parse('https://maps.apple.com/?q=$latitud,$longitud');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
