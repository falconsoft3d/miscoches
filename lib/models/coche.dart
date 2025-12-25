class Coche {
  final int? id;
  final String marca;
  final String modelo;
  final String matricula;
  final int year;
  final String? color;
  final String? vin;
  final double? kilometraje;
  final DateTime fechaCompra;
  final String? propietario;
  final String? urlFoto;
  final List<String> imagenes; // Galería de imágenes
  final String? imagenFavorita; // Path de la imagen favorita
  final int? intervaloMantenimientoKm; // Cada cuántos km hacer mantenimiento
  final DateTime? proximoMantenimientoFecha; // Fecha del próximo mantenimiento
  final double? cuotaMensual; // Cuota mensual a pagar
  final double? totalPendiente; // Total pendiente de pago
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;

  Coche({
    this.id,
    required this.marca,
    required this.modelo,
    required this.matricula,
    required this.year,
    this.color,
    this.vin,
    this.kilometraje,
    required this.fechaCompra,
    this.propietario,
    this.urlFoto,
    List<String>? imagenes,
    this.imagenFavorita,
    this.intervaloMantenimientoKm,
    this.proximoMantenimientoFecha,
    this.cuotaMensual,
    this.totalPendiente,
    DateTime? fechaCreacion,
    this.fechaActualizacion,
  }) : imagenes = imagenes ?? [],
       fechaCreacion = fechaCreacion ?? DateTime.now();

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marca': marca,
      'modelo': modelo,
      'matricula': matricula,
      'year': year,
      'color': color,
      'vin': vin,
      'kilometraje': kilometraje,
      'fechaCompra': fechaCompra.toIso8601String(),
      'propietario': propietario,
      'urlFoto': urlFoto,
      'imagenes': imagenes.join(','), // Guardar como CSV
      'imagenFavorita': imagenFavorita,
      'intervaloMantenimientoKm': intervaloMantenimientoKm,
      'proximoMantenimientoFecha': proximoMantenimientoFecha?.toIso8601String(),
      'cuotaMensual': cuotaMensual,
      'totalPendiente': totalPendiente,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  // Crear desde Map de SQLite
  factory Coche.fromMap(Map<String, dynamic> map) {
    final imagenesStr = map['imagenes'] as String?;
    return Coche(
      id: map['id'] as int?,
      marca: map['marca'] as String,
      modelo: map['modelo'] as String,
      matricula: map['matricula'] as String,
      year: map['year'] as int,
      color: map['color'] as String?,
      vin: map['vin'] as String?,
      kilometraje: map['kilometraje'] as double?,
      fechaCompra: DateTime.parse(map['fechaCompra'] as String),
      propietario: map['propietario'] as String?,
      urlFoto: map['urlFoto'] as String?,
      imagenes: imagenesStr != null && imagenesStr.isNotEmpty 
          ? imagenesStr.split(',') 
          : [],
      imagenFavorita: map['imagenFavorita'] as String?,
      intervaloMantenimientoKm: map['intervaloMantenimientoKm'] as int?,
      proximoMantenimientoFecha: map['proximoMantenimientoFecha'] != null
          ? DateTime.parse(map['proximoMantenimientoFecha'] as String)
          : null,
      cuotaMensual: map['cuotaMensual'] as double?,
      totalPendiente: map['totalPendiente'] as double?,
      fechaCreacion: DateTime.parse(map['fechaCreacion'] as String),
      fechaActualizacion: map['fechaActualizacion'] != null 
          ? DateTime.parse(map['fechaActualizacion'] as String) 
          : null,
    );
  }

  Coche copyWith({
    int? id,
    String? marca,
    String? modelo,
    String? matricula,
    int? year,
    String? color,
    String? vin,
    double? kilometraje,
    DateTime? fechaCompra,
    String? propietario,
    String? urlFoto,
    List<String>? imagenes,
    String? imagenFavorita,
    int? intervaloMantenimientoKm,
    DateTime? proximoMantenimientoFecha,
    double? cuotaMensual,
    double? totalPendiente,
  }) {
    return Coche(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      matricula: matricula ?? this.matricula,
      year: year ?? this.year,
      color: color ?? this.color,
      vin: vin ?? this.vin,
      kilometraje: kilometraje ?? this.kilometraje,
      fechaCompra: fechaCompra ?? this.fechaCompra,
      propietario: propietario ?? this.propietario,
      urlFoto: urlFoto ?? this.urlFoto,
      imagenes: imagenes ?? this.imagenes,
      imagenFavorita: imagenFavorita ?? this.imagenFavorita,
      intervaloMantenimientoKm: intervaloMantenimientoKm ?? this.intervaloMantenimientoKm,
      proximoMantenimientoFecha: proximoMantenimientoFecha ?? this.proximoMantenimientoFecha,
      cuotaMensual: cuotaMensual ?? this.cuotaMensual,
      totalPendiente: totalPendiente ?? this.totalPendiente,
      fechaCreacion: fechaCreacion,
      fechaActualizacion: DateTime.now(),
    );
  }
}
