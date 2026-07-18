import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';

class SupabaseUsuarioRepository implements UsuarioRepository {
  SupabaseUsuarioRepository(this._client);

  final SupabaseClient _client;

  Usuario _fromMap(Map<String, dynamic> map) {
    final rolNombre = (map['roles'] as Map<String, dynamic>?)?['nombre'] as String?;
    return Usuario(
      id: map['id'] as String,
      nombreCompleto: map['nombre_completo'] as String,
      email: map['email'] as String,
      rol: UserRole.fromDb(rolNombre ?? 'tecnico'),
      telefono: map['telefono'] as String?,
      activo: map['activo'] as bool? ?? true,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
    );
  }

  @override
  Future<Usuario?> getById(String id) async {
    final row = await _client
        .from('usuarios')
        .select('id, nombre_completo, email, telefono, activo, fecha_creacion, roles(nombre)')
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return _fromMap(row);
  }

  @override
  Future<List<Usuario>> getAll() async {
    final rows = await _client
        .from('usuarios')
        .select('id, nombre_completo, email, telefono, activo, fecha_creacion, roles(nombre)')
        .order('nombre_completo');
    return rows.map(_fromMap).toList();
  }

  @override
  Future<void> crearUsuario({
    required String email,
    required String password,
    required String nombreCompleto,
    required UserRole rol,
    String? telefono,
  }) async {
    final response = await _client.functions.invoke(
      'create-user',
      body: {
        'email': email,
        'password': password,
        'nombre_completo': nombreCompleto,
        'rol': rol.toDb(),
        'telefono': ?telefono,
      },
    );
    final data = response.data;
    if (response.status != 200) {
      final mensaje = data is Map ? data['error'] as String? : null;
      throw Exception(mensaje ?? 'No se pudo crear el usuario');
    }
  }
}
