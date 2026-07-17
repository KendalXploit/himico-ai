import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/settings_providers.dart';

/// App configuration: theme (always dark/cyberpunk by design), notification
/// toggle, language, exchange API keys (secure storage), and risk defaults
/// used by the AI signal engine when sizing entries.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _SectionLabel('Appearance'),
          GlassCard(
            child: Row(
              children: [
                const Icon(Icons.dark_mode_rounded, color: AppColors.neonCyan),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Theme', style: Theme.of(context).textTheme.titleSmall),
                      Text('Cyberpunk Dark (fixed)',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('Notifications'),
          GlassCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Push Notifications'),
              subtitle: const Text('Alerts for new high-confidence signals'),
              value: settings.notificationsEnabled,
              onChanged: controller.setNotifications,
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('Language'),
          GlassCard(
            child: DropdownButtonFormField<String>(
              value: settings.language,
              decoration: const InputDecoration(border: InputBorder.none),
              items: const [
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Indonesian', child: Text('Bahasa Indonesia')),
                DropdownMenuItem(value: 'Chinese', child: Text('中文')),
                DropdownMenuItem(value: 'Spanish', child: Text('Español')),
              ],
              onChanged: (v) => controller.setLanguage(v ?? 'English'),
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('Exchange'),
          GlassCard(
            child: DropdownButtonFormField<String>(
              value: settings.exchange,
              decoration: const InputDecoration(border: InputBorder.none),
              items: const [
                DropdownMenuItem(value: 'Binance Futures', child: Text('Binance Futures')),
                DropdownMenuItem(value: 'Bybit', child: Text('Bybit')),
                DropdownMenuItem(value: 'OKX', child: Text('OKX')),
                DropdownMenuItem(value: 'Bitget', child: Text('Bitget')),
              ],
              onChanged: (v) => controller.setExchange(v ?? 'Binance Futures'),
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('API Keys'),
          const _ApiKeysCard(),
          const SizedBox(height: 20),
          _SectionLabel('Risk Management'),
          GlassCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Risk per Trade'),
                    Text('${settings.riskPerTradePercent.toStringAsFixed(1)}%'),
                  ],
                ),
                Slider(
                  value: settings.riskPerTradePercent,
                  min: 0.25,
                  max: 5,
                  divisions: 19,
                  label: '${settings.riskPerTradePercent.toStringAsFixed(2)}%',
                  onChanged: controller.setRisk,
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Leverage'),
                    Text('${settings.leverage}x'),
                  ],
                ),
                Slider(
                  value: settings.leverage.toDouble(),
                  min: 1,
                  max: 100,
                  divisions: 99,
                  label: '${settings.leverage}x',
                  onChanged: (v) => controller.setLeverage(v.round()),
                ),
                Text(
                  'Only affects position sizing suggestions — HIMICO AI never executes trades automatically.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('Signal Threshold'),
          GlassCard(
            child: Row(
              children: [
                Icon(Icons.verified_rounded, color: AppColors.bullish),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Minimum confidence to publish a trade: ${AppConstants.minSignalConfidence.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '${AppConstants.appName} · v1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _ApiKeysCard extends ConsumerStatefulWidget {
  const _ApiKeysCard();

  @override
  ConsumerState<_ApiKeysCard> createState() => _ApiKeysCardState();
}

class _ApiKeysCardState extends ConsumerState<_ApiKeysCard> {
  final _keyCtrl = TextEditingController();
  final _secretCtrl = TextEditingController();
  bool _saved = false;

  @override
  void dispose() {
    _keyCtrl.dispose();
    _secretCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(secureStorageProvider);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _keyCtrl,
            decoration: const InputDecoration(labelText: 'API Key'),
            obscureText: true,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _secretCtrl,
            decoration: const InputDecoration(labelText: 'API Secret'),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await storage.write(
                        key: AppConstants.secureKeyApiKey, value: _keyCtrl.text);
                    await storage.write(
                        key: AppConstants.secureKeyApiSecret, value: _secretCtrl.text);
                    setState(() => _saved = true);
                  },
                  child: const Text('Save Securely'),
                ),
              ),
            ],
          ),
          if (_saved) ...[
            const SizedBox(height: 8),
            Text(
              'Stored in encrypted device storage.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.bullish,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
