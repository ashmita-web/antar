import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
    Locale('pt'),
    Locale('ta'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ANTAR'**
  String get appName;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'ANTAR'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bridging citizen voice and public infrastructure'**
  String get welcomeSubtitle;

  /// No description provided for @citizenMode.
  ///
  /// In en, this message translates to:
  /// **'Citizen — Awaaz'**
  String get citizenMode;

  /// No description provided for @citizenModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Report infrastructure needs in your language'**
  String get citizenModeDesc;

  /// No description provided for @officialMode.
  ///
  /// In en, this message translates to:
  /// **'Official — MP Console'**
  String get officialMode;

  /// No description provided for @officialModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Data-driven planning and budget optimization'**
  String get officialModeDesc;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @regionIndia.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get regionIndia;

  /// No description provided for @regionBrazil.
  ///
  /// In en, this message translates to:
  /// **'Brazil'**
  String get regionBrazil;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMode;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @modeSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch Mode'**
  String get modeSwitch;

  /// No description provided for @dataStatus.
  ///
  /// In en, this message translates to:
  /// **'Data & AI Status'**
  String get dataStatus;

  /// No description provided for @geminiStatus.
  ///
  /// In en, this message translates to:
  /// **'Gemini'**
  String get geminiStatus;

  /// No description provided for @mapsStatus.
  ///
  /// In en, this message translates to:
  /// **'Maps'**
  String get mapsStatus;

  /// No description provided for @statusLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get statusLive;

  /// No description provided for @statusCached.
  ///
  /// In en, this message translates to:
  /// **'Cached'**
  String get statusCached;

  /// No description provided for @statusDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get statusDemo;

  /// No description provided for @statusGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get statusGoogleMaps;

  /// No description provided for @statusOsm.
  ///
  /// In en, this message translates to:
  /// **'OpenStreetMap'**
  String get statusOsm;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About ANTAR'**
  String get about;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'ANTAR compares citizen demand with infrastructure deficit and funding coverage to surface silent gaps, recommend high-priority projects, and measure real impact.'**
  String get aboutDescription;

  /// No description provided for @syntheticDataBanner.
  ///
  /// In en, this message translates to:
  /// **'Synthetic demo data'**
  String get syntheticDataBanner;

  /// No description provided for @approxLabel.
  ///
  /// In en, this message translates to:
  /// **'Approx.'**
  String get approxLabel;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @gapMap.
  ///
  /// In en, this message translates to:
  /// **'Gap Map'**
  String get gapMap;

  /// No description provided for @quadrant.
  ///
  /// In en, this message translates to:
  /// **'Quadrant'**
  String get quadrant;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @impact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get impact;

  /// No description provided for @demoMode.
  ///
  /// In en, this message translates to:
  /// **'Demo Mode'**
  String get demoMode;

  /// No description provided for @liveMode.
  ///
  /// In en, this message translates to:
  /// **'Live Mode'**
  String get liveMode;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @silentGaps.
  ///
  /// In en, this message translates to:
  /// **'Silent Gaps'**
  String get silentGaps;

  /// No description provided for @avgPriority.
  ///
  /// In en, this message translates to:
  /// **'Avg Priority'**
  String get avgPriority;

  /// No description provided for @topPriorities.
  ///
  /// In en, this message translates to:
  /// **'Top 5 Priorities'**
  String get topPriorities;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorOccurred;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en', 'hi', 'pt', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return L10nBn();
    case 'en':
      return L10nEn();
    case 'hi':
      return L10nHi();
    case 'pt':
      return L10nPt();
    case 'ta':
      return L10nTa();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
