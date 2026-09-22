import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mc_sdk/mc_sdk.dart';

import '../ad_config.dart';
import '../widgets/event_console.dart';

/// Rewarded video ad screen.
///
/// Demonstrates the two documented integration paths:
///  - Smart Cache    -> EN/Ad-Formats/Rewarded-Video.md (recommended default)
///  - Manual Loading -> EN/Advanced/Manual-Loading/Rewarded-Video.md
class RewardedScreen extends StatefulWidget {
  const RewardedScreen({super.key});

  @override
  State<RewardedScreen> createState() => _RewardedScreenState();
}

class _RewardedScreenState extends State<RewardedScreen> {
  final EventConsoleController _console = EventConsoleController();

  // Smart Cache load is one-shot per screen visit: repeated loads against the
  // same cached slot just burn request quota.
  bool _smartLoadUsed = false;

  final String _adUnitId = AdConfig.rewardedAdUnitId;
  int _retryAttempt = 0;

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
  // Smart Cache — EN/Ad-Formats/Rewarded-Video.md
  // ===========================================================================

  void _setUpSmartCache() {
    McSdk.setSmartCacheRewardedListener(McSmartCacheRewardedListener(
      onDidLoadAd: (ad) => _console.log('[SmartCache] loaded ${ad.networkName}'),
      onDidFailToLoadAd: (error) =>
          _console.log('[SmartCache] load failed: ${error.code}'),
      onDidDisplayAd: (ad) => _console.log('[SmartCache] displayed'),
      onDidHideAd: (ad) => _console.log('[SmartCache] hidden'),
      onDidClickAd: (ad) => _console.log('[SmartCache] clicked'),
      onDidFailToDisplayAd: (ad, error) =>
          _console.log('[SmartCache] display failed: ${error.code}'),
      onDidRewardUserForAd: (ad, reward) => _console.log(
          '[SmartCache] reward ${reward.label} x ${reward.amount}'),
      onDidFailToRewardUserForAd: (ad) =>
          _console.log('[SmartCache] failed to reward user'),
      onDidAdVideoStarted: (ad) => _console.log('[SmartCache] video started'),
      onDidAdVideoCompleted: (ad) =>
          _console.log('[SmartCache] video completed'),
      onDidAdLoadFinished: () => _console.log('[SmartCache] load finished'),
      onDidPayRevenueForAd: (ad) =>
          _console.log('[SmartCache] revenue ${ad.revenue}'),
    ));
  }

  void _smartLoad() {
    if (_smartLoadUsed) return;
    setState(() => _smartLoadUsed = true);
    _console.log('[SmartCache] loading...');
    McSdk.smartSetRewardedAdExtraParameter('key', 'value');
    McSdk.smartSetRewardedAdLocalExtraParameter('key', 'value');
    McSdk.smartLoadRewardedAd();
  }

  Future<void> _smartShow() async {
    final bool? isReady = await McSdk.smartIsRewardedAdReady();
    if (isReady == true) {
      McSdk.smartShowRewardedAd();
    } else {
      _console.log('[SmartCache] not ready');
    }
  }

  // ===========================================================================
  // Manual Loading — EN/Advanced/Manual-Loading/Rewarded-Video.md
  // ===========================================================================

  void _setUpManualLoading() {
    McSdk.setRewardedAdListener(McRewardedAdListener(
      onAdLoadedCallback: (ad) {
        _retryAttempt = 0;
        _console.log('[Manual] loaded ${ad.networkName}');
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        _console.log('[Manual] load failed: ${error.code}');
        _retryAttempt++;
        if (_retryAttempt >= 3) return;
        final delaySeconds = pow(2, min(3, _retryAttempt)).toInt();
        Future.delayed(Duration(seconds: delaySeconds), () {
          if (!mounted) return;
          McSdk.loadRewardedAd(_adUnitId);
        });
      },
      onAdDisplayedCallback: (ad) {
        _console.log('[Manual] displayed');
        McSdk.loadRewardedAd(_adUnitId);
      },
      onAdDisplayFailedCallback: (ad, error) {
        _console.log('[Manual] display failed: ${error.code}');
        McSdk.loadRewardedAd(_adUnitId);
      },
      onAdClickedCallback: (ad) => _console.log('[Manual] clicked'),
      onAdHiddenCallback: (ad) {
        _console.log('[Manual] hidden');
        McSdk.loadRewardedAd(_adUnitId);
      },
      onAdRevenuePaidCallback: (ad) =>
          _console.log('[Manual] revenue ${ad.revenue}'),
      onAdLoadFinishedCallback: (adUnitId) =>
          _console.log('[Manual] load finished'),
      onAdReceivedRewardCallback: (ad, reward) {
        // The only reliable timing to grant rewards.
        _console.log('[Manual] reward ${reward.label} x ${reward.amount}');
      },
      onAdFailedToReceivedRewardCallback: (ad) =>
          _console.log('[Manual] failed to reward user'),
    ));
  }

  void _manualLoad() {
    _console.log('[Manual] loading...');
    McSdk.setRewardedAdExtraParameter(_adUnitId, 'key', 'value');
    McSdk.setRewardedAdLocalExtraParameter(_adUnitId, 'key', 'value');
    McSdk.loadRewardedAd(_adUnitId);
  }

  Future<void> _manualShow() async {
    final bool? isReady = await McSdk.isRewardedAdReady(_adUnitId);
    if (isReady == true) {
      McSdk.showRewardedAd(_adUnitId);
    } else {
      _console.log('[Manual] not ready, reloading...');
      McSdk.loadRewardedAd(_adUnitId);
    }
  }

  Future<void> _checkStatus() async {
    final McAdStatusInfo info = await McSdk.checkRewardedAdStatus(_adUnitId);
    _console.log(
      '[Status] loading=${info.isLoading} ready=${info.isReady} '
      'cached=${info.adList.length}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rewarded Video')),
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
