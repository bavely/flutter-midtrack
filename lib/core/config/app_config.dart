class AppConfig {
  final String apiBaseUrl;

  const AppConfig._({required this.apiBaseUrl});

  factory AppConfig() {
    const override =
        String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (override.isNotEmpty) {
      return AppConfig._(apiBaseUrl: override);
    }

    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    switch (env) {
      case 'emulator':
        return AppConfig._(apiBaseUrl: 'http://10.0.2.2:8000/graphql');
      case 'production':
        return AppConfig._(
            apiBaseUrl: 'https://midtrack.example.com/graphql');
      case 'development':
      default:
        return AppConfig._(apiBaseUrl: 'http://192.168.50.5:8000/graphql');
    }
  }
}

