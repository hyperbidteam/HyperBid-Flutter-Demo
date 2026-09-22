import 'package:flutter/material.dart';
import 'package:mc_sdk/mc_sdk.dart';

import '../ad_config.dart';
import '../widgets/event_console.dart';

/// MREC ad screen.
///
/// Demonstrates the two documented integration paths from EN/Ad-Formats/MREC.md:
///  - Programmatic -> created and positioned via `McSdk` static methods
///  - Widget       -> the `McAdView` widget embedded in the widget tree
class MRecScreen extends StatefulWidget {
  const MRecScreen({super.key});

  @override
  State<MRecScreen> createState() => _MRecScreenState();
}

class _MRecScreenState extends State<MRecScreen> {
  final EventConsoleController _console = EventConsoleController();
  final McAdViewController _adViewController = McAdViewController();

  final String _adUnitId = AdConfig.mrecAdUnitId;

  bool _programmaticCreated = false;
  bool _programmaticShowing = false;
  bool _widgetShowing = false;

  @override
  void initState() {
    super.initState();
    _setUpProgrammatic();
  }

  @override
  void dispose() {
    if (_programmaticCreated) {
      McSdk.destroyMRec(_adUnitId);
    }
    _adViewController.dispose();
    _console.dispose();
    super.dispose();
  }

  // ===========================================================================
  // Programmatic — EN/Ad-Formats/MREC.md §1 Programmatic
  // ===========================================================================

  void _setUpProgrammatic() {
    McSdk.setMRecListener(McAdViewAdListener(
      onAdLoadedCallback: (ad) => _console.log('[MREC] loaded ${ad.networkName}'),
      onAdLoadFailedCallback: (adUnitId, error) =>
          _console.log('[MREC] load failed: ${error.code}'),
      onAdClickedCallback: (ad) => _console.log('[MREC] clicked'),
      onAdExpandedCallback: (ad) => _console.log('[MREC] expanded'),
      onAdCollapsedCallback: (ad) => _console.log('[MREC] collapsed'),
      onAdDisplayedCallback: (ad) => _console.log('[MREC] displayed'),
      onAdRevenuePaidCallback: (ad) =>
          _console.log('[MREC] revenue ${ad.revenue}'),
      onAdLoadFinishedCallback: (adUnitId) =>
          _console.log('[MREC] load finished'),
    ));
  }

  void _toggleProgrammatic() {
    if (_programmaticShowing) {
      McSdk.hideMRec(_adUnitId);
    } else {
      if (!_programmaticCreated) {
        // Optional custom parameters.
        McSdk.setMRecExtraParameter(_adUnitId, 'key', 'value');
        McSdk.setMRecLocalExtraParameter(_adUnitId, 'key', 'value');
        // Optional scenario ID.
        McSdk.setMRecPlacement(_adUnitId, 'test_scenario_id_mrec');
        // Create MREC and specify display position; loading starts here.
        McSdk.createMRec(_adUnitId, AdViewPosition.bottomCenter);
        _programmaticCreated = true;
      }
      McSdk.showMRec(_adUnitId);
    }
    setState(() => _programmaticShowing = !_programmaticShowing);
  }

  // ===========================================================================
  // Widget — EN/Ad-Formats/MREC.md §1 Widget
  // ===========================================================================

  Widget _buildWidgetMRec() {
    return McAdView(
      adUnitId: _adUnitId,
      adFormat: AdFormat.mrec,
      controller: _adViewController,
      listener: McAdViewAdListener(
        onAdLoadedCallback: (ad) =>
            _console.log('[MREC widget] loaded ${ad.networkName}'),
        onAdLoadFailedCallback: (adUnitId, error) =>
            _console.log('[MREC widget] load failed: ${error.code}'),
        onAdClickedCallback: (ad) => _console.log('[MREC widget] clicked'),
        onAdExpandedCallback: (ad) => _console.log('[MREC widget] expanded'),
        onAdCollapsedCallback: (ad) => _console.log('[MREC widget] collapsed'),
        onAdDisplayedCallback: (ad) => _console.log('[MREC widget] displayed'),
        onAdRevenuePaidCallback: (ad) =>
            _console.log('[MREC widget] revenue ${ad.revenue}'),
        onAdLoadFinishedCallback: (adUnitId) =>
            _console.log('[MREC widget] load finished'),
      ),
      extraParameters: const {'key': 'value'},
      localExtraParameters: const {'key': 'value'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MREC')),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                  FilledButton(
                    onPressed: _widgetShowing ? null : _toggleProgrammatic,
                    child: Text(_programmaticShowing ? 'Hide' : 'Show'),
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
                  if (_widgetShowing) ...[
                    const SizedBox(height: 12),
                    Center(child: _buildWidgetMRec()),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          EventConsole(controller: _console),
        ],
      ),
    );
  }
}
