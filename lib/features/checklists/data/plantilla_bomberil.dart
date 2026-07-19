import '../../../domain/entities/checklist_item.dart';

/// Plantilla de checklist de mantenimiento preventivo para camion de bomberos.
/// Cada seccion agrupa sus items; el orden global se asigna al construir.
const plantillaBomberil = <String, List<String>>{
  '1. Iluminacion y senalizacion': [
    'Luces de posicion delanteras',
    'Luces de posicion traseras',
    'Luces bajas',
    'Luces altas',
    'Luces antiniebla',
    'Luces de giro delanteras',
    'Luces de giro traseras',
    'Balizas',
    'Luz de marcha atras',
    'Luz de patente',
    'Barra LED de emergencia',
    'Balizas laterales',
    'Reflectivos reglamentarios',
  ],
  '2. Sistema sonoro de emergencia': [
    'Sirena principal',
    'Sirena secundaria',
    'Bocina neumatica',
    'Bocina electrica',
    'Megafono',
  ],
  '3. Motor': [
    'Nivel de aceite motor',
    'Estado del aceite',
    'Nivel refrigerante',
    'Correas',
    'Mangueras',
    'Fugas de aceite',
    'Fugas de refrigerante',
    'Filtro de aire',
    'Arranque del motor',
    'Temperatura normal de trabajo',
  ],
  '4. Combustible y escape': [
    'Nivel de combustible',
    'Tapa de tanque',
    'Fugas de combustible',
    'Estado del escape',
  ],
  '5. Sistema electrico': [
    'Baterias',
    'Bornes limpios',
    'Alternador',
    'Fusibles',
    'Cableado visible',
    'Cargador de baterias',
  ],
  '6. Frenos': [
    'Freno de servicio',
    'Freno de estacionamiento',
    'Pastillas / zapatas',
    'Discos / tambores',
    'Nivel liquido de frenos',
    'Fugas neumaticas',
  ],
  '7. Direccion y suspension': [
    'Juego de direccion',
    'Rotulas',
    'Amortiguadores',
    'Elasticos',
    'Bujes',
  ],
  '8. Neumaticos': [
    'Presion neumatico delantero izquierdo',
    'Presion neumatico delantero derecho',
    'Presion neumaticos traseros',
    'Desgaste uniforme',
    'Estado rueda de auxilio',
  ],
  '9. Cabina': [
    'Cinturones de seguridad',
    'Asientos',
    'Espejos',
    'Limpiaparabrisas',
    'Lavaparabrisas',
    'Aire acondicionado',
    'Calefaccion',
    'Instrumental tablero',
  ],
  '10. Bomba contra incendios': [
    'Arranque de bomba',
    'Presion nominal',
    'Fugas en bomba',
    'Valvulas operativas',
    'Manometros',
    'Cebador',
    'Descargas laterales',
    'Descarga trasera',
    'Sistema CAFS (si posee)',
  ],
  '11. Tanque de agua y espuma': [
    'Nivel de agua',
    'Tanque sin perdidas',
    'Nivel de espumogeno',
    'Sistema de dosificacion',
  ],
  '12. Equipamiento operativo': [
    'Mangueras completas',
    'Lanzas',
    'Adaptadores',
    'Llaves de hidrante',
    'Escaleras',
    'Extintores',
    'Equipos ERA',
    'Herramientas de rescate',
    'Grupo electrogeno',
    'Motobomba portatil',
  ],
  '13. Seguridad': [
    'Botiquin',
    'Triangulos',
    'Matafuegos vehiculares',
    'Chalecos reflectivos',
    'Linternas',
  ],
};

/// Construye la lista de items de la plantilla para un checklist dado,
/// asignando categoria y orden global consecutivo.
List<ChecklistItem> construirItemsBomberil(String checklistId) {
  final items = <ChecklistItem>[];
  var orden = 0;
  for (final entry in plantillaBomberil.entries) {
    for (final descripcion in entry.value) {
      items.add(
        ChecklistItem(
          id: '',
          checklistId: checklistId,
          categoria: entry.key,
          descripcion: descripcion,
          orden: orden++,
        ),
      );
    }
  }
  return items;
}
