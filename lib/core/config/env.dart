import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Lee la configuracion de Supabase primero desde --dart-define (preferido para
/// build/release) y, si no vino definida, desde el .env local (desarrollo).
class SupabaseConfig {
  static const _dartDefineUrl = String.fromEnvironment('SUPABASE_URL');
  static const _dartDefineAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static String get url =>
      _dartDefineUrl.isNotEmpty ? _dartDefineUrl : (dotenv.env['SUPABASE_URL'] ?? '');

  static String get anonKey =>
      _dartDefineAnonKey.isNotEmpty ? _dartDefineAnonKey : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
