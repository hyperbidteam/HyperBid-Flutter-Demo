import 'dart:io' show Platform;

/// Centralised placeholder IDs for the HyperBid Flutter SDK demo.
///
/// Replace every value below with the real App ID / App Key and Mediation
/// Unit IDs issued for your app in the HyperBid dashboard before running on
/// a device. The strings match the placeholders used in the official
/// integration documentation.
class AdConfig {
  AdConfig._();

  /// App credentials, passed to `McSdk.initialize(appId, appKey)`.
  static final String appId = Platform.isAndroid ? 'j579bc57a7a6d2f7' : 'j867f95860021385';
  static final String appKey = Platform.isAndroid ? 'j5463ef383b9f8f2130a187da2acd04a5912b6856' : 'j86b7fa0a9c07ed80c7ea69c96e41d151beda3a28';

  /// Mediation Unit IDs, one per ad format.
  ///
  /// Smart Cache (the default flow for interstitial / rewarded / app open) does
  /// not need a Mediation Unit ID. These IDs are only used by the Manual
  /// Loading flow and by the banner / MREC / native formats.
  static final String interstitialAdUnitId = Platform.isAndroid ? 'k4e6c26c342233d9' : 'k1e6f3b2716ef70c';
  static final String rewardedAdUnitId = Platform.isAndroid ? 'k65e424add021a2c' : 'k75c51324fd5c7eb';
  static final String appOpenAdUnitId = Platform.isAndroid ? 'k4d9b76d092b9dbf' : 'kd31f42e8f6879ae';
  static final String bannerAdUnitId = Platform.isAndroid ? 'k246320439e4b8f9' : 'k5fd5709fc8a2043';
  static final String mrecAdUnitId = Platform.isAndroid ? 'k3cf9f17f85ad993' : 'k5fd5709fc8a2043';
  static final String nativeAdUnitId = Platform.isAndroid ? 'k76f8c01bc38fbbf' : 'k15ab0be584c9e8e';

}
