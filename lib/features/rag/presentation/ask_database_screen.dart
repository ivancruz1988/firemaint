import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/snackbar_error.dart';
import '../application/ask_database_providers.dart';

/// Consulta en lenguaje natural sobre los datos del cuartel. La respuesta la
/// arma la Edge Function `ask-database` con el contexto que encuentra en la
/// base, no es conocimiento general del modelo.
class AskDatabaseScreen extends ConsumerStatefulWidget {
  const AskDatabaseScreen({super.key});

  @override
  ConsumerState<AskDatabaseScreen> createState() => _AskDatabaseScreenState();
}

class _AskDatabaseScreenState extends ConsumerState<AskDatabaseScreen> {
  final _controller = TextEditingController();
  bool _consultando = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Solo la consulta: la pregunta ya quedo escrita en la conversacion, asi
  /// que reintentar no la duplica.
  Future<void> _consultar(String texto) async {
    if (_consultando) return;
    setState(() => _consultando = true);
    try {
      await ref.read(chatProvider.notifier).responder(texto);
    } catch (e) {
      if (mounted) {
        mostrarErrorConReintento(context, e, () => _consultar(texto), accion: 'hacer la consulta');
      }
    } finally {
      if (mounted) setState(() => _consultando = false);
    }
  }

  void _enviarDelCampo() {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _consultando) return;
    _controller.clear();
    ref.read(chatProvider.notifier).anotarPregunta(texto);
    _consultar(texto);
  }

  @override
  Widget build(BuildContext context) {
    final mensajes = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultar datos'),
        actions: [
          if (mensajes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Limpiar conversacion',
              onPressed: () => ref.read(chatProvider.notifier).limpiar(),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: mensajes.isEmpty
                ? const _SinMensajes()
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: mensajes.length,
                    itemBuilder: (context, i) =>
                        _Burbuja(mensaje: mensajes[mensajes.length - 1 - i]),
                  ),
          ),
          if (_consultando) const LinearProgressIndicator(minHeight: 2),
          _CampoPregunta(
            controller: _controller,
            habilitado: !_consultando,
            onEnviar: _enviarDelCampo,
          ),
        ],
      ),
    );
  }
}

class _SinMensajes extends StatelessWidget {
  const _SinMensajes();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.smart_toy_outlined, size: 56, color: AppColors.textoTenue),
            const SizedBox(height: 16),
            const Text(
              'Preguntá sobre la flota',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Por ejemplo: "que ordenes estan pendientes", '
              '"que repuestos tienen stock bajo".',
              style: AppTextStyles.label,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Burbuja extends StatelessWidget {
  const _Burbuja({required this.mensaje});

  final MensajeChat mensaje;

  @override
  Widget build(BuildContext context) {
    final esUsuario = mensaje.esDelUsuario;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: esUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: esUsuario ? AppColors.rojoBombero : AppColors.superficie,
                borderRadius: BorderRadius.circular(14),
                border: esUsuario ? null : Border.all(color: AppColors.borde),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mensaje.texto,
                    style: AppTextStyles.body.copyWith(
                      color: esUsuario ? AppColors.blanco : AppColors.textoPrincipal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _hora(mensaje.hora),
                    style: AppTextStyles.caption.copyWith(
                      color: esUsuario
                          ? AppColors.blanco.withValues(alpha: 0.7)
                          : AppColors.textoTenue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _hora(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _CampoPregunta extends StatelessWidget {
  const _CampoPregunta({
    required this.controller,
    required this.habilitado,
    required this.onEnviar,
  });

  final TextEditingController controller;
  final bool habilitado;
  final VoidCallback onEnviar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borde)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: habilitado,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onEnviar(),
              decoration: const InputDecoration(hintText: 'Escribi tu consulta...'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: habilitado ? onEnviar : null,
            icon: const Icon(Icons.send),
            tooltip: 'Consultar',
          ),
        ],
      ),
    );
  }
}
