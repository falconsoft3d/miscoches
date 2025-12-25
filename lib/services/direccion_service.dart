import '../models/direccion.dart';
import 'database_helper.dart';

class DireccionService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Direccion>> getDirecciones(int cocheId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'direcciones',
      where: 'cocheId = ?',
      whereArgs: [cocheId],
      orderBy: 'fechaCreacion DESC',
    );
    return List.generate(maps.length, (i) => Direccion.fromMap(maps[i]));
  }

  Future<Direccion?> getDireccion(int id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'direcciones',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Direccion.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error obteniendo dirección: $e');
      return null;
    }
  }

  Future<int?> crearDireccion(Direccion direccion) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert('direcciones', direccion.toMap());
    } catch (e) {
      print('Error creando dirección: $e');
      return null;
    }
  }

  Future<bool> actualizarDireccion(int id, Direccion direccion) async {
    try {
      final db = await _dbHelper.database;
      final direccionActualizada = direccion.copyWith(id: id);
      await db.update(
        'direcciones',
        direccionActualizada.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Error actualizando dirección: $e');
      return false;
    }
  }

  Future<bool> eliminarDireccion(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'direcciones',
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Error eliminando dirección: $e');
      return false;
    }
  }

  Future<List<Direccion>> getDireccionesPorTipo(int cocheId, String tipo) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'direcciones',
      where: 'cocheId = ? AND tipo = ?',
      whereArgs: [cocheId, tipo],
      orderBy: 'fechaCreacion DESC',
    );
    return List.generate(maps.length, (i) => Direccion.fromMap(maps[i]));
  }
}
