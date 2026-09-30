// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class L10nPt extends L10n {
  L10nPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'ANTAR';

  @override
  String get welcomeTitle => 'ANTAR';

  @override
  String get welcomeSubtitle =>
      'Conectando a voz do cidadão à infraestrutura pública';

  @override
  String get citizenMode => 'Cidadão — Voz';

  @override
  String get citizenModeDesc => 'Relate necessidades no seu idioma';

  @override
  String get officialMode => 'Oficial — Painel do Representante';

  @override
  String get officialModeDesc => 'Planejamento baseado em dados';

  @override
  String get continueButton => 'Continuar';

  @override
  String get settings => 'Configurações';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get region => 'Região';

  @override
  String get regionIndia => 'Índia';

  @override
  String get regionBrazil => 'Brasil';

  @override
  String get appLanguage => 'Idioma do App';

  @override
  String get themeMode => 'Tema';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Escuro';

  @override
  String get modeSwitch => 'Trocar Modo';

  @override
  String get dataStatus => 'Status de Dados & IA';

  @override
  String get geminiStatus => 'Gemini';

  @override
  String get mapsStatus => 'Mapas';

  @override
  String get statusLive => 'Ao Vivo';

  @override
  String get statusCached => 'Em Cache';

  @override
  String get statusDemo => 'Demo';

  @override
  String get statusGoogleMaps => 'Google Maps';

  @override
  String get statusOsm => 'OpenStreetMap';

  @override
  String get about => 'Sobre o ANTAR';

  @override
  String get aboutDescription =>
      'O ANTAR compara a demanda cidadã com o déficit de infraestrutura para identificar lacunas silenciosas e recomendar projetos prioritários.';

  @override
  String get syntheticDataBanner => 'Dados de demonstração sintéticos';

  @override
  String get approxLabel => 'Aprox.';

  @override
  String get home => 'Início';

  @override
  String get gapMap => 'Mapa de Lacunas';

  @override
  String get quadrant => 'Quadrante';

  @override
  String get budget => 'Orçamento';

  @override
  String get impact => 'Impacto';

  @override
  String get demoMode => 'Modo Demo';

  @override
  String get liveMode => 'Modo Ativo';

  @override
  String get requests => 'Solicitações';

  @override
  String get languages => 'Idiomas';

  @override
  String get silentGaps => 'Lacunas Silenciosas';

  @override
  String get avgPriority => 'Prioridade Média';

  @override
  String get topPriorities => 'Top 5 Prioridades';

  @override
  String get noDataAvailable => 'Sem dados disponíveis';

  @override
  String get errorOccurred => 'Algo deu errado';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get loading => 'Carregando…';
}
