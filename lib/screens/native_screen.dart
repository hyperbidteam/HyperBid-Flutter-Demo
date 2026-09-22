import 'package:flutter/material.dart';
import 'package:mc_sdk/mc_sdk.dart';

import '../ad_config.dart';
import '../widgets/event_console.dart';

/// Native ad screen.
///
/// Native ads use a pure Widget-based integration via `McNativeAdView`.
/// Reference: EN/Ad-Formats/Native.md
class NativeScreen extends StatefulWidget {
  const NativeScreen({super.key});

  @override
  State<NativeScreen> createState() => _NativeScreenState();
}

class _NativeScreenState extends State<NativeScreen> {
  static const double _defaultMediaAspectRatio = 16 / 9;

  final EventConsoleController _console = EventConsoleController();
  final McNativeAdViewController _nativeAdController =
      McNativeAdViewController();

  double _mediaAspectRatio = _defaultMediaAspectRatio;

  @override
  void dispose() {
    _nativeAdController.dispose();
    _console.dispose();
    super.dispose();
  }

  // ===========================================================================
  // Native ad view — EN/Ad-Formats/Native.md §1
  // ===========================================================================

  Widget _buildNativeAd() {
    return McNativeAdView(
      adUnitId: AdConfig.nativeAdUnitId,
      controller: _nativeAdController,
      width: double.infinity,
      height: 300,
      listener: McNativeAdListener(
        onAdLoadedCallback: (ad) {
          _console.log('[Native] loaded ${ad.networkName}');
          setState(() {
            _mediaAspectRatio =
                ad.nativeAd?.mediaContentAspectRatio ?? _defaultMediaAspectRatio;
          });
        },
        onAdLoadFailedCallback: (adUnitId, error) =>
            _console.log('[Native] load failed: ${error.code}'),
        onAdClickedCallback: (ad) => _console.log('[Native] clicked'),
        onAdDisplayedCallback: (ad) => _console.log('[Native] displayed'),
        onAdRevenuePaidCallback: (ad) =>
            _console.log('[Native] revenue ${ad.revenue}'),
      ),
      child: Container(
        color: const Color(0xFFEFEFEF),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const McNativeAdIconView(width: 48, height: 48),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      McNativeAdTitleView(
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                      McNativeAdAdvertiserView(
                        style: TextStyle(fontSize: 10),
                        maxLines: 1,
                      ),
                      McNativeAdStarRatingView(size: 10, color: Colors.amber),
                    ],
                  ),
                ),
                const McNativeAdOptionsView(width: 20, height: 20),
              ],
            ),
            const SizedBox(height: 8),
            const McNativeAdBodyView(
              style: TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: AspectRatio(
                aspectRatio: _mediaAspectRatio,
                child: const McNativeAdMediaView(),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: McNativeAdCallToActionView(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.blue),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNativeAd(),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              _console.log('[Native] reload requested');
              _nativeAdController.loadAd();
            },
            child: const Text('Reload'),
          ),
          const SizedBox(height: 16),
          EventConsole(controller: _console),
        ],
      ),
    );
  }
}
