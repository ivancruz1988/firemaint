// Enums de dominio con conversion 1:1 a los `text` + `check` de Postgres.
// Centralizados aca para que las 13 tablas compartan el mismo vocabulario.

enum UserRole {
  administrador,
  tecnico,
  jefeTaller;

  static UserRole fromDb(String value) => switch (value) {
        'administrador' => UserRole.administrador,
        'tecnico' => UserRole.tecnico,
        'jefe_taller' => UserRole.jefeTaller,
        _ => throw ArgumentError('Rol desconocido: $value'),
      };

  String toDb() => switch (this) {
        UserRole.administrador => 'administrador',
        UserRole.tecnico => 'tecnico',
        UserRole.jefeTaller => 'jefe_taller',
      };

  String get label => switch (this) {
        UserRole.administrador => 'Administrador',
        UserRole.tecnico => 'Tecnico',
        UserRole.jefeTaller => 'Jefe de taller',
      };
}

enum TipoVehiculo {
  autobomba,
  cisterna,
  rescate,
  pickup,
  otro;

  static TipoVehiculo fromDb(String value) =>
      TipoVehiculo.values.firstWhere((e) => e.name == value, orElse: () => TipoVehiculo.otro);

  String toDb() => name;

  String get label => switch (this) {
        TipoVehiculo.autobomba => 'Autobomba',
        TipoVehiculo.cisterna => 'Cisterna',
        TipoVehiculo.rescate => 'Vehiculo de rescate',
        TipoVehiculo.pickup => 'Camioneta',
        TipoVehiculo.otro => 'Otro',
      };
}

enum EstadoVehiculo {
  operativo,
  fueraDeServicio,
  enMantenimiento;

  static EstadoVehiculo fromDb(String value) => switch (value) {
        'operativo' => EstadoVehiculo.operativo,
        'fuera_de_servicio' => EstadoVehiculo.fueraDeServicio,
        'en_mantenimiento' => EstadoVehiculo.enMantenimiento,
        _ => throw ArgumentError('Estado desconocido: $value'),
      };

  String toDb() => switch (this) {
        EstadoVehiculo.operativo => 'operativo',
        EstadoVehiculo.fueraDeServicio => 'fuera_de_servicio',
        EstadoVehiculo.enMantenimiento => 'en_mantenimiento',
      };

  String get label => switch (this) {
        EstadoVehiculo.operativo => 'Operativo',
        EstadoVehiculo.fueraDeServicio => 'Fuera de servicio',
        EstadoVehiculo.enMantenimiento => 'En mantenimiento',
      };
}

enum PrioridadOt {
  baja,
  media,
  alta,
  critica;

  static PrioridadOt fromDb(String value) =>
      PrioridadOt.values.firstWhere((e) => e.name == value, orElse: () => PrioridadOt.media);

  String toDb() => name;

  String get label => switch (this) {
        PrioridadOt.baja => 'Baja',
        PrioridadOt.media => 'Media',
        PrioridadOt.alta => 'Alta',
        PrioridadOt.critica => 'Critica',
      };
}

enum EstadoOt {
  pendiente,
  enProceso,
  esperandoRepuestos,
  finalizada,
  cancelada;

  static EstadoOt fromDb(String value) => switch (value) {
        'pendiente' => EstadoOt.pendiente,
        'en_proceso' => EstadoOt.enProceso,
        'esperando_repuestos' => EstadoOt.esperandoRepuestos,
        'finalizada' => EstadoOt.finalizada,
        'cancelada' => EstadoOt.cancelada,
        _ => throw ArgumentError('Estado de OT desconocido: $value'),
      };

  String toDb() => switch (this) {
        EstadoOt.pendiente => 'pendiente',
        EstadoOt.enProceso => 'en_proceso',
        EstadoOt.esperandoRepuestos => 'esperando_repuestos',
        EstadoOt.finalizada => 'finalizada',
        EstadoOt.cancelada => 'cancelada',
      };

  String get label => switch (this) {
        EstadoOt.pendiente => 'Pendiente',
        EstadoOt.enProceso => 'En proceso',
        EstadoOt.esperandoRepuestos => 'Esperando repuestos',
        EstadoOt.finalizada => 'Finalizada',
        EstadoOt.cancelada => 'Cancelada',
      };
}

enum TipoNovedad {
  averia,
  falla,
  accidente,
  reparacionUrgente;

  static TipoNovedad fromDb(String value) => switch (value) {
        'averia' => TipoNovedad.averia,
        'falla' => TipoNovedad.falla,
        'accidente' => TipoNovedad.accidente,
        'reparacion_urgente' => TipoNovedad.reparacionUrgente,
        _ => throw ArgumentError('Tipo de novedad desconocido: $value'),
      };

