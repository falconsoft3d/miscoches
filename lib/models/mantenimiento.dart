enum TipoMantenimiento {
  cambioAceite,
  revisionGeneral,
  cambioFrenos,
  cambioNeumaticos,
  reparacion,
  inspeccionTecnica,
  otros
}

class Mantenimiento {
  final int? id;
  final int cocheId;
  final TipoMantenimiento tipo;
  final String? descripcion;
  final DateTime fecha;
  final double kilometraje;
  final double? costo;
  final String? taller;
  final String? notas;
  final DateTime? proximoMantenimiento;
  final double? proximoKilometraje;
  final DateTime fechaCreacion;

  Mantenimiento({
    this.id,
    required this.cocheId,
    required this.tipo,
    this.descripcion,
    required this.fecha,
    required this.kilometraje,
    this.costo,
    this.taller,
    this.notas,
    this.proximoMantenimiento,
    this.proximoKilometraje,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cocheId': cocheId,
      'tipo': tipo.name,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'kilometraje': kilometraje,
      'costo': costo,
      'taller': taller,
      'notas': notas,
      'proximoMantenimiento': proximoMantenimiento?.toIso8601String(),
      'proximoKilometraje': proximoKilometraje,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Mantenimiento.fromMap(Map<String, dynamic> map) {
    return Mantenimiento(
      id: map['id'] as int?,
      cocheId: map['cocheId'] as int,
      tipo: TipoMantenimiento.values.firstWhere(
        (e) => e.name == map['tipo'],
        orElse: () => TipoMantenimiento.otros,
      ),
      descripcion: map['descripcion'] as String?,
      fecha: DateTime.parse(map['fecha'] as String),
      kilometraje: map['kilometraje'] as double,
      costo: map['costo'] as double?,
      taller: map['taller'] as String?,
      notas: map['notas'] as String?,
      proximoMantenimiento: map['proximoMantenimiento'] != null 
          ? DateTime.parse(map['proximoMantenimiento'] as String) 
          : null,
      proximoKilometraje: map['proximoKilometraje'] as double?,
      fechaCreacion: DateTime.parse(map['fechaCreacion'] as String),
    );
  }

  String get tipoNombre {
    switch (tipo) {
      case TipoMantenimiento.cambioAceite:
        return 'Cambio de Aceite';
      case TipoMantenimiento.revisionGeneral:
        return 'Revisión General';
      case TipoMantenimiento.cambioFrenos:
        return 'Cambio de Frenos';
      case TipoMantenimiento.cambioNeumaticos:
        return 'Cambio de Neumáticos';
      case TipoMantenimiento.reparacion:
        return 'Reparación';
      case TipoMantenimiento.inspeccionTecnica:
        return 'Inspección Técnica';
      case TipoMantenimiento.otros:
        return 'Otros';
    }
  }
}
