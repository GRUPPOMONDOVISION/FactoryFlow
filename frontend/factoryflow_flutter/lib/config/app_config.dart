class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:5100',
  );

  static const String codAzi = String.fromEnvironment(
    'COD_AZI',
    defaultValue: 'MOROS',
  );

  static const int esercizio = int.fromEnvironment(
    'ESERCIZIO',
    defaultValue: 2023,
  );

  static const String magazzinoDefault = String.fromEnvironment(
    'MAGAZZINO_DEFAULT',
    defaultValue: '01',
  );
}


