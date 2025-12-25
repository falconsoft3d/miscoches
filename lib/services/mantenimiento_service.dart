import '../models/mantenimiento.dart';
import 'database_helper.dart';

class MantenimientoService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Obtener todos los mantenimientos de un coche
  Future<List<Mantenimiento>> getMantenimientos(int cocheId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mantenimientos',
      where: 'cocheId = ?',
      whereArgs: [cocheId],
      orderBy: 'fecha DESC',
    );
    return List.generate(maps.length, (i) => Mantenimiento.fromMap(maps[i]));
  }

  // Obtener un mantenimiento por ID
  Future<Mantenimiento?> getMantenimiento(int id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'mantenimientos',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Mantenimiento.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error obteniendo mantenimiento: $e');
      return null;
    }
  }

  // Crear un nuevo mantenimiento
  Future<int?> crearMantenimiento(Mantenimiento mantenimiento) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert('mantenimientos', mantenimiento.toMap());
    } catch (e) {
      print('Error creando mantenimiento: $e');
      return null;
    }
  }

  // Actualizar un mantenimiento
  Future<bool> actualizarMantenimiento(int id, Mantenimiento mantenimiento) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'mantenimientos',
        mantenimiento.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Error actualizando mantenimiento: $e');
      return false;
    }
  }

  // Eliminar un mantenimiento
  Future<bool> eliminarMantenimiento(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'mantenimientos',
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Error eliminando mantenimiento: $e');
      return false;
    }
  }

  // Obtener mantenimientos próximos
  Future<List<Mantenimiento>> getMantenimientosProximos(int cocheId) async {
    try {
      final db = await _dbHelper.database;
      final ahora = DateTime.now().toIso8601String();
      final List<Map<String, dynamic>> maps = await db.query(
        'mantenimientos',
        where: 'cocheId = ? AND proximoMantenimiento >= ?',
        whereArgs: [cocheId, ahora],
        orderBy: 'proximoMantenimiento ASC',
        limit: 5,
      );
      return List.generate(maps.length, (i) => Mantenimiento.fromMap(maps[i]));
    } catch (e) {
      print('Error obteniendo mantenimientos próximos: $e');
      return [];
    }
  }

  // Obtener costo total de mantenimientos de un coche
  Future<double> getCostoTotal(int cocheId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(costo) as total FROM mantenimientos WHERE cocheId = ?',
        [cocheId],
      );
      return result.first['total'] as double? ?? 0.0;
    } catch (e) {
      print('Error calculando costo total: $e');
      return 0.0;
    }
  }

  // Obtener mantenimientos por tipo
  Future<List<Mantenimiento>> getMantenimientosPorTipo(
      int cocheId, TipoMantenimiento tipo) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mantenimientos',
      where: 'cocheId = ? AND tipo = ?',
      whereArgs: [cocheId, tipo.name],
      orderBy: 'fecha DESC',
    );
    return List.generate(maps.length, (i) => Mantenimiento.fromMap(maps[i]));
  }
}
