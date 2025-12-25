import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('miscoches.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 10, // Incrementar versión para campos de cuota mensual y total pendiente
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar columnas para galería de imágenes
      await db.execute('ALTER TABLE coches ADD COLUMN imagenes TEXT');
      await db.execute('ALTER TABLE coches ADD COLUMN imagenFavorita TEXT');
    }
    if (oldVersion < 3) {
      // Agregar columnas para configuración de mantenimiento
      await db.execute('ALTER TABLE coches ADD COLUMN intervaloMantenimientoKm INTEGER');
      await db.execute('ALTER TABLE coches ADD COLUMN proximoMantenimientoFecha TEXT');
    }
    if (oldVersion < 4) {
      // Crear tabla de notas
      await db.execute('''
        CREATE TABLE notas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cocheId INTEGER NOT NULL,
          titulo TEXT NOT NULL,
          contenido TEXT NOT NULL,
          fechaCreacion TEXT NOT NULL,
          fechaActualizacion TEXT,
          FOREIGN KEY (cocheId) REFERENCES coches (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 5) {
      // Crear tabla de tareas
      await db.execute('''
        CREATE TABLE tareas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cocheId INTEGER NOT NULL,
          titulo TEXT NOT NULL,
          descripcion TEXT,
          completada INTEGER NOT NULL DEFAULT 0,
          fechaLimite TEXT,
          fechaCreacion TEXT NOT NULL,
          fechaActualizacion TEXT,
          FOREIGN KEY (cocheId) REFERENCES coches (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 6) {
      // Crear tabla de direcciones
      await db.execute('''
        CREATE TABLE direcciones (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cocheId INTEGER NOT NULL,
          nombre TEXT NOT NULL,
          direccion TEXT NOT NULL,
          latitud REAL,
          longitud REAL,
          tipo TEXT,
          telefono TEXT,
          notas TEXT,
          fechaCreacion TEXT NOT NULL,
          FOREIGN KEY (cocheId) REFERENCES coches (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 7) {
      // Crear tabla de mejoras
      await db.execute('''
        CREATE TABLE mejoras (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cocheId INTEGER NOT NULL,
          nombre TEXT NOT NULL,
          imagenPath TEXT,
          linkCompra TEXT,
          notas TEXT,
          fechaCreacion TEXT NOT NULL,
          FOREIGN KEY (cocheId) REFERENCES coches (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 8) {
      // Crear tabla de coches deseados
      await db.execute('''
        CREATE TABLE coches_deseados (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          marca TEXT NOT NULL,
          modelo TEXT NOT NULL,
          anio INTEGER,
          imagenes TEXT,
          imagenFavorita TEXT,
          dondeLoVi TEXT,
          notas TEXT,
          fechaCreacion TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 9) {
      // Crear tabla de estacionamientos
      await db.execute('''
        CREATE TABLE estacionamientos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cocheId INTEGER NOT NULL,
          latitud REAL,
          longitud REAL,
          direccion TEXT,
          piso TEXT,
          numero TEXT,
          notas TEXT,
          fechaCreacion TEXT NOT NULL,
          FOREIGN KEY (cocheId) REFERENCES coches (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 10) {
      // Agregar columnas para cuota mensual y total pendiente
      await db.execute('ALTER TABLE coches ADD COLUMN cuotaMensual REAL');
      await db.execute('ALTER TABLE coches ADD COLUMN totalPendiente REAL');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL';
    const textTypeNullable = 'TEXT';
    const realTypeNullable = 'REAL';

    // Tabla de coches
    await db.execute('''
      CREATE TABLE coches (
        id $idType,
        marca $textType,
        modelo $textType,
        matricula $textType,
        year $integerType,
        color $textTypeNullable,
        vin $textTypeNullable,
        kilometraje $realTypeNullable,
        fechaCompra $textType,
        propietario $textTypeNullable,
        urlFoto $textTypeNullable,
        imagenes $textTypeNullable,
        imagenFavorita $textTypeNullable,
        intervaloMantenimientoKm INTEGER,
        proximoMantenimientoFecha $textTypeNullable,
        cuotaMensual $realTypeNullable,
        totalPendiente $realTypeNullable,
        fechaCreacion $textType,
        fechaActualizacion $textTypeNullable
      )
    ''');

    // Tabla de mantenimientos
    await db.execute('''
      CREATE TABLE mantenimientos (
        id $idType,
        cocheId $integerType,
        tipo $textType,
        descripcion $textTypeNullable,
        fecha $textType,
        kilometraje $realType,
        costo $realTypeNullable,
        taller $textTypeNullable,
        proximoMantenimiento $textTypeNullable,
        proximoKilometraje $realTypeNullable,
        notas $textTypeNullable,
        fechaCreacion $textType,
        FOREIGN KEY (cocheId) REFERENCES coches (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de repostajes
    await db.execute('''
      CREATE TABLE repostajes (
        id $idType,
        cocheId $integerType,
        fecha $textType,
        kilometraje $realType,
        litros $realType,
        costoTotal $realType,
        precioPorLitro $realTypeNullable,
        tipoCombustible $textType,
        gasolinera $textTypeNullable,
        tanqueLleno INTEGER NOT NULL DEFAULT 0,
        notas $textTypeNullable,
        fechaCreacion $textType,
        FOREIGN KEY (cocheId) REFERENCES coches (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de notas
    await db.execute('''
      CREATE TABLE notas (
        id $idType,
        cocheId $integerType,
        titulo $textType,
        contenido $textType,
        fechaCreacion $textType,
        fechaActualizacion $textTypeNullable,
        FOREIGN KEY (cocheId) REFERENCES coches (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de tareas
    await db.execute('''
      CREATE TABLE tareas (
        id $idType,
        cocheId $integerType,
        titulo $textType,
        descripcion $textTypeNullable,
        completada INTEGER NOT NULL DEFAULT 0,
        fechaLimite $textTypeNullable,
        fechaCreacion $textType,
        fechaActualizacion $textTypeNullable,
        FOREIGN KEY (cocheId) REFERENCES coches (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de direcciones
    await db.execute('''
      CREATE TABLE direcciones (
        id $idType,
        cocheId $integerType,
        nombre $textType,
        direccion $textType,
        latitud $realTypeNullable,
        longitud $realTypeNullable,
        tipo $textTypeNullable,
        telefono $textTypeNullable,
        notas $textTypeNullable,
        fechaCreacion $textType,
        FOREIGN KEY (cocheId) REFERENCES coches (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de mejoras
    await db.execute('''
      CREATE TABLE mejoras (
        id $idType,
        cocheId $integerType,
        nombre $textType,
        imagenPath $textTypeNullable,
        linkCompra $textTypeNullable,
        notas $textTypeNullable,
        fechaCreacion $textType,
        FOREIGN KEY (cocheId) REFERENCES coches (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de coches deseados
    await db.execute('''
      CREATE TABLE coches_deseados (
        id $idType,
        marca $textType,
        modelo $textType,
        anio INTEGER,
        imagenes $textTypeNullable,
        imagenFavorita $textTypeNullable,
        dondeLoVi $textTypeNullable,
        notas $textTypeNullable,
        fechaCreacion $textType
      )
    ''');

    // Tabla de estacionamientos
    await db.execute('''
      CREATE TABLE estacionamientos (
        id $idType,
        cocheId $integerType,
        latitud $realTypeNullable,
        longitud $realTypeNullable,
        direccion $textTypeNullable,
        piso $textTypeNullable,
        numero $textTypeNullable,
        notas $textTypeNullable,
        fechaCreacion $textType,
        FOREIGN KEY (cocheId) REFERENCES coches (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
