import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/enums.dart';
import '../../../../domain/repositories/vehiculo_repository.dart';
import '../../application/vehiculos_providers.dart';

class VehiculoFiltrosBar extends ConsumerStatefulWidget {
  const VehiculoFiltrosBar({super.key});

  @override
  ConsumerState<VehiculoFiltrosBar> createState() => _VehiculoFiltrosBarState();
}

class _VehiculoFiltrosBarState extends ConsumerState<VehiculoFiltrosBar> {
  final _textoController = TextEditingController();

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }

  void _actualizar({
    String? texto,
    TipoVehiculo? tipo,
    EstadoVehiculo? estado,
    bool clearTipo = false,
    bool clearEstado = false,
  }) {
    final actual = ref.read(vehiculoFiltroProvider);
    ref.read(vehiculoFiltroProvider.notifier).state = VehiculoFiltro(
      texto: texto ?? actual.texto,
      tipo: clearTipo ? null : (tipo ?? actual.tipo),
      estado: clearEstado ? null : (estado ?? actual.estado),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtro = ref.watch(vehiculoFiltroProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _textoController,
          decoration: const InputDecoration(
            hintText: 'Buscar por numero interno, dominio, marca o modelo',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => _actualizar(texto: value),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Todos'),
                selected: filtro.estado == null,
                onSelected: (_) => _actualizar(clearEstado: true),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Operativo'),
                selected: filtro.estado == EstadoVehiculo.operativo,
                onSelected: (_) => _actualizar(estado: EstadoVehiculo.operativo),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('En mantenimiento'),
                selected: filtro.estado == EstadoVehiculo.enMantenimiento,
                onSelected: (_) => _actualizar(estado: EstadoVehiculo.enMantenimiento),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Fuera de servicio'),
                selected: filtro.estado == EstadoVehiculo.fueraDeServicio,
                onSelected: (_) => _actualizar(estado: EstadoVehiculo.fueraDeServicio),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final tipo in TipoVehiculo.values) ...[
                FilterChip(
                  label: Text(tipo.label),
                  selected: filtro.tipo == tipo,
                  onSelected: (selected) =>
                      _actualizar(tipo: selected ? tipo : null, clearTipo: !selected),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
