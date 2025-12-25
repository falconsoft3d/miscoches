import '../models/tarea.dart';
import 'database_helper.dart';

class TareaService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Obtener todas las tareas de un coche
  Future<List<Tarea>> getTareas(int cocheId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tareas',
      where: 'cocheId = ?',
      whereArgs: [cocheId],
      orderBy: 'completada ASC, fechaLimite ASC, fechaCreacion DESC',
    );
    return List.generate(maps.length, (i) => Tarea.fromMap(maps[i]));
  }

  // Obtener una tarea por ID
  Future<Tarea?> getTarea(int id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tareas',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Tarea.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error obteniendo tarea: $e');
      return null;
    }
  }

  // Crear una nueva tarea
  Future<int?> crearTarea(Tarea tarea) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert('tareas', tarea.toMap());
    } catch (e) {
      print('Error creando tarea: $e');
      return null;
    }
  }

  // Actualizar una tarea
  Future<bool> actualizarTarea(int id, Tarea tarea) async {
    try {
      final db = await _dbHelper.database;
      final tareaActualizada = tarea.copyWith(id: id);
      await db.update(
        'tareas',
        tareaActualizada.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Error actualizando tarea: $e');
      return false;
    }
  }

  // Marcar/desmarcar tarea como completada
  Future<bool> toggleCompletada(int id, bool completada) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'tareas',
        {
          'completada': completada ? 1 : 0,
          'fechaActualizacion': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Error actualizando estado de tarea: $e');
      return false;
    }
  }

  // Eliminar una tarea
  Future<bool> eliminarTarea(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'tareas',
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Error eliminando tarea: $e');
      return false;
    }
  }

  // Contar tareas pendientes de un coche
  Future<int> contarTareasPendientes(int cocheId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tareas WHERE cocheId = ? AND completada = 0',
        [cocheId],
      );
      return result.first['count'] as int;
    } catch (e) {
      print('Error contando tareas pendientes: $e');
      return 0;
    }
  }

  // Obtener tareas pendientes de un coche
  Future<List<Tarea>> getTareasPendientes(int cocheId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tareas',
        where: 'cocheId = ? AND completada = 0',
        whereArgs: [cocheId],
        orderBy: 'fechaLimite ASC',
      );
      return List.generate(maps.length, (i) => Tarea.fromMap(maps[i]));
    } catch (e) {
      print('Error obteniendo tareas pendientes: $e');
      return [];
    }
  }

  // Obtener tareas completadas de un coche
  Future<List<Tarea>> getTareasCompletadas(int cocheId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tareas',
        where: 'cocheId = ? AND completada = 1',
        whereArgs: [cocheId],
        orderBy: 'fechaCreacion DESC',
      );
      return List.generate(maps.length, (i) => Tarea.fromMap(maps[i]));
    } catch (e) {
      print('Error obteniendo tareas completadas: $e');
      return [];
    }
  }
}
