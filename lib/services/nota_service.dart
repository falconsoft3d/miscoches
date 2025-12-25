import '../models/nota.dart';
import 'database_helper.dart';

class NotaService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Obtener todas las notas de un coche
  Future<List<Nota>> getNotas(int cocheId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notas',
      where: 'cocheId = ?',
      whereArgs: [cocheId],
      orderBy: 'fechaCreacion DESC',
    );
    return List.generate(maps.length, (i) => Nota.fromMap(maps[i]));
  }

  // Obtener una nota por ID
  Future<Nota?> getNota(int id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'notas',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Nota.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error obteniendo nota: $e');
      return null;
    }
  }

  // Crear una nueva nota
  Future<int?> crearNota(Nota nota) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert('notas', nota.toMap());
    } catch (e) {
      print('Error creando nota: $e');
      return null;
    }
  }

  // Actualizar una nota
  Future<bool> actualizarNota(int id, Nota nota) async {
    try {
      final db = await _dbHelper.database;
      final notaActualizada = nota.copyWith(id: id);
      await db.update(
        'notas',
        notaActualizada.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Error actualizando nota: $e');
      return false;
    }
  }

  // Eliminar una nota
  Future<bool> eliminarNota(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'notas',
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Error eliminando nota: $e');
      return false;
    }
  }

  // Contar notas de un coche
  Future<int> contarNotas(int cocheId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notas WHERE cocheId = ?',
        [cocheId],
      );
      return result.first['count'] as int;
    } catch (e) {
      print('Error contando notas: $e');
      return 0;
    }
  }
}
