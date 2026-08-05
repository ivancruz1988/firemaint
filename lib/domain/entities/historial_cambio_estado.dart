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

  // minimoHoras/maximoHoras vienen de una vista que nunca calculo su
  // equivalente en dias (a diferencia de promedioDias, que si lo trae de
  // origen). La conversion es exacta (24hs = 1 dia), asi que hacerla aca
  // evita otra migracion solo para agregar dos columnas derivadas.
  double? get minimoDias => minimoHoras != null ? minimoHoras! / 24 : null;
  double? get maximoDias => maximoHoras != null ? maximoHoras! / 24 : null;
}
