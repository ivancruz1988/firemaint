import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/proveedor.dart';
import '../../domain/repositories/proveedor_repository.dart';

class SupabaseProveedorRepository implements ProveedorRepository {
  SupabaseProveedorRepository(this._client);

  final SupabaseClient _client;

  /// Envuelve un valor de patron `ilike` en comillas dobles para que las
  /// comas, parentesis u otros caracteres reservados del DSL de filtros de
  /// PostgREST no rompan (ni inyecten condiciones en) la lista de `.or(...)`.
  String _patronIlike(String texto) {
    final escapado = texto.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
    return '"%$escapado%"';
  }

  Proveedor _fromMap(Map<String, dynamic> map) => Proveedor(
    id: map['id'] as String,
    nombre: map['nombre'] as String,
    rubro: map['rubro'] as String?,
    contacto: map['contacto'] as String?,
    telefono: map['telefono'] as String?,
    whatsapp: map['whatsapp'] as String?,
    email: map['email'] as String?,
    direccion: map['direccion'] as String?,
    localidad: map['localidad'] as String?,
    notas: map['notas'] as String?,
    activo: map['activo'] as bool? ?? true,
  );

  Map<String, dynamic> _toMap(Proveedor p) => {
    'nombre': p.nombre,
    'rubro': p.rubro,
    'contacto': p.contacto,
    'telefono': p.telefono,
    'whatsapp': p.whatsapp,
    'email': p.email,
    'direccion': p.direccion,
    'localidad': p.localidad,
    'notas': p.notas,
    'activo': p.activo,
  };

  @override
  Future<List<Proveedor>> getAll({String busqueda = ''}) async {
    var query = _client.from('proveedores').select();
    final texto = busqueda.trim();
    if (texto.isNotEmpty) {
      final patron = _patronIlike(texto);
      query = query.or(
        'nombre.ilike.$patron,rubro.ilike.$patron,contacto.ilike.$patron,localidad.ilike.$patron',
      );
    }
    final rows = await query.order('nombre');
    return rows.map(_fromMap).toList();
  }

  @override
  Future<Proveedor?> getById(String id) async {
    final row = await _client
        .from('proveedores')
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : _fromMap(row);
  }

  @override
  Future<Proveedor> upsert(Proveedor proveedor) async {
    final data = _toMap(proveedor);
    final row = proveedor.id.isEmpty
        ? await _client.from('proveedores').insert(data).select().single()
        : await _client
              .from('proveedores')
              .update(data)
              .eq('id', proveedor.id)
              .select()
              .single();
    return _fromMap(row);
  }

  @override
  Future<void> delete(String id) =>
      _client.from('proveedores').delete().eq('id', id);
}
