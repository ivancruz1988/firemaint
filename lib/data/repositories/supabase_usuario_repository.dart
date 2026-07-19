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

  @override
  Future<void> actualizarUsuario({
    required String id,
    required String nombreCompleto,
    required UserRole rol,
    String? telefono,
  }) async {
    // La tabla guarda rol_id, no el nombre del rol: hay que resolverlo antes.
    final rolRow = await _client.from('roles').select('id').eq('nombre', rol.toDb()).single();

    await _client
        .from('usuarios')
        .update({'nombre_completo': nombreCompleto, 'rol_id': rolRow['id'], 'telefono': telefono})
        .eq('id', id);
  }

  @override
  Future<void> setActivo(String id, {required bool activo}) async {
    // Las reglas (solo admin, no autodesactivarse) las hace cumplir el trigger
    // trg_proteger_campos_usuario en la base: no dependen del cliente.
    await _client.from('usuarios').update({'activo': activo}).eq('id', id);
  }
}
