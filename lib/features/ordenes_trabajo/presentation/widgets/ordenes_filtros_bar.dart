import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/lookup_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/enums.dart';
import '../../application/orden_trabajo_filtro.dart';
import '../../application/ordenes_trabajo_providers.dart';

/// Barra de filtros del historial de ordenes.
///
/// Mantiene los valores en estado local y emite el filtro completo en cada
/// cambio: evita el problema clasico de copyWith con campos que se quieren
/// volver a poner en null al elegir "Todos".
class OrdenesFiltrosBar extends ConsumerStatefulWidget {
  const OrdenesFiltrosBar({super.key});

  @override
  ConsumerState<OrdenesFiltrosBar> createState() => _OrdenesFiltrosBarState();
}

class _OrdenesFiltrosBarState extends ConsumerState<OrdenesFiltrosBar> {
  final _textoController = TextEditingController();

  EstadoOt? _estado;
  PrioridadOt? _prioridad;
  String? _tecnicoId;
  bool _sinTecnico = false;
  String? _vehiculoId;
  int? _anio;
  int? _mes;
  bool _expandido = false;

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }

  void _emitir() {
    ref
        .read(filtroOrdenesProvider.notifier)
        .aplicar(
          OrdenTrabajoFiltro(
            texto: _textoController.text.trim(),
            estado: _estado,
            prioridad: _prioridad,
            tecnicoId: _tecnicoId,
            sinTecnico: _sinTecnico,
            vehiculoId: _vehiculoId,
            anio: _anio,
            mes: _mes,
          ),
        );
  }

  void _limpiar() {
    setState(() {
      _textoController.clear();
      _estado = null;
      _prioridad = null;
      _tecnicoId = null;
      _sinTecnico = false;
      _vehiculoId = null;
      _anio = null;
      _mes = null;
    });
    ref.read(filtroOrdenesProvider.notifier).limpiar();
  }

  @override
  Widget build(BuildContext context) {
    final filtro = ref.watch(filtroOrdenesProvider);
    final vehiculos = ref.watch(vehiculosLookupProvider).value ?? const [];
    final usuarios = ref.watch(usuariosLookupProvider).value ?? const [];
    final anios = ref.watch(aniosConOrdenesProvider).value ?? const [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textoController,
                  onChanged: (_) => _emitir(),
                  decoration: InputDecoration(
                    hintText: 'Buscar por numero, titulo o descripcion',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    suffixIcon: _textoController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(_textoController.clear);
                              _emitir();
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: _expandido ? 'Ocultar filtros' : 'Mas filtros',
                onPressed: () => setState(() => _expandido = !_expandido),
                icon: Badge(
                  // El punto avisa que hay filtros activos aunque el panel
                  // este plegado; sin esto se ven resultados recortados sin
                  // ninguna pista de por que.
                  isLabelVisible: filtro.hayAlguno,
                  backgroundColor: AppColors.rojoClaro,
                  child: Icon(_expandido ? Icons.filter_list_off : Icons.filter_list),
                ),
              ),
            ],
          ),
          if (_expandido) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _desplegable<EstadoOt>(
                  etiqueta: 'Estado',
                  valor: _estado,
                  opciones: {for (final e in EstadoOt.values) e: e.label},
                  onChanged: (v) => setState(() {
                    _estado = v;
                    _emitir();
                  }),
                ),
                _desplegable<PrioridadOt>(
                  etiqueta: 'Prioridad',
                  valor: _prioridad,
                  opciones: {for (final p in PrioridadOt.values) p: p.label},
                  onChanged: (v) => setState(() {
                    _prioridad = v;
                    _emitir();
                  }),
                ),
                _desplegable<String>(
                  etiqueta: 'Unidad',
                  valor: _vehiculoId,
                  opciones: {
                    for (final v in vehiculos) v.id: '${v.numeroInterno} - ${v.marca} ${v.modelo}',
                  },
                  onChanged: (v) => setState(() {
                    _vehiculoId = v;
                    _emitir();
                  }),
                ),
                _desplegable<String>(
                  etiqueta: 'Tecnico',
                  valor: _sinTecnico ? _sinAsignar : _tecnicoId,
                  opciones: {
                    _sinAsignar: 'Sin asignar',
                    for (final u in usuarios) u.id: u.nombreCompleto,
                  },
                  onChanged: (v) => setState(() {
                    _sinTecnico = v == _sinAsignar;
                    _tecnicoId = v == _sinAsignar ? null : v;
                    _emitir();
                  }),
                ),
                _desplegable<int>(
                  etiqueta: 'Anio',
                  valor: _anio,
                  opciones: {for (final a in anios) a: '$a'},
                  onChanged: (v) => setState(() {
                    _anio = v;
                    _emitir();
                  }),
                ),
                _desplegable<int>(
                  etiqueta: 'Mes',
                  valor: _mes,
                  opciones: {for (var i = 1; i <= 12; i++) i: mesesDelAnio[i - 1]},
                  onChanged: (v) => setState(() {
                    _mes = v;
                    _emitir();
                  }),
                ),
                if (filtro.hayAlguno)
                  ActionChip(
                    avatar: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Limpiar'),
                    onPressed: _limpiar,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static const _sinAsignar = '__sin_asignar__';

  Widget _desplegable<T>({
    required String etiqueta,
    required T? valor,
    required Map<T, String> opciones,
    required ValueChanged<T?> onChanged,
  }) {
    return SizedBox(
      width: 190,
      child: DropdownButtonFormField<T?>(
        initialValue: valor,
        isExpanded: true,
        decoration: InputDecoration(labelText: etiqueta, isDense: true),
        items: [
          const DropdownMenuItem(value: null, child: Text('Todos')),
          for (final e in opciones.entries)
            DropdownMenuItem(
              value: e.key,
              child: Text(e.value, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
