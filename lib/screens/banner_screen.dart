import 'package:flutter/material.dart';
import 'package:mc_sdk/mc_sdk.dart';

import '../ad_config.dart';
import '../widgets/event_console.dart';

/// Banner ad screen.
///
/// Demonstrates the two documented integration paths from EN/Ad-Formats/Banner.md:
///  - Programmatic -> created and positioned via `McSdk` static methods
///  - Widget       -> the `McAdView` widget embedded in the widget tree
class BannerScreen extends StatefulWidget {
  const BannerScreen({super.key});

  @override
  State<BannerScreen> createState() => _BannerScreenState();
}

class _BannerScreenState extends State<BannerScreen> {
  final EventConsoleController _console = EventConsoleController();
  final McAdViewController _adViewController = McAdViewController();

  final String _adUnitId = AdConfig.bannerAdUnitId;

  bool _programmaticCreated = false;
  bool _programmaticShowing = false;
  bool _widgetShowing = false;

  // Standard banner slot; the widget is pinned to the page bottom-center.
  static const double _widgetBannerWidth = 320;
  static const double _widgetBannerHeight = 50;

  @override
  void initState() {
    super.initState();
    _setUpProgrammatic();
  }

  @override
  void dispose() {
    if (_programmaticCreated) {
      McSdk.destroyBanner(_adUnitId);
    }
    _adViewController.dispose();
    _console.dispose();
    super.dispose();
  }

  // ===========================================================================
  // Programmatic — EN/Ad-Formats/Banner.md §1 Programmatic
  // ===========================================================================

  void _setUpProgrammatic() {
    McSdk.setBannerListener(McAdViewAdListener(
      onAdLoadedCallback: (ad) => _console.log('[Banner] loaded ${ad.networkName}'),
      onAdLoadFailedCallback: (adUnitId, error) =>
          _console.log('[Banner] load failed: ${error.code}'),
      onAdClickedCallback: (ad) => _console.log('[Banner] clicked'),
      onAdExpandedCallback: (ad) => _console.log('[Banner] expanded'),
      onAdCollapsedCallback: (ad) => _console.log('[Banner] collapsed'),
      onAdDisplayedCallback: (ad) => _console.log('[Banner] displayed'),
      onAdRevenuePaidCallback: (ad) =>
          _console.log('[Banner] revenue ${ad.revenue}'),
      onAdLoadFinishedCallback: (adUnitId) =>
          _console.log('[Banner] load finished'),
    ));
  }

  void _toggleProgrammatic() {
    if (_programmaticShowing) {
      McSdk.hideBanner(_adUnitId);
    } else {
      if (!_programmaticCreated) {
        // Optional custom parameters.
        McSdk.setBannerExtraParameter(_adUnitId, 'key', 'value');
        McSdk.setBannerLocalExtraParameter(_adUnitId, 'key', 'value');
        // Optional scenario ID.
        McSdk.setBannerPlacement(_adUnitId, 'test_scenario_id_banner');
        // Optional background color (hex color string only).
        McSdk.setBannerBackgroundColor(_adUnitId, '#000000');
        // Create banner and specify display position; loading starts here.
        McSdk.createBanner(_adUnitId, AdViewPosition.bottomCenter);
        _programmaticCreated = true;
      }
      McSdk.showBanner(_adUnitId);
    }
    setState(() => _programmaticShowing = !_programmaticShowing);
  }

  Future<void> _logAdaptiveHeight() async {
    final double? height = await McSdk.getAdaptiveBannerHeightForWidth(320.0);
    _console.log('[Banner] adaptive height for 320 = $height');
  }

  // ===========================================================================
  // Widget — EN/Ad-Formats/Banner.md §1 Widget
  // ===========================================================================

  Widget _buildWidgetBanner() {
    return McAdView(
      adUnitId: _adUnitId,
      adFormat: AdFormat.banner,
      controller: _adViewController,
      listener: McAdViewAdListener(
        onAdLoadedCallback: (ad) =>
            _console.log('[Banner widget] loaded ${ad.networkName}'),
        onAdLoadFailedCallback: (adUnitId, error) =>
            _console.log('[Banner widget] load failed: ${error.code}'),
        onAdClickedCallback: (ad) => _console.log('[Banner widget] clicked'),
        onAdExpandedCallback: (ad) => _console.log('[Banner widget] expanded'),
        onAdCollapsedCallback: (ad) =>
            _console.log('[Banner widget] collapsed'),
        onAdDisplayedCallback: (ad) =>
            _console.log('[Banner widget] displayed'),
        onAdRevenuePaidCallback: (ad) =>
            _console.log('[Banner widget] revenue ${ad.revenue}'),
        onAdLoadFinishedCallback: (adUnitId) =>
            _console.log('[Banner widget] load finished'),
      ),
      extraParameters: const {'key': 'value'},
      localExtraParameters: const {'key': 'value'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banner')),
      body: Stack(
        children: [
          ListView(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, _widgetShowing ? 16 + _widgetBannerHeight + 8 : 16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Programmatic',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        onPressed: _widgetShowing ? null : _toggleProgrammatic,
                        child: Text(_programmaticShowing ? 'Hide' : 'Show'),
                      ),
                      FilledButton.tonal(
                        onPressed: _logAdaptiveHeight,
                        child: const Text('Adaptive Height'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Widget',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _programmaticShowing
                        ? null
                        : () => setState(
                            () => _widgetShowing = !_widgetShowing),
                    child: Text(_widgetShowing ? 'Hide' : 'Show'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          EventConsole(controller: _console),
          ],
          ),
          if (_widgetShowing)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: SizedBox(
                  width: _widgetBannerWidth,
                  height: _widgetBannerHeight,
                  child: _buildWidgetBanner(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
