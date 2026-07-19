import '../entities/enums.dart';
import '../entities/usuario.dart';

abstract class UsuarioRepository {
  Future<Usuario?> getById(String id);
  Future<List<Usuario>> getAll();

  /// Crea el usuario via la Edge Function `create-user` (requiere admin).
  Future<void> crearUsuario({
    required String email,
    required String password,
    required String nombreCompleto,
    required UserRole rol,
    String? telefono,
  });

  /// Da de baja (o reactiva) un usuario. Se usa baja logica en lugar de
  /// borrado para no perder el historial de trabajos que cargo. Solo admin.
  Future<void> setActivo(String id, {required bool activo});

  /// Corrige los datos de un usuario ya creado. El correo no se incluye:
  /// vive en auth.users y cambiarlo solo aca dejaria las dos tablas
  /// desincronizadas.
  Future<void> actualizarUsuario({
    required String id,
    required String nombreCompleto,
    required UserRole rol,
    String? telefono,
  });
}
