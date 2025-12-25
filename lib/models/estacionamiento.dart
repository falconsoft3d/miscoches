class Estacionamiento {
  final int? id;
  final int cocheId;
  final double? latitud;
  final double? longitud;
  final String? direccion;
  final String? piso;
  final String? numero;
  final String? notas;
  final DateTime fechaCreacion;

  Estacionamiento({
    this.id,
    required this.cocheId,
    this.latitud,
    this.longitud,
    this.direccion,
    this.piso,
    this.numero,
    this.notas,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cocheId': cocheId,
      'latitud': latitud,
      'longitud': longitud,
      'direccion': direccion,
      'piso': piso,
      'numero': numero,
      'notas': notas,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Estacionamiento.fromMap(Map<String, dynamic> map) {
    return Estacionamiento(
      id: map['id'] as int?,
      cocheId: map['cocheId'] as int,
      latitud: map['latitud'] as double?,
      longitud: map['longitud'] as double?,
      direccion: map['direccion'] as String?,
      piso: map['piso'] as String?,
      numero: map['numero'] as String?,
      notas: map['notas'] as String?,
      fechaCreacion: DateTime.parse(map['fechaCreacion'] as String),
    );
  }

  Estacionamiento copyWith({
    int? id,
    int? cocheId,
    double? latitud,
    double? longitud,
    String? direccion,
    String? piso,
    String? numero,
    String? notas,
    DateTime? fechaCreacion,
  }) {
    return Estacionamiento(
      id: id ?? this.id,
      cocheId: cocheId ?? this.cocheId,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      direccion: direccion ?? this.direccion,
      piso: piso ?? this.piso,
      numero: numero ?? this.numero,
      notas: notas ?? this.notas,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}
