class HistorialCambioEstado {
  final String id;
  final String ordenTrabajoId;
  final String? estadoAnterior;
  final String estadoNuevo;
  final DateTime fechaCambio;
  final String? usuarioNombre;
  final String? observacion;

  const HistorialCambioEstado({
    required this.id,
    required this.ordenTrabajoId,
    this.estadoAnterior,
    required this.estadoNuevo,
    required this.fechaCambio,
    this.usuarioNombre,
    this.observacion,
  });
}

class EstadisticasTiempos {
  final String? estadoDesde;
  final String? estadoHacia;
  final int cantidadTransiciones;
  final double? promedioHoras;
  final double? minimoHoras;
  final double? maximoHoras;
  final double? promedioDias;

  const EstadisticasTiempos({
    this.estadoDesde,
    this.estadoHacia,
    this.cantidadTransiciones = 0,
    this.promedioHoras,
    this.minimoHoras,
    this.maximoHoras,
    this.promedioDias,
  });

  double? get promedioMinutos => promedioHoras != null ? promedioHoras! * 60 : null;
}
