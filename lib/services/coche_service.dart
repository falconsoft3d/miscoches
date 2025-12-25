import '../models/coche.dart';
import 'database_helper.dart';

class CocheService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Obtener todos los coches
  Future<List<Coche>> getCoches() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'coches',
      orderBy: 'fechaCreacion DESC',
    );
    return List.generate(maps.length, (i) => Coche.fromMap(maps[i]));
  }

  // Obtener un coche por ID
  Future<Coche?> getCoche(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'coches',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Coche.fromMap(maps.first);
    }
    return null;
  }

  // Crear un nuevo coche
  Future<int?> crearCoche(Coche coche) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert('coches', coche.toMap());
    } catch (e) {
      print('Error creando coche: $e');
      return null;
    }
  }

  // Actualizar un coche
  Future<bool> actualizarCoche(int id, Coche coche) async {
    try {
      final db = await _dbHelper.database;
      final cocheActualizado = coche.copyWith(id: id);
      await db.update(
        'coches',
        cocheActualizado.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Error actualizando coche: $e');
      return false;
    }
  }

  // Actualizar kilometraje
  Future<bool> actualizarKilometraje(int id, double kilometraje) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'coches',
        {
          'kilometraje': kilometraje,
          'fechaActualizacion': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Error actualizando kilometraje: $e');
      return false;
    }
  }

  // Eliminar un coche
  Future<bool> eliminarCoche(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'coches',
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Error eliminando coche: $e');
      return false;
    }
  }

  // Buscar coches por matrícula
  Future<List<Coche>> buscarPorMatricula(String matricula) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'coches',
        where: 'matricula = ?',
        whereArgs: [matricula],
      );
      return List.generate(maps.length, (i) => Coche.fromMap(maps[i]));
    } catch (e) {
      print('Error buscando coche por matrícula: $e');
      return [];
    }
  }
}
