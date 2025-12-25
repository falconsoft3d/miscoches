class Direccion {
  final int? id;
  final int cocheId;
  final String nombre;
  final String direccion;
  final double? latitud;
  final double? longitud;
  final String? tipo; // concesionario, taller, gasolinera, etc.
  final String? telefono;
  final String? notas;
  final DateTime fechaCreacion;

  Direccion({
    this.id,
    required this.cocheId,
    required this.nombre,
    required this.direccion,
    this.latitud,
    this.longitud,
    this.tipo,
    this.telefono,
    this.notas,
    required this.fechaCreacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cocheId': cocheId,
      'nombre': nombre,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'tipo': tipo,
      'telefono': telefono,
      'notas': notas,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Direccion.fromMap(Map<String, dynamic> map) {
    return Direccion(
      id: map['id'],
      cocheId: map['cocheId'],
      nombre: map['nombre'],
      direccion: map['direccion'],
      latitud: map['latitud'],
      longitud: map['longitud'],
      tipo: map['tipo'],
      telefono: map['telefono'],
      notas: map['notas'],
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
    );
  }

  Direccion copyWith({
    int? id,
    int? cocheId,
    String? nombre,
    String? direccion,
    double? latitud,
    double? longitud,
    String? tipo,
    String? telefono,
    String? notas,
    DateTime? fechaCreacion,
  }) {
    return Direccion(
      id: id ?? this.id,
      cocheId: cocheId ?? this.cocheId,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      tipo: tipo ?? this.tipo,
      telefono: telefono ?? this.telefono,
      notas: notas ?? this.notas,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}
