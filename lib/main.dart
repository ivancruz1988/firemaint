import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_AR');

  try {
    await dotenv.load();
  } catch (_) {
    // .env ausente (por ejemplo en release con --dart-define): se ignora,
    // SupabaseConfig ya sabe leer de dart-define como alternativa.
  }

  await Supabase.initialize(
    url: SupabaseConfig.isConfigured ? SupabaseConfig.url : 'https://placeholder.supabase.co',
    publishableKey: SupabaseConfig.isConfigured ? SupabaseConfig.anonKey : 'placeholder-anon-key',
  );

  runApp(const ProviderScope(child: AutomotoresApp()));
}

class AutomotoresApp extends ConsumerWidget {
  const AutomotoresApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Sistema de Gestion de Automotores',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
