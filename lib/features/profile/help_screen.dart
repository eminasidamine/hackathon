import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/settings_controller.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/catalog_service.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _catalog = CatalogService();
  late Future<AppSettings> _future;

  @override
  void initState() {
    super.initState();
    _future = _catalog.fetchAppSettings();
  }

  Future<void> _openWhatsapp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWebsite(String url) async {
    final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        surfaceTintColor: AppTheme.bg,
        iconTheme: const IconThemeData(color: AppTheme.ink),
        title: Text(t('help_support'),
            style: const TextStyle(color: AppTheme.ink)),
      ),
      body: SafeArea(
        child: FutureBuilder<AppSettings>(
          future: _future,
          builder: (context, snapshot) {
            final settings = snapshot.data ?? AppSettings();
            final hasPhone = settings.contactPhone != null &&
                settings.contactPhone!.isNotEmpty;
            final hasWebsite =
                settings.websiteUrl != null && settings.websiteUrl!.isNotEmpty;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Icon(Icons.support_agent,
                    size: 56, color: AppTheme.muted),
                const SizedBox(height: 16),
                Text(
                  t('help_support'),
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Une question sur une commande, un paiement ou une boutique ? '
                  'Contact us directly, we reply fast.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.ink2),
                ),
                const SizedBox(height: 24),
                if (hasPhone)
                  FilledButton.icon(
                    onPressed: () => _openWhatsapp(settings.contactPhone!),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(t('contact_whatsapp')),
                  ),
                if (hasWebsite) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => _openWebsite(settings.websiteUrl!),
                    icon: const Icon(Icons.public, size: 18),
                    label: const Text('Voir le site'),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
