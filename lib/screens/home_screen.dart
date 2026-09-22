import 'package:flutter/material.dart';

import 'app_open_screen.dart';
import 'banner_screen.dart';
import 'interstitial_screen.dart';
import 'mrec_screen.dart';
import 'native_screen.dart';
import 'rewarded_screen.dart';

/// Entry screen: routes to one screen per ad format. Each format screen
/// mirrors exactly one document under `EN/Ad-Formats`.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.isInitialized,
    required this.initStatus,
  });

  final bool isInitialized;
  final String initStatus;

  @override
  Widget build(BuildContext context) {
    final entries = <_AdFormatEntry>[
      _AdFormatEntry('Interstitial', Icons.fullscreen,
          (_) => const InterstitialScreen()),
      _AdFormatEntry('Rewarded Video', Icons.card_giftcard,
          (_) => const RewardedScreen()),
      _AdFormatEntry('App Open', Icons.open_in_new,
          (_) => const AppOpenScreen()),
      _AdFormatEntry('Banner', Icons.view_day, (_) => const BannerScreen()),
      _AdFormatEntry('MREC', Icons.crop_square, (_) => const MRecScreen()),
      _AdFormatEntry('Native', Icons.dashboard_customize,
          (_) => const NativeScreen()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('HyperBid Flutter Demo')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: isInitialized
                ? Colors.green.shade50
                : Colors.orange.shade50,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  isInitialized ? Icons.check_circle : Icons.hourglass_top,
                  color: isInitialized ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(initStatus)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  child: ListTile(
                    leading: Icon(entry.icon),
                    title: Text(entry.title),
                    trailing: const Icon(Icons.chevron_right),
                    enabled: isInitialized,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: entry.builder),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdFormatEntry {
  const _AdFormatEntry(this.title, this.icon, this.builder);

  final String title;
  final IconData icon;
  final WidgetBuilder builder;
}
