import 'package:flutter/material.dart';

import '../app_colors.dart';
import 'pulse_glow.dart';

enum _Urgencia { ninguna, atencion, critica }

/// Pill de color reutilizada para estado operativo de vehiculo, estado y
/// prioridad de OT, y estado de novedad. Los estados criticos llevan un
/// pulso de urgencia; el resto queda estatico y calmo.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color})
    : _urgencia = _Urgencia.ninguna;

  const StatusBadge._urgente(this.label, this.color, this._urgencia);

  factory StatusBadge.estadoOperativo(String estado) {
    switch (estado) {
      case 'operativo':
        return const StatusBadge(label: 'Operativo', color: AppColors.exito);
      case 'en_mantenimiento':
        return const StatusBadge._urgente('En mantenimiento', AppColors.alerta, _Urgencia.atencion);
      case 'fuera_de_servicio':
        return const StatusBadge._urgente(
          'Fuera de servicio',
          AppColors.critico,
          _Urgencia.critica,
        );
      default:
        return StatusBadge(label: estado, color: AppColors.textoTenue);
    }
  }

  factory StatusBadge.prioridadOt(String prioridad) {
    switch (prioridad) {
      case 'baja':
        return const StatusBadge(label: 'Baja', color: AppColors.exito);
      case 'media':
        return const StatusBadge(label: 'Media', color: AppColors.info);
      case 'alta':
        return const StatusBadge(label: 'Alta', color: AppColors.alerta);
      case 'critica':
        return const StatusBadge._urgente('Critica', AppColors.critico, _Urgencia.critica);
      default:
        return StatusBadge(label: prioridad, color: AppColors.textoTenue);
    }
  }

  factory StatusBadge.estadoOt(String estado) {
    switch (estado) {
      case 'pendiente':
        return const StatusBadge(label: 'Pendiente', color: AppColors.alerta);
      case 'en_proceso':
        return const StatusBadge(label: 'En proceso', color: AppColors.info);
      case 'esperando_repuestos':
        return const StatusBadge(label: 'Esperando repuestos', color: AppColors.amarilloSeguridad);
      case 'finalizada':
        return const StatusBadge(label: 'Finalizada', color: AppColors.exito);
      case 'cancelada':
        return const StatusBadge(label: 'Cancelada', color: AppColors.textoTenue);
      default:
        return StatusBadge(label: estado, color: AppColors.textoTenue);
    }
  }

  final String label;
  final Color color;
  final _Urgencia _urgencia;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );

    switch (_urgencia) {
      case _Urgencia.critica:
        return PulseGlow(
          color: color,
          borderRadius: BorderRadius.circular(20),
          period: const Duration(milliseconds: 1500),
          child: pill,
        );
      case _Urgencia.atencion:
        return PulseGlow(
          color: color,
          borderRadius: BorderRadius.circular(20),
          period: const Duration(milliseconds: 2800),
          child: pill,
        );
      case _Urgencia.ninguna:
        return pill;
    }
  }
}
