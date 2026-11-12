import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../services/notification_service.dart';

/// Mostra os avisos do app como notificações do celular (aparecem no topo
/// da tela por alguns segundos).
///
/// Como funciona (sem Firebase): enquanto o app está aberto ou minimizado, ele
/// consulta a API de tempos em tempos. Cada aviso novo vira uma notificação
/// local e é marcado como lido. O back já respeita as preferências do usuário
/// ao criar o aviso; a chave "push" é respeitada aqui, no aparelho.
///
/// Limite: com o app totalmente fechado nada chega (isso exigiria push real).
class NotificationCenter with WidgetsBindingObserver {
  NotificationCenter._();

  static final NotificationCenter instance = NotificationCenter._();

  static const _channelId = 'aluga_crajubar_avisos';
  static const _pollInterval = Duration(seconds: 20);

  /// Quantidade máxima de avisos exibidos por consulta (os mais antigos só
  /// são marcados como lidos, para não inundar a tela).
  static const _maxPopupsPerPoll = 3;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final Set<String> _shown = {};

  NotificationService? _service;
  Timer? _timer;
  bool _initialized = false;
  bool _permissionGranted = false;
  bool _pushEnabled = true;
  bool _polling = false;
  void Function(String? payload)? _onSelected;

  /// Notificações do sistema só em Android e iOS.
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool get pushEnabled => _pushEnabled;

  /// Liga o monitoramento. [onSelected] recebe o tipo do aviso tocado.
  Future<void> start({void Function(String? payload)? onSelected}) async {
    if (!supported || _timer != null) return;

    _onSelected = onSelected;
    _service = NotificationService();
    WidgetsBinding.instance.addObserver(this);
    // Marca como ativo já, para chamadas repetidas não duplicarem o timer.
    _timer = Timer.periodic(_pollInterval, (_) => _poll());

    try {
      await _init();
      await refreshPreferences();
      await _poll();
    } catch (error) {
      debugPrint('Notificações: não foi possível iniciar ($error)');
    }
  }

  /// Desliga o monitoramento (use ao sair da conta).
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
    _service?.close();
    _service = null;
    _shown.clear();
    _pushEnabled = true;
    _polling = false;

    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  /// Relê a chave "push" do servidor.
  Future<void> refreshPreferences() async {
    final service = _service;
    if (service == null) return;

    try {
      final preferences = await service.getPreferences();
      for (final preference in preferences) {
        if (preference.type == 'push') _pushEnabled = preference.enabled;
      }
    } catch (_) {
      // Mantém o último valor conhecido.
    }
  }

  /// Atualiza a chave "push" na hora (a tela de preferências usa isto).
  void setPushEnabled(bool value) => _pushEnabled = value;

  /// Pede (ou reconfirma) a permissão de notificação do sistema.
  Future<bool> requestPermission() async {
    if (!supported) return false;
    await _init();
    _permissionGranted = await _askPermission();
    return _permissionGranted;
  }

  /// Mostra uma notificação de teste. Devolve false se não foi possível.
  Future<bool> showTest() async {
    if (!supported) return false;
    final allowed = await requestPermission();
    if (!allowed) return false;

    try {
      await _display(
        id: 0,
        title: 'Tudo certo!',
        body: 'As notificações do AlugaCrajubar estão funcionando.',
        payload: 'test',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Ao voltar para o app, confere na hora se há avisos novos.
    if (state == AppLifecycleState.resumed) _poll();
  }

  // ---------------------------------------------------------------------------
  // Internos
  // ---------------------------------------------------------------------------
  Future<void> _init() async {
    if (_initialized) return;

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) =>
          _onSelected?.call(response.payload),
    );

    _permissionGranted = await _askPermission();
    _initialized = true;
  }

  Future<bool> _askPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? true;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;
  }

  Future<void> _poll() async {
    final service = _service;
    if (_polling ||
        service == null ||
        !_initialized ||
        !_pushEnabled ||
        !_permissionGranted) {
      return;
    }

    _polling = true;
    try {
      final unread = await service.getUnread();
      final fresh = unread.where((n) => !_shown.contains(n.id)).toList();
      if (fresh.isEmpty) return;

      // A lista vem da mais recente para a mais antiga; exibimos as mais
      // recentes em ordem cronológica, para a última ficar no topo.
      final toShow = fresh.take(_maxPopupsPerPoll).toList().reversed;
      for (final notification in toShow) {
        await _display(
          id: notification.id.hashCode & 0x7fffffff,
          title: notification.title ?? 'AlugaCrajubar',
          body: notification.message,
          payload: notification.type,
        );
      }

      for (final notification in fresh) {
        _shown.add(notification.id);
        try {
          await service.markAsRead(notification.id);
        } catch (_) {
          // Já está em _shown: não será exibido de novo nesta sessão.
        }
      }
    } on NotificationApiException catch (error) {
      // Sessão encerrada: para de consultar.
      if (error.statusCode == 401) await stop();
    } catch (_) {
      // Falhas de rede são esperadas; tenta de novo no próximo ciclo.
    } finally {
      _polling = false;
    }
  }

  Future<void> _display({
    required int id,
    required String title,
    String? body,
    String? payload,
  }) {
    return _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Avisos do AlugaCrajubar',
          channelDescription: 'Reservas e novidades do AlugaCrajubar',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }
}