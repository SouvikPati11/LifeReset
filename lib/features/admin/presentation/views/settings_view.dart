import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/content_keys.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/admin_models.dart';
import '../controllers/admin_controllers.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_widgets.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(settingsProvider);
    final textTheme = Theme.of(context).textTheme;

    return async.when(
      loading: () => const LoadingView(),
      error: (_, __) => const Center(child: Text('Could not load settings')),
      data: (settings) => ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          Text('Settings', style: textTheme.titleLarge),
          const SizedBox(height: AppSizes.md),
          _SettingsForm(settings: settings),
        ],
      ),
    );
  }
}

class _SettingsForm extends ConsumerStatefulWidget {
  const _SettingsForm({required this.settings});
  final AppSettings settings;
  @override
  ConsumerState<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<_SettingsForm> {
  late final _version =
      TextEditingController(text: widget.settings.appVersion);
  late final _language =
      TextEditingController(text: widget.settings.defaultLanguage);
  late final _support =
      TextEditingController(text: widget.settings.supportEmail);
  late final _supportPhone =
      TextEditingController(text: widget.settings.supportPhone);
  late final _supportMessage =
      TextEditingController(text: widget.settings.supportMessage);
  late final _privacy = TextEditingController(text: widget.settings.privacyUrl);
  late final _terms = TextEditingController(text: widget.settings.termsUrl);
  late bool _maintenance = widget.settings.maintenanceMode;

  @override
  void dispose() {
    _version.dispose();
    _language.dispose();
    _support.dispose();
    _supportPhone.dispose();
    _supportMessage.dispose();
    _privacy.dispose();
    _terms.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ok = await ref.read(adminWriteControllerProvider.notifier).save(
      'app_config',
      'general',
      {
        'appVersion': _version.text.trim(),
        'maintenanceMode': _maintenance,
        'defaultLanguage': _language.text.trim(),
        ContentKeys.supportEmail: _support.text.trim(),
        ContentKeys.supportPhone: _supportPhone.text.trim(),
        ContentKeys.supportMessage: _supportMessage.text.trim(),
        'privacyUrl': _privacy.text.trim(),
        'termsUrl': _terms.text.trim(),
      },
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Settings saved' : 'Could not save')),
    );
  }

  Widget _field(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.md),
        child: TextField(
          controller: c,
          decoration: InputDecoration(labelText: label),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(adminWriteControllerProvider).isLoading;
    return ACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(_version, 'App Version'),
          _field(_language, 'Default Language'),
          _field(_support, 'Support Email'),
          _field(_supportPhone, 'Support Phone'),
          _field(_supportMessage, 'Support Message / Instructions'),
          _field(_privacy, 'Privacy Policy URL'),
          _field(_terms, 'Terms of Service URL'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Maintenance Mode'),
            subtitle: const Text('Temporarily restrict access to the app'),
            value: _maintenance,
            onChanged: (v) => setState(() => _maintenance = v),
          ),
          const SizedBox(height: AppSizes.md),
          FilledButton.icon(
            onPressed: saving ? null : _save,
            icon: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            label: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}
