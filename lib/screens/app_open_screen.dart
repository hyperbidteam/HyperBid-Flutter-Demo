import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mc_sdk/mc_sdk.dart';

import '../ad_config.dart';
import '../widgets/event_console.dart';

/// App open ad screen.
///
/// Demonstrates the two documented integration paths:
///  - Smart Cache    -> EN/Ad-Formats/App-Open.md (recommended default)
///  - Manual Loading -> EN/Advanced/Manual-Loading/App-Open.md
class AppOpenScreen extends StatefulWidget {
  const AppOpenScreen({super.key});

  @override
  State<AppOpenScreen> createState() => _AppOpenScreenState();
}

class _AppOpenScreenState extends State<AppOpenScreen> {
  final EventConsoleController _console = EventConsoleController();

  // Smart Cache load is one-shot per screen visit: repeated loads against the
  // same cached slot just burn request quota.
  bool _smartLoadUsed = false;

  final String _adUnitId = AdConfig.appOpenAdUnitId;

  @override
  void initState() {
    super.initState();
    _setUpSmartCache();
    _setUpManualLoading();
  }

  @override
  void dispose() {
    _console.dispose();
    super.dispose();
  }

  // ===========================================================================
  // Smart Cache — EN/Ad-Formats/App-Open.md
  // ===========================================================================

  void _setUpSmartCache() {
    McSdk.setSmartCacheAppOpenListener(McSmartCacheAppOpenListener(
      onDidLoadAd: (ad) => _console.log('[SmartCache] loaded ${ad.networkName}'),
      onDidFailToLoadAd: (error) =>
          _console.log('[SmartCache] load failed: ${error.code}'),
      onDidDisplayAd: (ad) => _console.log('[SmartCache] displayed'),
      onDidHideAd: (ad) => _console.log('[SmartCache] hidden'),
      onDidClickAd: (ad) => _console.log('[SmartCache] clicked'),
      onDidFailToDisplayAd: (ad, error) =>
          _console.log('[SmartCache] display failed: ${error.code}'),
      onDidAdLoadTimeout: () => _console.log('[SmartCache] load timeout'),
      onDidAdLoadFinished: () => _console.log('[SmartCache] load finished'),
      onDidPayRevenueForAd: (ad) =>
          _console.log('[SmartCache] revenue ${ad.revenue}'),
    ));
  }

  void _smartLoad() {
    if (_smartLoadUsed) return;
    setState(() => _smartLoadUsed = true);
    _console.log('[SmartCache] loading...');
    McSdk.smartSetAppOpenAdExtraParameter('key', 'value');
    McSdk.smartSetAppOpenAdLocalExtraParameter('key', 'value');
    // Optional load timeout in milliseconds.
    McSdk.smartLoadAppOpenAd(timeout: 5000);
  }

  Future<void> _smartShow() async {
    final bool? isReady = await McSdk.smartIsAppOpenAdReady();
    if (isReady == true) {
      McSdk.smartShowAppOpenAd();
    } else {
      _console.log('[SmartCache] not ready');
    }
  }

  // ===========================================================================
  // Manual Loading — EN/Advanced/Manual-Loading/App-Open.md
  // ===========================================================================

  void _setUpManualLoading() {
    McSdk.setAppOpenAdListener(McAppOpenAdListener(
      onAdLoadedCallback: (ad) =>
          _console.log('[Manual] loaded ${ad.networkName}'),
      onAdLoadFailedCallback: (adUnitId, error) {
        // App open ads rely on the timeout mechanism; no manual retry needed.
        _console.log('[Manual] load failed: ${error.code}');
      },
      onAdLoadTimeoutCallback: (adUnitId) =>
          _console.log('[Manual] load timeout'),
      onAdDisplayedCallback: (ad) {
        _console.log('[Manual] displayed');
        // Preload next ad (recommended for warm start).
        // McSdk.loadAppOpenAd(_adUnitId);
      },
      onAdDisplayFailedCallback: (ad, error) =>
          _console.log('[Manual] display failed: ${error.code}'),
      onAdClickedCallback: (ad) => _console.log('[Manual] clicked'),
      onAdHiddenCallback: (ad) => _console.log('[Manual] hidden'),
      onAdRevenuePaidCallback: (ad) =>
          _console.log('[Manual] revenue ${ad.revenue}'),
      onAdLoadFinishedCallback: (adUnitId) =>
          _console.log('[Manual] load finished'),
    ));
  }

  void _manualLoad() {
    _console.log('[Manual] loading...');
    McSdk.setAppOpenAdExtraParameter(_adUnitId, 'key', 'value');
    McSdk.setAppOpenAdLocalExtraParameter(_adUnitId, 'key', 'value');
    // timeout is in milliseconds; pass -1 to disable.
    McSdk.loadAppOpenAd(_adUnitId, timeout: 5000);
  }

  Future<void> _manualShow() async {
    final bool? isReady = await McSdk.isAppOpenAdReady(_adUnitId);
    if (isReady == true) {
      McSdk.showAppOpenAd(_adUnitId);
    } else {
      _console.log('[Manual] not ready, reloading...');
      McSdk.loadAppOpenAd(_adUnitId);
    }
  }

  Future<void> _checkStatus() async {
    final McAdStatusInfo info = await McSdk.checkAppOpenAdStatus(_adUnitId);
    _console.log(
      '[Status] loading=${info.isLoading} ready=${info.isReady} '
      'cached=${info.adList.length}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Open')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            title: 'Smart Cache (recommended)',
            children: [
              FilledButton(onPressed: _smartLoadUsed ? null : _smartLoad, child: const Text('Load')),
              FilledButton(onPressed: _smartShow, child: const Text('Show')),
            ],
          ),
          const SizedBox(height: 12),
          _card(
            title: 'Manual Loading',
            children: [
              FilledButton.tonal(
                  onPressed: _manualLoad, child: const Text('Load')),
              FilledButton.tonal(
                  onPressed: _manualShow, child: const Text('Show')),
              FilledButton.tonal(
                  onPressed: _checkStatus, child: const Text('Check Status')),
            ],
          ),
          const SizedBox(height: 16),
          EventConsole(controller: _console),
        ],
      ),
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: children),
          ],
        ),
      ),
    );
  }
}
