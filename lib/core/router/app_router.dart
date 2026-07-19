import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/enums.dart';
import '../supabase/supabase_client_provider.dart';
import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/checklists/presentation/checklists_list_screen.dart';
import '../../features/checklists/presentation/checklist_detail_screen.dart';
import '../../features/checklists/presentation/checklist_form_screen.dart';
import '../../features/configuracion/presentation/configuracion_screen.dart';
import '../../features/configuracion/presentation/usuarios_admin_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/mantenimiento_preventivo/presentation/mantenimiento_list_screen.dart';
import '../../features/mantenimiento_preventivo/presentation/mantenimiento_form_screen.dart';
import '../../features/novedades/presentation/novedades_list_screen.dart';
import '../../features/novedades/presentation/novedad_detail_screen.dart';
import '../../features/novedades/presentation/novedad_form_screen.dart';
import '../../features/ordenes_trabajo/presentation/ordenes_trabajo_list_screen.dart';
import '../../features/ordenes_trabajo/presentation/orden_trabajo_detail_screen.dart';
import '../../features/ordenes_trabajo/presentation/orden_trabajo_form_screen.dart';
import '../../features/reportes/presentation/reportes_screen.dart';
import '../../features/repuestos/presentation/repuestos_list_screen.dart';
import '../../features/repuestos/presentation/repuesto_detail_screen.dart';
import '../../features/repuestos/presentation/repuesto_form_screen.dart';
import '../../features/vehiculos/presentation/vehiculo_detail_screen.dart';
import '../../features/vehiculos/presentation/vehiculo_form_screen.dart';
import '../../features/vehiculos/presentation/vehiculos_list_screen.dart';
import 'app_shell.dart';
import 'go_router_refresh_stream.dart';

/// Rutas que requieren un rol especifico. Si una ruta no aparece aca, cualquier
/// usuario autenticado puede entrar. Esto es UX: la seguridad real la da RLS
/// en Supabase (defensa en profundidad).
final _routeRoleGuards = <String, Set<UserRole>>{
  '/vehiculos/nuevo': {UserRole.administrador, UserRole.jefeTaller},
  '/ordenes-trabajo/nueva': {UserRole.administrador, UserRole.jefeTaller},
  '/checklists/nuevo': {UserRole.administrador, UserRole.jefeTaller},
  '/mantenimiento-preventivo/nuevo': {UserRole.administrador, UserRole.jefeTaller},
  '/repuestos/nuevo': {UserRole.administrador, UserRole.jefeTaller},
  '/configuracion/usuarios': {UserRole.administrador},
};

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(supabaseClientProvider).auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      // Se lee la sesion directamente del cliente (siempre actualizada al
      // instante tras signInWithPassword), no del provider cacheado, para
      // evitar un problema de timing donde el redirect corre antes de que
      // Riverpod propague el cambio de sesion.
      final authUser = ref.read(supabaseClientProvider).auth.currentUser;
      final loggingIn = state.matchedLocation == '/login';

      if (authUser == null) return loggingIn ? null : '/login';
      if (loggingIn) return '/dashboard';

      final usuarioAsync = ref.read(currentUsuarioProvider);
      if (usuarioAsync.isLoading) return null;

      // Si dieron de baja al usuario con la sesion ya abierta, se lo desloguea
      // en cuanto intenta navegar. La base de datos, ademas, ya le nego el
      // acceso a los datos por su cuenta (migracion 0014).
      final usuario = usuarioAsync.value;
      if (usuario != null && !usuario.activo) {
        ref.read(supabaseClientProvider).auth.signOut();
        return '/login';
      }

      final rol = usuario?.rol;

      for (final entry in _routeRoleGuards.entries) {
        if (state.matchedLocation.startsWith(entry.key)) {
          if (rol == null || !entry.value.contains(rol)) return '/dashboard';
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/vehiculos',
              builder: (context, state) => const VehiculosListScreen(),
              routes: [
                GoRoute(
                  path: 'nuevo',
                  builder: (context, state) => const VehiculoFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      VehiculoDetailScreen(vehiculoId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: ':id/editar',
                  builder: (context, state) =>
                      VehiculoFormScreen(vehiculoId: state.pathParameters['id']),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/ordenes-trabajo',
              builder: (context, state) => const OrdenesTrabajoListScreen(),
              routes: [
                GoRoute(
                  path: 'nueva',
                  builder: (context, state) => const OrdenTrabajoFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      OrdenTrabajoDetailScreen(ordenId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: ':id/editar',
                  builder: (context, state) =>
                      OrdenTrabajoFormScreen(ordenId: state.pathParameters['id']),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/checklists',
              builder: (context, state) => const ChecklistsListScreen(),
              routes: [
                GoRoute(
                  path: 'nuevo',
                  builder: (context, state) => const ChecklistFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      ChecklistDetailScreen(checklistId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: ':id/editar',
                  builder: (context, state) =>
                      ChecklistFormScreen(checklistId: state.pathParameters['id']),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/mantenimiento-preventivo',
              builder: (context, state) => const MantenimientoListScreen(),
              routes: [
                GoRoute(
                  path: 'nuevo',
                  builder: (context, state) => const MantenimientoFormScreen(),
                ),
                GoRoute(
                  path: ':id/editar',
                  builder: (context, state) =>
                      MantenimientoFormScreen(mantenimientoId: state.pathParameters['id']),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/novedades',
              builder: (context, state) => const NovedadesListScreen(),
              routes: [
                GoRoute(
                  path: 'nueva',
                  builder: (context, state) => const NovedadFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      NovedadDetailScreen(novedadId: state.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/repuestos',
              builder: (context, state) => const RepuestosListScreen(),
              routes: [
                GoRoute(
                  path: 'nuevo',
                  builder: (context, state) => const RepuestoFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      RepuestoDetailScreen(repuestoId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: ':id/editar',
                  builder: (context, state) =>
                      RepuestoFormScreen(repuestoId: state.pathParameters['id']),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/reportes', builder: (context, state) => const ReportesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/configuracion',
              builder: (context, state) => const ConfiguracionScreen(),
              routes: [
                GoRoute(
                  path: 'usuarios',
                  builder: (context, state) => const UsuariosAdminScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});
