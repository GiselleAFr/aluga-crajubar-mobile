import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ações que saem do app: WhatsApp, mapas e área de transferência.
/// Reutilizável por inquilino e locador.
class ExternalLinks {
  const ExternalLinks._();

  /// Normaliza para o formato do wa.me (DDI + DDD + número).
  static String? whatsappNumber(String? telefone) {
    final digitos = (telefone ?? '').replaceAll(RegExp(r'\D'), '');
    if (digitos.isEmpty) return null;
    if (digitos.startsWith('55') && digitos.length >= 12) return digitos;
    if (digitos.length == 10 || digitos.length == 11) return '55$digitos';
    return digitos;
  }

  static bool hasPhone(String? telefone) => whatsappNumber(telefone) != null;

  static Future<void> openWhatsapp(
    BuildContext context,
    String? telefone, {
    String? message,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final numero = whatsappNumber(telefone);

    if (numero == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Telefone não informado.')),
      );
      return;
    }

    final texto = (message == null || message.isEmpty)
        ? ''
        : '?text=${Uri.encodeComponent(message)}';
    final uri = Uri.parse('https://wa.me/$numero$texto');

    try {
      final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!abriu) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  static Future<void> copy(
    BuildContext context,
    String texto, {
    String confirmacao = 'Copiado.',
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: texto));
    messenger.showSnackBar(SnackBar(content: Text(confirmacao)));
  }

  static Future<void> openMaps(
    BuildContext context,
    double latitude,
    double longitude,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!abriu) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o Google Maps.')),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o Google Maps.')),
      );
    }
  }
}