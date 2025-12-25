import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/repostaje.dart';
import '../services/repostaje_service.dart';

class KpiScreen extends StatefulWidget {
  final int cocheId;

  const KpiScreen({super.key, required this.cocheId});

  @override
  State<KpiScreen> createState() => _KpiScreenState();
}

class _KpiScreenState extends State<KpiScreen> {
  final RepostajeService _repostajeService = RepostajeService();
  List<Repostaje> _repostajes = [];
  bool _isLoading = true;

  double _kmPorSemana = 0;
  double _kmPorMes = 0;
  double _kmPorAnio = 0;

  @override
  void initState() {
    super.initState();
    _cargarKPIs();
  }

  Future<void> _cargarKPIs() async {
    setState(() => _isLoading = true);

    try {
      _repostajes = await _repostajeService.getRepostajes(widget.cocheId);
      _repostajes.sort((a, b) => a.fecha.compareTo(b.fecha));

      if (_repostajes.length >= 2) {
        _calcularKPIs();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _calcularKPIs() {
    final ahora = DateTime.now();
    
    // KM por semana (últimos 7 días)
    final haceSemana = ahora.subtract(const Duration(days: 7));
    final repostajesSemana = _repostajes.where((r) => r.fecha.isAfter(haceSemana)).toList();
    
    if (repostajesSemana.length >= 2) {
      repostajesSemana.sort((a, b) => a.fecha.compareTo(b.fecha));
      final kmInicial = repostajesSemana.first.kilometraje;
      final kmFinal = repostajesSemana.last.kilometraje;
      final dias = repostajesSemana.last.fecha.difference(repostajesSemana.first.fecha).inDays;
      
      if (dias > 0) {
        _kmPorSemana = ((kmFinal - kmInicial) / dias) * 7;
      }
    }

    // KM por mes (últimos 30 días)
    final haceMes = ahora.subtract(const Duration(days: 30));
    final repostajesMes = _repostajes.where((r) => r.fecha.isAfter(haceMes)).toList();
    
    if (repostajesMes.length >= 2) {
      repostajesMes.sort((a, b) => a.fecha.compareTo(b.fecha));
      final kmInicial = repostajesMes.first.kilometraje;
      final kmFinal = repostajesMes.last.kilometraje;
      final dias = repostajesMes.last.fecha.difference(repostajesMes.first.fecha).inDays;
      
      if (dias > 0) {
        _kmPorMes = ((kmFinal - kmInicial) / dias) * 30;
      }
    }

    // KM por año (últimos 365 días)
    final haceAnio = ahora.subtract(const Duration(days: 365));
    final repostajesAnio = _repostajes.where((r) => r.fecha.isAfter(haceAnio)).toList();
    
    if (repostajesAnio.length >= 2) {
      repostajesAnio.sort((a, b) => a.fecha.compareTo(b.fecha));
      final kmInicial = repostajesAnio.first.kilometraje;
      final kmFinal = repostajesAnio.last.kilometraje;
      final dias = repostajesAnio.last.fecha.difference(repostajesAnio.first.fecha).inDays;
      
      if (dias > 0) {
        _kmPorAnio = ((kmFinal - kmInicial) / dias) * 365;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_repostajes.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Necesitas al menos 2 repostajes para ver estadísticas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarKPIs,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildKpiCard(
            'Kilómetros por Semana',
            _kmPorSemana,
            Icons.calendar_view_week,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildKpiCard(
            'Kilómetros por Mes',
            _kmPorMes,
            Icons.calendar_month,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildKpiCard(
            'Kilómetros por Año',
            _kmPorAnio,
            Icons.calendar_today,
            Colors.orange,
          ),
          const SizedBox(height: 24),
          _buildResumenCard(),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String titulo, double valor, IconData icono, Color color) {
    final formatoNumero = NumberFormat('#,##0', 'es_ES');
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icono,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${formatoNumero.format(valor)} km',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenCard() {
    if (_repostajes.isEmpty) {
      return const SizedBox.shrink();
    }

    final kmTotal = _repostajes.isNotEmpty 
        ? _repostajes.last.kilometraje - _repostajes.first.kilometraje
        : 0.0;
    
    final dias = _repostajes.isNotEmpty 
        ? _repostajes.last.fecha.difference(_repostajes.first.fecha).inDays
        : 0;

    final formatoFecha = DateFormat('dd/MM/yyyy');
    final formatoNumero = NumberFormat('#,##0', 'es_ES');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Resumen General',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildResumenItem(
              'Total de repostajes',
              '${_repostajes.length}',
            ),
            const SizedBox(height: 12),
            _buildResumenItem(
              'Kilómetros recorridos',
              '${formatoNumero.format(kmTotal)} km',
            ),
            const SizedBox(height: 12),
            _buildResumenItem(
              'Período analizado',
              '$dias días',
            ),
            const SizedBox(height: 12),
            _buildResumenItem(
              'Primer registro',
              formatoFecha.format(_repostajes.first.fecha),
            ),
            const SizedBox(height: 12),
            _buildResumenItem(
              'Último registro',
              formatoFecha.format(_repostajes.last.fecha),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenItem(String label, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
