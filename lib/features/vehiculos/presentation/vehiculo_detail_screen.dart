import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/fade_slide_in.dart';
import '../../../core/theme/widgets/fire_button.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../core/theme/widgets/hazard_stripes.dart';
import '../../../core/theme/widgets/status_badge.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/snackbar_error.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/orden_trabajo.dart';
import '../../../domain/entities/vehiculo.dart';
import '../../auth/application/auth_providers.dart';
import '../../dashboard/application/dashboard_providers.dart';
import '../application/vehiculos_providers.dart';
import '../../../core/widgets/adjuntos_section.dart';
import '../../../domain/entities/padre_archivo.dart';

Color _colorEstadoVehiculo(EstadoVehiculo estado) => switch (estado) {
  EstadoVehiculo.operativo => AppColors.exito,
  EstadoVehiculo.enMantenimiento => AppColors.alerta,
  EstadoVehiculo.fueraDeServicio => AppColors.critico,
};

class VehiculoDetailScreen extends ConsumerWidget {
  const VehiculoDetailScreen({super.key, required this.vehiculoId});

  final String vehiculoId;

  Future<void> _eliminar(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar vehiculo'),
        content: const Text('Esta accion no se puede deshacer. Confirmas la eliminacion?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await ref.read(vehiculoRepositoryProvider).delete(vehiculoId);
      ref.invalidate(vehiculosListProvider);
      ref.invalidate(dashboardKpisProvider);
      if (context.mounted) context.pop();
    } catch (e) {
      // Sin este catch, un fallo de red dejaba al usuario mirando la pantalla
      // sin ningun aviso de que el vehiculo seguia existiendo.
      if (context.mounted) {
        mostrarErrorConReintento(
          context,
          e,
          () => _eliminar(context, ref),
          accion: 'eliminar el vehiculo',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiculoAsync = ref.watch(vehiculoByIdProvider(vehiculoId));
    final rol = ref.watch(currentRoleProvider);
    final puedeEditar = rol == UserRole.administrador || rol == UserRole.jefeTaller;
    final puedeEliminar = rol == UserRole.administrador;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha del vehiculo'),
        actions: [
          if (puedeEditar)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/vehiculos/$vehiculoId/editar'),
            ),
          if (puedeEliminar)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _eliminar(context, ref),
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4),
          child: HazardStripes(height: 4),
        ),
      ),
      body: vehiculoAsync.when(
        data: (vehiculo) {
          if (vehiculo == null) {
            return const Center(child: Text('El vehiculo no existe o fue eliminado.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FadeSlideIn(child: _HeaderCard(vehiculo: vehiculo)),
              const SizedBox(height: 16),
              FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: _AccionesRapidas(vehiculoId: vehiculo.id, puedeSolicitarTaller: puedeEditar),
              ),
              const SizedBox(height: 16),
              FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: _MetricasBento(vehiculo: vehiculo),
              ),
              const SizedBox(height: 16),
              FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: _HistorialServicio(vehiculoId: vehiculo.id),
              ),
              const SizedBox(height: 16),
              FadeSlideIn(
                delay: const Duration(milliseconds: 240),
                child: AdjuntosSection(padre: PadreArchivo.vehiculo(vehiculo.id)),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('No se pudo cargar el vehiculo: $error')),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.vehiculo});

  final Vehiculo vehiculo;

  @override
  Widget build(BuildContext context) {
    final color = _colorEstadoVehiculo(vehiculo.estadoOperativo);
    return FireCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.relleno,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(Icons.local_shipping, color: AppColors.rojoBombero, size: 44),
                ),
                const SizedBox(height: 16),
                Text(vehiculo.numeroInterno, style: AppTextStyles.headline),
                const SizedBox(height: 8),
                StatusBadge.estadoOperativo(vehiculo.estadoOperativo.toDb()),
                const SizedBox(height: 4),
                Text(
                  '${vehiculo.marca} ${vehiculo.modelo}',
                  style: AppTextStyles.body.copyWith(color: AppColors.textoTenue),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 4),
                _Fila('Dominio', vehiculo.dominio ?? '-'),
                _Fila('Tipo', vehiculo.tipo.label),
                _Fila('Anio', vehiculo.anio?.toString() ?? '-'),
                _Fila('Fecha de alta', formatDate(vehiculo.fechaAlta)),
                if (vehiculo.observaciones != null && vehiculo.observaciones!.isNotEmpty)
                  _Fila('Observaciones', vehiculo.observaciones!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccionesRapidas extends StatelessWidget {
  const _AccionesRapidas({required this.vehiculoId, required this.puedeSolicitarTaller});

  final String vehiculoId;
  final bool puedeSolicitarTaller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FireButton.danger(
          label: 'Registrar novedad',
          icon: Icons.report_outlined,
          onPressed: () => context.push('/novedades/nueva'),
        ),
        if (puedeSolicitarTaller) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/ordenes-trabajo/nueva'),
              icon: const Icon(Icons.build_outlined),
              label: const Text('Solicitar taller'),
            ),
          ),
        ],
      ],
    );
  }
}

