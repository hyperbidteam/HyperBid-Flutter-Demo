import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:mc_sdk/mc_sdk.dart';

import 'ad_config.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const HyperBidDemoApp());
}

class HyperBidDemoApp extends StatefulWidget {
  const HyperBidDemoApp({super.key});

  @override
  State<HyperBidDemoApp> createState() => _HyperBidDemoAppState();
}

class _HyperBidDemoAppState extends State<HyperBidDemoApp> {
  bool _isInitialized = false;
  String _initStatus = 'Initializing SDK...';

  @override
  void initState() {
    super.initState();
    _initializeSdk();
  }

  /// SDK initialization.
  ///
  /// Reference: SDK-Import-and-Initialization.md §5. All global configuration
  /// methods must be called BEFORE `McSdk.initialize()`.
  Future<void> _initializeSdk() async {
    // ==========================================
    // Global Configuration (must be called before initialize)
    // ==========================================

    // Verbose logging follows the build mode; never on in release.
    McSdk.setVerboseLogging(kDebugMode);

    // --- Custom Traffic Segmentation (optional) ---
    // McSdk.setUserId('your user id');
    // McSdk.setChannel('your_channel');
    // McSdk.setSubChannel('your_sub_channel');
    // McSdk.setCustomRule({'key1': 'value1', 'key2': 'value2'});

    // --- Privacy Compliance (optional, configure per the user's region) ---
    // McSdk.setHasUserConsent(true);       // GDPR
    // McSdk.setIsAgeRestrictedUser(false); // COPPA
    // McSdk.setDoNotSell(false);           // CCPA
    // McSdk.setPrivacySettingEnable(true); // Google UMP

    // --- Preset Strategy (optional, improves first-launch fill rate) ---
    // McSdk.setLocalStrategyAssetPath('LocalStrategy');

    // ==========================================
    // Execute Initialization
    // ==========================================
    final McConfiguration? configuration = await McSdk.initialize(
      AdConfig.appId,
      AdConfig.appKey,
    );

    if (!mounted) return;
    setState(() {
      _isInitialized = configuration != null;
      _initStatus =
          _isInitialized ? 'SDK initialized' : 'SDK initialization failed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HyperBid Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: HomeScreen(
        isInitialized: _isInitialized,
        initStatus: _initStatus,
      ),
    );
  }
}
