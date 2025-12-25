import '../models/repostaje.dart';
import 'database_helper.dart';
import 'coche_service.dart';

class RepostajeService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final CocheService _cocheService = CocheService();

  // Obtener todos los repostajes de un coche
  Future<List<Repostaje>> getRepostajes(int cocheId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'repostajes',
      where: 'cocheId = ?',
      whereArgs: [cocheId],
      orderBy: 'fecha DESC',
    );
    return List.generate(maps.length, (i) => Repostaje.fromMap(maps[i]));
  }

  // Obtener un repostaje por ID
  Future<Repostaje?> getRepostaje(int id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'repostajes',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Repostaje.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error obteniendo repostaje: $e');
      return null;
    }
  }

  // Crear un nuevo repostaje
  Future<int?> crearRepostaje(Repostaje repostaje) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.insert('repostajes', repostaje.toMap());
      
      // Actualizar el kilometraje del coche automáticamente
      await _cocheService.actualizarKilometraje(
        repostaje.cocheId, 
        repostaje.kilometraje,
      );
      
      return result;
    } catch (e) {
      print('Error creando repostaje: $e');
      return null;
    }
  }

  // Actualizar un repostaje
  Future<bool> actualizarRepostaje(int id, Repostaje repostaje) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'repostajes',
        repostaje.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Error actualizando repostaje: $e');
      return false;
    }
  }

  // Eliminar un repostaje
  Future<bool> eliminarRepostaje(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'repostajes',
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Error eliminando repostaje: $e');
      return false;
    }
  }

  // Calcular consumo medio
  Future<double> getConsumoMedio(int cocheId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'repostajes',
        where: 'cocheId = ? AND tanqueLleno = 1',
        whereArgs: [cocheId],
        orderBy: 'fecha ASC',
      );

      if (maps.length < 2) {
        return 0.0;
      }

      double totalLitros = 0.0;
      double totalKm = 0.0;

      for (int i = 1; i < maps.length; i++) {
        Repostaje actual = Repostaje.fromMap(maps[i]);
        Repostaje anterior = Repostaje.fromMap(maps[i - 1]);
        
        double kmRecorridos = actual.kilometraje - anterior.kilometraje;
        if (kmRecorridos > 0) {
          totalLitros += actual.litros;
          totalKm += kmRecorridos;
        }
      }

      if (totalKm > 0) {
        return (totalLitros / totalKm) * 100; // L/100km
      }
      return 0.0;
    } catch (e) {
      print('Error calculando consumo medio: $e');
      return 0.0;
    }
  }

  // Obtener costo total en combustible
  Future<double> getCostoTotal(int cocheId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(costoTotal) as total FROM repostajes WHERE cocheId = ?',
        [cocheId],
      );
      return result.first['total'] as double? ?? 0.0;
    } catch (e) {
      print('Error calculando costo total: $e');
      return 0.0;
    }
  }

  // Obtener últimos N repostajes
  Future<List<Repostaje>> getUltimosRepostajes(int cocheId, int limite) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'repostajes',
        where: 'cocheId = ?',
        whereArgs: [cocheId],
        orderBy: 'fecha DESC',
        limit: limite,
      );
      return List.generate(maps.length, (i) => Repostaje.fromMap(maps[i]));
    } catch (e) {
      print('Error obteniendo últimos repostajes: $e');
      return [];
    }
  }

  // Obtener estadísticas de repostajes
  Future<Map<String, dynamic>> getEstadisticas(int cocheId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'repostajes',
        where: 'cocheId = ?',
        whereArgs: [cocheId],
        orderBy: 'fecha ASC',
      );

      if (maps.isEmpty) {
        return {
          'totalRepostajes': 0,
          'totalLitros': 0.0,
          'totalCosto': 0.0,
          'precioMedio': 0.0,
          'consumoMedio': 0.0,
        };
      }

      double totalLitros = 0.0;
      double totalCosto = 0.0;
      int count = maps.length;

      for (var map in maps) {
        Repostaje repostaje = Repostaje.fromMap(map);
        totalLitros += repostaje.litros;
        totalCosto += repostaje.costoTotal;
      }

      double precioMedio = totalCosto / totalLitros;
      double consumoMedio = await getConsumoMedio(cocheId);

      return {
        'totalRepostajes': count,
        'totalLitros': totalLitros,
        'totalCosto': totalCosto,
        'precioMedio': precioMedio,
        'consumoMedio': consumoMedio,
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {
        'totalRepostajes': 0,
        'totalLitros': 0.0,
        'totalCosto': 0.0,
        'precioMedio': 0.0,
        'consumoMedio': 0.0,
      };
    }
  }
}