class _MetricasBento extends ConsumerWidget {
  const _MetricasBento({required this.vehiculo});

  final Vehiculo vehiculo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otsAsync = ref.watch(ordenesTrabajoPorVehiculoProvider(vehiculo.id));
    final otsAbiertas = otsAsync.value?.where((ot) => ot.estado.estaAbierta).length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.4,
      children: [
        _MetricaTile(
          icon: Icons.speed_outlined,
          valor: formatNumber(vehiculo.kilometraje),
          unidad: 'km',
          etiqueta: 'Kilometraje',
        ),
        _MetricaTile(
          icon: Icons.timelapse_outlined,
          valor: formatNumber(vehiculo.horasBomba),
          unidad: 'hs',
          etiqueta: 'Horas de bomba',
        ),
        _MetricaTile(
          icon: Icons.build_circle_outlined,
          valor: otsAbiertas?.toString() ?? '—',
          etiqueta: 'OT abiertas',
          colorValor: otsAbiertas == null || otsAbiertas == 0 ? null : AppColors.alerta,
          colorPunto: otsAbiertas == null
              ? null
              : (otsAbiertas == 0 ? AppColors.exito : AppColors.alerta),
        ),
        _MetricaTile(
          icon: Icons.event_outlined,
          valor: vehiculo.anio?.toString() ?? '-',
          etiqueta: 'Anio',
        ),
      ],
    );
  }
}

class _MetricaTile extends StatelessWidget {
  const _MetricaTile({
    required this.icon,
    required this.valor,
    required this.etiqueta,
    this.unidad,
    this.colorValor,
    this.colorPunto,
  });

  final IconData icon;
  final String valor;
  final String etiqueta;
  final String? unidad;
  final Color? colorValor;
  final Color? colorPunto;

  @override
  Widget build(BuildContext context) {
    return FireCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.textoTenue, size: 22),
              if (colorPunto != null)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: colorPunto, shape: BoxShape.circle),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: valor,
                      style: AppTextStyles.kpiNumber.copyWith(
                        fontSize: 24,
                        color: colorValor ?? AppColors.textoPrincipal,
                      ),
                    ),
                    if (unidad != null)
                      TextSpan(
                        text: ' $unidad',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textoTenue),
                      ),
                  ],
                ),
              ),
              Text(etiqueta.toUpperCase(), style: AppTextStyles.label),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistorialServicio extends ConsumerWidget {
  const _HistorialServicio({required this.vehiculoId});

  final String vehiculoId;

  IconData _icono(EstadoOt estado) => switch (estado) {
    EstadoOt.pendiente => Icons.schedule_outlined,
    EstadoOt.enProceso => Icons.sync,
    EstadoOt.esperandoRepuestos => Icons.inventory_2_outlined,
    EstadoOt.finalizada => Icons.check_circle_outline,
    EstadoOt.cancelada => Icons.cancel_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otsAsync = ref.watch(ordenesTrabajoPorVehiculoProvider(vehiculoId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Historial de servicio', style: AppTextStyles.title),
        const SizedBox(height: 6),
        const ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          child: HazardStripes(height: 4),
        ),
        const SizedBox(height: 12),
        otsAsync.when(
          data: (ots) {
            if (ots.isEmpty) {
              return const Text('Sin ordenes de trabajo registradas.', style: AppTextStyles.body);
            }
            return FireCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < ots.length; i++) ...[
                    if (i > 0) const Divider(),
                    _HistorialItem(ot: ots[i], icono: _icono(ots[i].estado)),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('No se pudo cargar el historial: $error', style: AppTextStyles.body),
        ),
      ],
    );
  }
}

class _HistorialItem extends StatelessWidget {
  const _HistorialItem({required this.ot, required this.icono});

  final OrdenTrabajo ot;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final fecha = ot.fechaFin ?? ot.fechaCreacion;
    return InkWell(
      onTap: () => context.push('/ordenes-trabajo/${ot.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icono, size: 20, color: AppColors.textoTenue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OT #${ot.numeroOt} — ${ot.titulo}', style: AppTextStyles.body),
                const SizedBox(height: 2),
                Row(
                  children: [
                    StatusBadge.estadoOt(ot.estado.toDb()),
                    const SizedBox(width: 8),
                    Text(formatDateTime(fecha), style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(etiqueta, style: AppTextStyles.label)),
          Expanded(
            child: Text(valor, style: AppTextStyles.body.copyWith(color: AppColors.textoPrincipal)),
          ),
        ],
      ),
    );
  }
}
