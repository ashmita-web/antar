abstract final class Env {
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const googleMapsKey = String.fromEnvironment('GOOGLE_MAPS_KEY');
  static const firebaseConfigured = String.fromEnvironment(
    'FIREBASE_CONFIGURED',
    defaultValue: 'false',
  );

  static bool get hasGemini => geminiApiKey.isNotEmpty;
  static bool get hasMaps => googleMapsKey.isNotEmpty;
  static bool get hasFirebase => firebaseConfigured == 'true';
  static bool get isDemoMode => !hasFirebase;
}
