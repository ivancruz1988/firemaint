import 'enums.dart';

class Usuario {
  final String id;
  final String nombreCompleto;
  final String email;
  final UserRole rol;
  final String? telefono;
  final bool activo;
  final DateTime fechaCreacion;

  const Usuario({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.rol,
    this.telefono,
    this.activo = true,
    required this.fechaCreacion,
  });
}
