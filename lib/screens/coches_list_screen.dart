import 'dart:io';
import 'package:flutter/material.dart';
import '../models/coche.dart';
import '../services/coche_service.dart';
import '../services/tarea_service.dart';
import 'coche_detalle_screen.dart';
import 'coche_form_screen.dart';
import 'configuracion_screen.dart';
import 'coches_deseados_screen.dart';

class CochesListScreen extends StatefulWidget {
  const CochesListScreen({super.key});

  @override
  State<CochesListScreen> createState() => _CochesListScreenState();
}

class _CochesListScreenState extends State<CochesListScreen> {
  final CocheService _cocheService = CocheService();
  final TareaService _tareaService = TareaService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Coches'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CochesDeseadosScreen(),
                ),
              );
            },
            tooltip: 'Coches que me gustan',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConfiguracionScreen(),
                ),
              );
            },
            tooltip: 'Configuración',
          ),
        ],
      ),
      body: FutureBuilder<List<Coche>>(
        future: _cocheService.getCoches(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final coches = snapshot.data ?? [];

          if (coches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No tienes coches registrados',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Toca el botón + para agregar uno',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: coches.length + 1, // +1 para el resumen
              itemBuilder: (context, index) {
                // Primer elemento: resumen
                if (index == 0) {
                  return _buildResumenFinanciero(coches);
                }
                
                // Los demás elementos son los coches
                final coche = coches[index - 1];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CocheDetalleScreen(cocheId: coche.id!),
                        ),
                      );
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Mostrar imagen favorita si existe, sino mostrar icono
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: coche.imagenFavorita != null
                                ? Image.file(
                                    File(coche.imagenFavorita!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.directions_car,
                                        size: 40,
                                        color: Colors.grey[400],
                                      );
                                    },
                                  )
                                : coche.imagenes.isNotEmpty
                                    ? Image.file(
                                        File(coche.imagenes.first),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.directions_car,
                                            size: 40,
                                            color: Colors.grey[400],
                                          );
                                        },
                                      )
                                    : Icon(
                                        Icons.directions_car,
                                        size: 40,
                                        color: Colors.grey[400],
                                      ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${coche.marca} ${coche.modelo}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  coche.matricula,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (coche.kilometraje != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.speed,
                                        size: 16,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${coche.kilometraje!.toStringAsFixed(0)} km',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 8),
                                _buildEstadoMantenimiento(coche),
                                const SizedBox(height: 4),
                                _buildTareasPendientes(coche),
                                if (coche.cuotaMensual != null || coche.totalPendiente != null) ...[
                                  const SizedBox(height: 8),
                                  _buildInfoFinanciera(coche),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CocheFormScreen(),
            ),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEstadoMantenimiento(Coche coche) {
    // Calcular días hasta próximo mantenimiento por fecha
    int? diasHastaMantenimientoFecha;
    if (coche.proximoMantenimientoFecha != null) {
      diasHastaMantenimientoFecha = coche.proximoMantenimientoFecha!
          .difference(DateTime.now())
          .inDays;
    }

    // Calcular km hasta próximo mantenimiento
    double? kmHastaMantenimiento;
    if (coche.intervaloMantenimientoKm != null && coche.kilometraje != null) {
      final ultimoMantenimientoKm = (coche.kilometraje! / coche.intervaloMantenimientoKm!).floor() * coche.intervaloMantenimientoKm!;
      final proximoMantenimientoKm = ultimoMantenimientoKm + coche.intervaloMantenimientoKm!;
      kmHastaMantenimiento = proximoMantenimientoKm - coche.kilometraje!;
    }

    // Determinar estado y mostrar el más urgente
    Color backgroundColor;
    Color textColor;
    String mensaje;
    IconData icono;

    if (diasHastaMantenimientoFecha != null && diasHastaMantenimientoFecha <= 0) {
      backgroundColor = Colors.red[50]!;
      textColor = Colors.red[700]!;
      mensaje = '¡Mantenimiento vencido!';
      icono = Icons.error;
    } else if (kmHastaMantenimiento != null && kmHastaMantenimiento <= 0) {
      backgroundColor = Colors.red[50]!;
      textColor = Colors.red[700]!;
      mensaje = '¡Mantenimiento vencido!';
      icono = Icons.error;
    } else if (diasHastaMantenimientoFecha != null && diasHastaMantenimientoFecha <= 7) {
      backgroundColor = Colors.orange[50]!;
      textColor = Colors.orange[700]!;
      mensaje = 'Mantenimiento en $diasHastaMantenimientoFecha días';
      icono = Icons.warning;
    } else if (kmHastaMantenimiento != null && kmHastaMantenimiento <= 1000) {
      backgroundColor = Colors.orange[50]!;
      textColor = Colors.orange[700]!;
      mensaje = 'Mantenimiento en ${kmHastaMantenimiento.toStringAsFixed(0)} km';
      icono = Icons.warning;
    } else if (diasHastaMantenimientoFecha != null || kmHastaMantenimiento != null) {
      backgroundColor = Colors.green[50]!;
      textColor = Colors.green[700]!;
      if (diasHastaMantenimientoFecha != null && (kmHastaMantenimiento == null || diasHastaMantenimientoFecha < (kmHastaMantenimiento / 50).round())) {
        mensaje = 'OK - En $diasHastaMantenimientoFecha días';
      } else if (kmHastaMantenimiento != null) {
        mensaje = 'OK - En ${kmHastaMantenimiento.toStringAsFixed(0)} km';
      } else {
        mensaje = 'OK';
      }
      icono = Icons.check_circle;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              mensaje,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTareasPendientes(Coche coche) {
    return FutureBuilder<List<dynamic>>(
      future: _tareaService.getTareasPendientes(coche.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final tareasPendientes = snapshot.data!;
        final totalPendientes = tareasPendientes.length;

        if (totalPendientes == 0) {
          return const SizedBox.shrink();
        }

        // Contar tareas vencidas
        final tareasVencidas = tareasPendientes.where((tarea) {
          if (tarea.fechaLimite != null) {
            return tarea.fechaLimite!.isBefore(DateTime.now());
          }
          return false;
        }).length;

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final Color backgroundColor = tareasVencidas > 0 
            ? (isDark ? Colors.red.withOpacity(0.2) : Colors.red[50]!) 
            : Theme.of(context).colorScheme.surfaceContainerHighest;
        final Color textColor = tareasVencidas > 0 
            ? (isDark ? Colors.red[300]! : Colors.red[700]!) 
            : Theme.of(context).colorScheme.onSurface;
        final IconData icono = tareasVencidas > 0 
            ? Icons.warning 
            : Icons.check_box_outline_blank;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 14, color: textColor),
              const SizedBox(width: 4),
              Text(
                tareasVencidas > 0
                    ? '$totalPendientes tarea${totalPendientes > 1 ? 's' : ''} ($tareasVencidas vencida${tareasVencidas > 1 ? 's' : ''})'
                    : '$totalPendientes tarea${totalPendientes > 1 ? 's' : ''} pendiente${totalPendientes > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResumenFinanciero(List<Coche> coches) {
    double totalCuotasMensuales = 0;
    double totalPendiente = 0;
    int cochesConCuota = 0;

    for (final coche in coches) {
      if (coche.cuotaMensual != null) {
        totalCuotasMensuales += coche.cuotaMensual!;
        cochesConCuota++;
      }
      if (coche.totalPendiente != null) {
        totalPendiente += coche.totalPendiente!;
      }
    }

    // Si no hay información financiera, no mostrar el resumen
    if (cochesConCuota == 0 && totalPendiente == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Cuadro de Cuotas Mensuales
          if (totalCuotasMensuales > 0)
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cuota Mensual',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '€ ${totalCuotasMensuales.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (totalCuotasMensuales > 0 && totalPendiente > 0)
            const SizedBox(width: 12),
          // Cuadro de Total Pendiente
          if (totalPendiente > 0)
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.orange[700],
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Pendiente',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '€ ${totalPendiente.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoFinanciera(Coche coche) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (coche.cuotaMensual != null)
            Row(
              children: [
                Icon(Icons.calendar_month, size: 14, color: Theme.of(context).colorScheme.onSurface),
                const SizedBox(width: 4),
                Text(
                  'Cuota: € ${coche.cuotaMensual!.toStringAsFixed(2)}/mes',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          if (coche.cuotaMensual != null && coche.totalPendiente != null)
            const SizedBox(height: 4),
          if (coche.totalPendiente != null)
            Row(
              children: [
                Icon(Icons.attach_money, size: 14, color: Theme.of(context).colorScheme.onSurface),
                const SizedBox(width: 4),
                Text(
                  'Pendiente: € ${coche.totalPendiente!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
