import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client_provider.dart';
import '../data/ask_database_repository.dart';

final askDatabaseRepositoryProvider = Provider<AskDatabaseRepository>((ref) {
  return AskDatabaseRepository(ref.watch(supabaseClientProvider));
});

/// Un mensaje del chat. `esDelUsuario` distingue la pregunta de la respuesta:
/// mas simple que un string de rol que hay que comparar en cada widget.
class MensajeChat {
  const MensajeChat({
    required this.esDelUsuario,
    required this.texto,
    required this.hora,
  });

  final bool esDelUsuario;
  final String texto;
  final DateTime hora;
}

/// Conversacion en memoria: se pierde al salir de la pantalla, que es lo
/// esperable para una consulta puntual. Si en algun momento hace falta
/// historial persistente, va en una tabla, no aca.
class ChatController extends Notifier<List<MensajeChat>> {
  @override
  List<MensajeChat> build() => const [];

  /// Agrega la pregunta a la conversacion. Va separado de [responder] para que
  /// un reintento no vuelva a escribir la pregunta que ya esta en pantalla.
  void anotarPregunta(String texto) {
    state = [
      ...state,
      MensajeChat(esDelUsuario: true, texto: texto, hora: DateTime.now()),
    ];
  }

  Future<void> responder(String pregunta) async {
    final respuesta =
        await ref.read(askDatabaseRepositoryProvider).preguntar(pregunta);

    state = [
      ...state,
      MensajeChat(esDelUsuario: false, texto: respuesta, hora: DateTime.now()),
    ];
  }

  void limpiar() => state = const [];
}

final chatProvider = NotifierProvider<ChatController, List<MensajeChat>>(
  ChatController.new,
);
