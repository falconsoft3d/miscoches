class CocheDeseado {
  final int? id;
  final String marca;
  final String modelo;
  final int? anio;
  final List<String> imagenes;
  final String? imagenFavorita;
  final String? dondeLoVi;
  final String? notas;
  final DateTime fechaCreacion;

  CocheDeseado({
    this.id,
    required this.marca,
    required this.modelo,
    this.anio,
    this.imagenes = const [],
    this.imagenFavorita,
    this.dondeLoVi,
    this.notas,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'imagenes': imagenes.isEmpty ? null : imagenes.join(','),
      'imagenFavorita': imagenFavorita,
      'dondeLoVi': dondeLoVi,
      'notas': notas,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory CocheDeseado.fromMap(Map<String, dynamic> map) {
    return CocheDeseado(
      id: map['id'] as int?,
      marca: map['marca'] as String,
      modelo: map['modelo'] as String,
      anio: map['anio'] as int?,
      imagenes: map['imagenes'] != null 
          ? (map['imagenes'] as String).split(',')
          : [],
      imagenFavorita: map['imagenFavorita'] as String?,
      dondeLoVi: map['dondeLoVi'] as String?,
      notas: map['notas'] as String?,
      fechaCreacion: DateTime.parse(map['fechaCreacion'] as String),
    );
  }

  CocheDeseado copyWith({
    int? id,
    String? marca,
    String? modelo,
    int? anio,
    List<String>? imagenes,
    String? imagenFavorita,
    String? dondeLoVi,
    String? notas,
    DateTime? fechaCreacion,
  }) {
    return CocheDeseado(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      anio: anio ?? this.anio,
      imagenes: imagenes ?? this.imagenes,
      imagenFavorita: imagenFavorita ?? this.imagenFavorita,
      dondeLoVi: dondeLoVi ?? this.dondeLoVi,
      notas: notas ?? this.notas,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}
