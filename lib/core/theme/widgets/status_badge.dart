import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Pill de color reutilizada para estado operativo de vehiculo, estado y
/// prioridad de OT, y estado de novedad.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color});

  factory StatusBadge.estadoOperativo(String estado) {
    switch (estado) {
      case 'operativo':
        return StatusBadge(label: 'Operativo', color: AppColors.exito);
      case 'en_mantenimiento':
        return StatusBadge(label: 'En mantenimiento', color: AppColors.alerta);
      case 'fuera_de_servicio':
        return StatusBadge(label: 'Fuera de servicio', color: AppColors.critico);
      default:
        return StatusBadge(label: estado, color: Colors.grey);
    }
  }

  factory StatusBadge.prioridadOt(String prioridad) {
    switch (prioridad) {
      case 'baja':
        return StatusBadge(label: 'Baja', color: AppColors.exito);
      case 'media':
        return StatusBadge(label: 'Media', color: AppColors.info);
      case 'alta':
        return StatusBadge(label: 'Alta', color: AppColors.alerta);
      case 'critica':
        return StatusBadge(label: 'Critica', color: AppColors.critico);
      default:
        return StatusBadge(label: prioridad, color: Colors.grey);
    }
  }

  factory StatusBadge.estadoOt(String estado) {
    switch (estado) {
      case 'pendiente':
        return StatusBadge(label: 'Pendiente', color: AppColors.alerta);
      case 'en_proceso':
        return StatusBadge(label: 'En proceso', color: AppColors.info);
      case 'esperando_repuestos':
        return StatusBadge(label: 'Esperando repuestos', color: AppColors.amarilloSeguridad);
      case 'finalizada':
        return StatusBadge(label: 'Finalizada', color: AppColors.exito);
      case 'cancelada':
        return const StatusBadge(label: 'Cancelada', color: Colors.grey);
      default:
        return StatusBadge(label: estado, color: Colors.grey);
    }
  }

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
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
  }
}
