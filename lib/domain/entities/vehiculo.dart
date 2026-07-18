import 'enums.dart';

class Vehiculo {
  final String id;
  final String numeroInterno;
  final String? dominio;
  final String marca;
  final String modelo;
  final int? anio;
  final TipoVehiculo tipo;
  final double kilometraje;
  final double horasBomba;
  final DateTime fechaAlta;
  final EstadoVehiculo estadoOperativo;
  final String? observaciones;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;

  const Vehiculo({
    required this.id,
    required this.numeroInterno,
    this.dominio,
    required this.marca,
    required this.modelo,
    this.anio,
    required this.tipo,
    this.kilometraje = 0,
    this.horasBomba = 0,
    required this.fechaAlta,
    this.estadoOperativo = EstadoVehiculo.operativo,
    this.observaciones,
    required this.fechaCreacion,
    required this.fechaModificacion,
  });

  Vehiculo copyWith({
    String? numeroInterno,
    String? dominio,
    String? marca,
    String? modelo,
    int? anio,
    TipoVehiculo? tipo,
    double? kilometraje,
    double? horasBomba,
    DateTime? fechaAlta,
    EstadoVehiculo? estadoOperativo,
    String? observaciones,
  }) {
    return Vehiculo(
      id: id,
      numeroInterno: numeroInterno ?? this.numeroInterno,
      dominio: dominio ?? this.dominio,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      anio: anio ?? this.anio,
      tipo: tipo ?? this.tipo,
      kilometraje: kilometraje ?? this.kilometraje,
      horasBomba: horasBomba ?? this.horasBomba,
      fechaAlta: fechaAlta ?? this.fechaAlta,
      estadoOperativo: estadoOperativo ?? this.estadoOperativo,
      observaciones: observaciones ?? this.observaciones,
      fechaCreacion: fechaCreacion,
      fechaModificacion: fechaModificacion,
    );
  }
}
