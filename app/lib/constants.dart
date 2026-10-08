/// Central application constants.
///
/// NOTE: The stubble purchase price is centrally configured here per UX rules.
class AppConstants {
  /// Assumed purchase price per tonne of dry paddy stubble (in INR).
  /// This value is referenced across the UI and agronomic calculations.
  static const double assumedPricePerTonneInr = 1200.0;

  /// Default network timeout duration for backend calls.
  static const Duration networkTimeout = Duration(seconds: 60);

  /// Key names for flutter_secure_storage.
  static const String keyAccessToken = 'jwt_access_token';
  static const String keyRefreshToken = 'jwt_refresh_token';
  static const String keyFarmerId = 'farmer_id';
  static const String keyLanguage = 'user_language';
  static const String keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String keyCachedProfile = 'cached_user_profile';
}
