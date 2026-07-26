import 'package:supabase_flutter/supabase_flutter.dart';

/// Cliente de la Edge Function `ask-database`, que busca contexto en la base y
/// arma la respuesta con Gemini. El token de sesion lo agrega el propio
/// SupabaseClient al invocar, no hace falta pasarlo a mano.
class AskDatabaseRepository {
  AskDatabaseRepository(this._client);

  final SupabaseClient _client;

  Future<String> preguntar(String pregunta) async {
    final respuesta = await _client.functions.invoke(
      'ask-database',
      body: {'query': pregunta},
    );

    final datos = respuesta.data;
    if (datos is! Map) {
      throw Exception('La consulta devolvio una respuesta inesperada.');
    }

    final error = datos['error'];
    if (error != null) throw Exception(error.toString());

    final texto = datos['answer'];
    if (texto is! String || texto.isEmpty) {
      throw Exception('La consulta no devolvio ninguna respuesta.');
    }
    return texto;
  }
}
