import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/coche_deseado.dart';
import '../services/coche_deseado_service.dart';
import 'coche_deseado_form_screen.dart';

class CochesDeseadosScreen extends StatefulWidget {
  const CochesDeseadosScreen({super.key});

  @override
  State<CochesDeseadosScreen> createState() => _CochesDeseadosScreenState();
}

class _CochesDeseadosScreenState extends State<CochesDeseadosScreen> {
  final CocheDeseadoService _cocheService = CocheDeseadoService();
  List<CocheDeseado> _coches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCoches();
  }

  Future<void> _cargarCoches() async {
    setState(() => _isLoading = true);
    _coches = await _cocheService.getCochesDeseados();
    setState(() => _isLoading = false);
  }

  Future<void> _agregarCoche() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CocheDeseadoFormScreen(),
      ),
    );
    if (result == true) {
      _cargarCoches();
    }
  }

  Future<void> _editarCoche(CocheDeseado coche) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CocheDeseadoFormScreen(coche: coche),
      ),
    );
    if (result == true) {
      _cargarCoches();
    }
  }

  Future<void> _eliminarCoche(CocheDeseado coche) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Estás seguro de que deseas eliminar "${coche.marca} ${coche.modelo}"?'),
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
      await _cocheService.eliminarCocheDeseado(coche.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coche eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarCoches();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coches que me Gustan'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _coches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 100,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay coches deseados',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _agregarCoche,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Primer Coche'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarCoches,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _coches.length,
                    itemBuilder: (context, index) {
                      final coche = _coches[index];
                      return _buildCocheCard(coche);
                    },
                  ),
                ),
      floatingActionButton: _coches.isNotEmpty
          ? FloatingActionButton(
              onPressed: _agregarCoche,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildCocheCard(CocheDeseado coche) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _verDetalle(coche),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (coche.imagenFavorita != null)
              Image.file(
                File(coche.imagenFavorita!),
                width: double.infinity,
                height: 200,
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
              )
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${coche.marca} ${coche.modelo}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (coche.anio != null)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text('Año ${coche.anio}'),
                      ],
                    ),
                  if (coche.dondeLoVi != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(coche.dondeLoVi!)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Agregado: ${dateFormat.format(coche.fechaCreacion)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _editarCoche(coche),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Editar'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _eliminarCoche(coche),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Eliminar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
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

  void _verDetalle(CocheDeseado coche) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (coche.imagenes.isNotEmpty)
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    itemCount: coche.imagenes.length,
                    itemBuilder: (context, index) {
                      return Image.file(
                        File(coche.imagenes[index]),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${coche.marca} ${coche.modelo}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (coche.anio != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Año ${coche.anio}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                    if (coche.dondeLoVi != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Dónde lo vi:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(coche.dondeLoVi!),
                    ],
                    if (coche.notas != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Notas:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(coche.notas!),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
}
