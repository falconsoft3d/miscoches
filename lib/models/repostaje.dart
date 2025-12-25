enum TipoCombustible {
  gasolina95,
  gasolina98,
  diesel,
  electrico,
  hibrido,
  glp,
  gnc
}

class Repostaje {
  final int? id;
  final int cocheId;
  final DateTime fecha;
  final double litros;
  final double? precioPorLitro;
  final double costoTotal;
  final double kilometraje;
  final TipoCombustible tipoCombustible;
  final bool tanqueLleno;
  final String? gasolinera;
  final String? notas;
  final DateTime fechaCreacion;

  Repostaje({
    this.id,
    required this.cocheId,
    required this.fecha,
    required this.litros,
    this.precioPorLitro,
    required this.costoTotal,
    required this.kilometraje,
    required this.tipoCombustible,
    this.tanqueLleno = false,
    this.gasolinera,
    this.notas,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cocheId': cocheId,
      'fecha': fecha.toIso8601String(),
      'litros': litros,
      'precioPorLitro': precioPorLitro,
      'costoTotal': costoTotal,
      'kilometraje': kilometraje,
      'tipoCombustible': tipoCombustible.name,
      'tanqueLleno': tanqueLleno ? 1 : 0,
      'gasolinera': gasolinera,
      'notas': notas,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Repostaje.fromMap(Map<String, dynamic> map) {
    return Repostaje(
      id: map['id'] as int?,
      cocheId: map['cocheId'] as int,
      fecha: DateTime.parse(map['fecha'] as String),
      litros: map['litros'] as double,
      precioPorLitro: map['precioPorLitro'] as double?,
      costoTotal: map['costoTotal'] as double,
      kilometraje: map['kilometraje'] as double,
      tipoCombustible: TipoCombustible.values.firstWhere(
        (e) => e.name == map['tipoCombustible'],
        orElse: () => TipoCombustible.gasolina95,
      ),
      tanqueLleno: map['tanqueLleno'] == 1,
      gasolinera: map['gasolinera'] as String?,
      notas: map['notas'] as String?,
      fechaCreacion: DateTime.parse(map['fechaCreacion'] as String),
    );
  }

  String get tipoCombustibleNombre {
    switch (tipoCombustible) {
      case TipoCombustible.gasolina95:
        return 'Gasolina 95';
      case TipoCombustible.gasolina98:
        return 'Gasolina 98';
      case TipoCombustible.diesel:
        return 'Diesel';
      case TipoCombustible.electrico:
        return 'Eléctrico';
      case TipoCombustible.hibrido:
        return 'Híbrido';
      case TipoCombustible.glp:
        return 'GLP';
      case TipoCombustible.gnc:
        return 'GNC';
    }
  }
}
