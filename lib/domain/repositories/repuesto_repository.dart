import '../entities/movimiento_stock.dart';
import '../entities/repuesto.dart';

abstract class RepuestoRepository {
  Future<List<Repuesto>> getAll();
  Future<List<Repuesto>> getStockBajo();
  Future<Repuesto?> getById(String id);
  Future<Repuesto> upsert(Repuesto repuesto);
  Future<void> delete(String id);
  Future<List<MovimientoStock>> getMovimientos(String repuestoId);

  /// Registra un movimiento y actualiza el stock del repuesto en consecuencia.
  Future<void> registrarMovimiento(MovimientoStock movimiento);
}