  String toDb() => switch (this) {
        TipoNovedad.averia => 'averia',
        TipoNovedad.falla => 'falla',
        TipoNovedad.accidente => 'accidente',
        TipoNovedad.reparacionUrgente => 'reparacion_urgente',
      };

  String get label => switch (this) {
        TipoNovedad.averia => 'Averia',
        TipoNovedad.falla => 'Falla',
        TipoNovedad.accidente => 'Accidente',
        TipoNovedad.reparacionUrgente => 'Reparacion urgente',
      };
}

enum EstadoNovedad {
  abierta,
  enAtencion,
  resuelta;

  static EstadoNovedad fromDb(String value) => switch (value) {
        'abierta' => EstadoNovedad.abierta,
        'en_atencion' => EstadoNovedad.enAtencion,
        'resuelta' => EstadoNovedad.resuelta,
        _ => throw ArgumentError('Estado de novedad desconocido: $value'),
      };

  String toDb() => switch (this) {
        EstadoNovedad.abierta => 'abierta',
        EstadoNovedad.enAtencion => 'en_atencion',
        EstadoNovedad.resuelta => 'resuelta',
      };

  String get label => switch (this) {
        EstadoNovedad.abierta => 'Abierta',
        EstadoNovedad.enAtencion => 'En atencion',
        EstadoNovedad.resuelta => 'Resuelta',
      };
}

enum Frecuencia {
  diario,
  semanal,
  mensual,
  anual;

  static Frecuencia fromDb(String value) =>
      Frecuencia.values.firstWhere((e) => e.name == value, orElse: () => Frecuencia.mensual);

  String toDb() => name;

  String get label => switch (this) {
        Frecuencia.diario => 'Diario',
        Frecuencia.semanal => 'Semanal',
        Frecuencia.mensual => 'Mensual',
        Frecuencia.anual => 'Anual',
      };
}

enum ResultadoChecklistItem {
  cumple,
  noCumple,
  noAplica;

  static ResultadoChecklistItem? fromDb(String? value) => switch (value) {
        'cumple' => ResultadoChecklistItem.cumple,
        'no_cumple' => ResultadoChecklistItem.noCumple,
        'no_aplica' => ResultadoChecklistItem.noAplica,
        _ => null,
      };

  String toDb() => switch (this) {
        ResultadoChecklistItem.cumple => 'cumple',
        ResultadoChecklistItem.noCumple => 'no_cumple',
        ResultadoChecklistItem.noAplica => 'no_aplica',
      };

  String get label => switch (this) {
        ResultadoChecklistItem.cumple => 'OK',
        ResultadoChecklistItem.noCumple => 'NO OK',
        ResultadoChecklistItem.noAplica => 'N/A',
      };
}

enum TipoMovimientoStock {
  ingreso,
  egreso,
  ajuste;

  static TipoMovimientoStock fromDb(String value) => TipoMovimientoStock.values
      .firstWhere((e) => e.name == value, orElse: () => TipoMovimientoStock.ajuste);

  String toDb() => name;

  String get label => switch (this) {
        TipoMovimientoStock.ingreso => 'Ingreso',
        TipoMovimientoStock.egreso => 'Egreso',
        TipoMovimientoStock.ajuste => 'Ajuste',
      };
}

enum TipoArchivo {
  foto,
  manual,
  documento,
  fotoAntes,
  fotoDespues;

  static TipoArchivo fromDb(String value) => switch (value) {
        'foto' => TipoArchivo.foto,
        'manual' => TipoArchivo.manual,
        'documento' => TipoArchivo.documento,
        'foto_antes' => TipoArchivo.fotoAntes,
        'foto_despues' => TipoArchivo.fotoDespues,
        _ => throw ArgumentError('Tipo de archivo desconocido: $value'),
      };

  String toDb() => switch (this) {
        TipoArchivo.foto => 'foto',
        TipoArchivo.manual => 'manual',
        TipoArchivo.documento => 'documento',
        TipoArchivo.fotoAntes => 'foto_antes',
        TipoArchivo.fotoDespues => 'foto_despues',
      };
}

enum TipoEventoHistorial {
  ordenTrabajo,
  novedad,
  mantenimiento,
  cambioEstado;

  static TipoEventoHistorial fromDb(String value) => switch (value) {
        'orden_trabajo' => TipoEventoHistorial.ordenTrabajo,
        'novedad' => TipoEventoHistorial.novedad,
        'mantenimiento' => TipoEventoHistorial.mantenimiento,
        'cambio_estado' => TipoEventoHistorial.cambioEstado,
        _ => throw ArgumentError('Tipo de evento desconocido: $value'),
      };
}
