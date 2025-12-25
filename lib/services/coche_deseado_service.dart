import 'package:sqflite/sqflite.dart';
import '../models/coche_deseado.dart';
import 'database_helper.dart';

class CocheDeseadoService {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  Future<List<CocheDeseado>> getCochesDeseados() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'coches_deseados',
      orderBy: 'fechaCreacion DESC',
    );
    return List.generate(maps.length, (i) => CocheDeseado.fromMap(maps[i]));
  }

  Future<CocheDeseado?> getCocheDeseado(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'coches_deseados',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CocheDeseado.fromMap(maps.first);
  }

  Future<int> crearCocheDeseado(CocheDeseado coche) async {
    final db = await _db;
    return await db.insert(
      'coches_deseados',
      coche.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> actualizarCocheDeseado(int id, CocheDeseado coche) async {
    final db = await _db;
    return await db.update(
      'coches_deseados',
      coche.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminarCocheDeseado(int id) async {
    final db = await _db;
    return await db.delete(
      'coches_deseados',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
