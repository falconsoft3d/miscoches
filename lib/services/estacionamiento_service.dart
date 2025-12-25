import 'package:sqflite/sqflite.dart';
import '../models/estacionamiento.dart';
import 'database_helper.dart';

class EstacionamientoService {
  EstacionamientoService._privateConstructor();
  static final EstacionamientoService instance = EstacionamientoService._privateConstructor();
  
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  Future<Estacionamiento?> getEstacionamientoActual(int cocheId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'estacionamientos',
      where: 'cocheId = ?',
      whereArgs: [cocheId],
      orderBy: 'fechaCreacion DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Estacionamiento.fromMap(maps.first);
  }

  Future<List<Estacionamiento>> getHistorialEstacionamientos(int cocheId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'estacionamientos',
      where: 'cocheId = ?',
      whereArgs: [cocheId],
      orderBy: 'fechaCreacion DESC',
    );
    return List.generate(maps.length, (i) => Estacionamiento.fromMap(maps[i]));
  }

  Future<int> registrarEstacionamiento(Estacionamiento estacionamiento) async {
    final db = await _db;
    return await db.insert(
      'estacionamientos',
      estacionamiento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> actualizarEstacionamiento(int id, Estacionamiento estacionamiento) async {
    final db = await _db;
    return await db.update(
      'estacionamientos',
      estacionamiento.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminarEstacionamiento(int id) async {
    final db = await _db;
    return await db.delete(
      'estacionamientos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
