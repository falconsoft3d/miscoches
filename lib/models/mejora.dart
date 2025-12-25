class Mejora {
  final int? id;
  final int cocheId;
  final String nombre;
  final String? imagenPath;
  final String? linkCompra;
  final String? notas;
  final DateTime fechaCreacion;

  Mejora({
    this.id,
    required this.cocheId,
    required this.nombre,
    this.imagenPath,
    this.linkCompra,
    this.notas,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cocheId': cocheId,
      'nombre': nombre,
      'imagenPath': imagenPath,
      'linkCompra': linkCompra,
      'notas': notas,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Mejora.fromMap(Map<String, dynamic> map) {
    return Mejora(
      id: map['id'] as int?,
      cocheId: map['cocheId'] as int,
      nombre: map['nombre'] as String,
      imagenPath: map['imagenPath'] as String?,
      linkCompra: map['linkCompra'] as String?,
      notas: map['notas'] as String?,
      fechaCreacion: DateTime.parse(map['fechaCreacion'] as String),
    );
  }

  Mejora copyWith({
    int? id,
    int? cocheId,
    String? nombre,
    String? imagenPath,
    String? linkCompra,
    String? notas,
    DateTime? fechaCreacion,
  }) {
    return Mejora(
      id: id ?? this.id,
      cocheId: cocheId ?? this.cocheId,
      nombre: nombre ?? this.nombre,
      imagenPath: imagenPath ?? this.imagenPath,
      linkCompra: linkCompra ?? this.linkCompra,
      notas: notas ?? this.notas,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}
