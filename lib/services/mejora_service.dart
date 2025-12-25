import 'package:sqflite/sqflite.dart';
import '../models/mejora.dart';
import 'database_helper.dart';

class MejoraService {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  Future<List<Mejora>> getMejoras(int cocheId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'mejoras',
      where: 'cocheId = ?',
      whereArgs: [cocheId],
      orderBy: 'fechaCreacion DESC',
    );
    return List.generate(maps.length, (i) => Mejora.fromMap(maps[i]));
  }

  Future<Mejora?> getMejora(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'mejoras',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Mejora.fromMap(maps.first);
  }

  Future<int> crearMejora(Mejora mejora) async {
    final db = await _db;
    return await db.insert(
      'mejoras',
      mejora.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> actualizarMejora(int id, Mejora mejora) async {
    final db = await _db;
    return await db.update(
      'mejoras',
      mejora.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminarMejora(int id) async {
    final db = await _db;
    return await db.delete(
      'mejoras',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
