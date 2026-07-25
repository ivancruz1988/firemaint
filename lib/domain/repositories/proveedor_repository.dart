import '../entities/proveedor.dart';

abstract class ProveedorRepository {
  Future<List<Proveedor>> getAll({String busqueda = ''});
  Future<Proveedor?> getById(String id);
  Future<Proveedor> upsert(Proveedor proveedor);
  Future<void> delete(String id);
}
