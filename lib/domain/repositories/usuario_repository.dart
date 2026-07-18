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
}
