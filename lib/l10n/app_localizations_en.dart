// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ANTAR';

  @override
  String get welcomeTitle => 'ANTAR';

  @override
  String get welcomeSubtitle =>
      'Bridging citizen voice and public infrastructure';

  @override
  String get citizenMode => 'Citizen — Awaaz';

  @override
  String get citizenModeDesc => 'Report infrastructure needs in your language';

  @override
  String get officialMode => 'Official — MP Console';

  @override
  String get officialModeDesc => 'Data-driven planning and budget optimization';

  @override
  String get continueButton => 'Continue';

  @override
  String get settings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get region => 'Region';

  @override
  String get regionIndia => 'India';

  @override
  String get regionBrazil => 'Brazil';

  @override
  String get appLanguage => 'App Language';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get modeSwitch => 'Switch Mode';

  @override
  String get dataStatus => 'Data & AI Status';

  @override
  String get geminiStatus => 'Gemini';

  @override
  String get mapsStatus => 'Maps';

  @override
  String get statusLive => 'Live';

  @override
  String get statusCached => 'Cached';

  @override
  String get statusDemo => 'Demo';

  @override
  String get statusGoogleMaps => 'Google Maps';

  @override
  String get statusOsm => 'OpenStreetMap';

  @override
  String get about => 'About ANTAR';

  @override
  String get aboutDescription =>
      'ANTAR compares citizen demand with infrastructure deficit and funding coverage to surface silent gaps, recommend high-priority projects, and measure real impact.';

  @override
  String get syntheticDataBanner => 'Synthetic demo data';

  @override
  String get approxLabel => 'Approx.';

  @override
  String get home => 'Home';

  @override
  String get gapMap => 'Gap Map';

  @override
  String get quadrant => 'Quadrant';

  @override
  String get budget => 'Budget';

  @override
  String get impact => 'Impact';

  @override
  String get demoMode => 'Demo Mode';

  @override
  String get liveMode => 'Live Mode';

  @override
  String get requests => 'Requests';

  @override
  String get languages => 'Languages';

  @override
  String get silentGaps => 'Silent Gaps';

  @override
  String get avgPriority => 'Avg Priority';

  @override
  String get topPriorities => 'Top 5 Priorities';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get errorOccurred => 'Something went wrong';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get loading => 'Loading…';
}
