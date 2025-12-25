class Nota {
  final int? id;
  final int cocheId;
  final String titulo;
  final String contenido;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;

  Nota({
    this.id,
    required this.cocheId,
    required this.titulo,
    required this.contenido,
    DateTime? fechaCreacion,
    this.fechaActualizacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cocheId': cocheId,
      'titulo': titulo,
      'contenido': contenido,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  // Crear desde Map de SQLite
  factory Nota.fromMap(Map<String, dynamic> map) {
    return Nota(
      id: map['id'] as int?,
      cocheId: map['cocheId'] as int,
      titulo: map['titulo'] as String,
      contenido: map['contenido'] as String,
      fechaCreacion: DateTime.parse(map['fechaCreacion'] as String),
      fechaActualizacion: map['fechaActualizacion'] != null
          ? DateTime.parse(map['fechaActualizacion'] as String)
          : null,
    );
  }

  Nota copyWith({
    int? id,
    int? cocheId,
    String? titulo,
    String? contenido,
  }) {
    return Nota(
      id: id ?? this.id,
      cocheId: cocheId ?? this.cocheId,
      titulo: titulo ?? this.titulo,
      contenido: contenido ?? this.contenido,
      fechaCreacion: fechaCreacion,
      fechaActualizacion: DateTime.now(),
    );
  }
}
