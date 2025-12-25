class Tarea {
  final int? id;
  final int cocheId;
  final String titulo;
  final String? descripcion;
  final bool completada;
  final DateTime? fechaLimite;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;

  Tarea({
    this.id,
    required this.cocheId,
    required this.titulo,
    this.descripcion,
    this.completada = false,
    this.fechaLimite,
    DateTime? fechaCreacion,
    this.fechaActualizacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cocheId': cocheId,
      'titulo': titulo,
      'descripcion': descripcion,
      'completada': completada ? 1 : 0,
      'fechaLimite': fechaLimite?.toIso8601String(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  // Crear desde Map de SQLite
  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: map['id'] as int?,
      cocheId: map['cocheId'] as int,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String?,
      completada: (map['completada'] as int) == 1,
      fechaLimite: map['fechaLimite'] != null
          ? DateTime.parse(map['fechaLimite'] as String)
          : null,
      fechaCreacion: DateTime.parse(map['fechaCreacion'] as String),
      fechaActualizacion: map['fechaActualizacion'] != null
          ? DateTime.parse(map['fechaActualizacion'] as String)
          : null,
    );
  }

  Tarea copyWith({
    int? id,
    int? cocheId,
    String? titulo,
    String? descripcion,
    bool? completada,
    DateTime? fechaLimite,
  }) {
    return Tarea(
      id: id ?? this.id,
      cocheId: cocheId ?? this.cocheId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      completada: completada ?? this.completada,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      fechaCreacion: fechaCreacion,
      fechaActualizacion: DateTime.now(),
    );
  }
}
