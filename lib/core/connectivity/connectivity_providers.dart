import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de conectividad de red del dispositivo.
///
/// No confirma que Supabase responda (eso solo se sabe al intentar la
/// operacion), pero alcanza para la señal mas util en el taller: "tenes wifi
/// o no". Sirve para el banner global y para decidir si vale la pena
/// reintentar una escritura automaticamente.
final conectividadProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged.map(
    (resultados) => !resultados.contains(ConnectivityResult.none),
  );
});

/// true mientras se resuelve el primer valor, para no mostrar "sin conexion"
/// por un instante al abrir la app.
final estaOnlineProvider = Provider<bool>((ref) {
  return ref.watch(conectividadProvider).value ?? true;
});
