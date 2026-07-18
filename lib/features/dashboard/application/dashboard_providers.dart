import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/repositories/vehiculo_repository.dart';

final dashboardKpisProvider = FutureProvider<VehiculosKpis>((ref) {
  return ref.watch(vehiculoRepositoryProvider).getKpis();
});
