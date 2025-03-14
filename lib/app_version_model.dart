class AppVersion {
  final String version;
  final String minAppVersion;
  final String? about;

  AppVersion({
    required this.version,
    required this.minAppVersion,
    this.about,
  });

  factory AppVersion.fromJson(Map<String, dynamic>? json) {
    return AppVersion(
      version: json?['version'] ?? '1.0.0',
      minAppVersion: json?['minAppVersion'] ?? '1.0.0',
      about: json?['about'],
    );
  }

  static Future<AppVersion?> fetchLatestVersion() async {
    final Map<String, dynamic>? appVersion = {
      'version': '1.0.0',
      'minAppVersion': '1.1.0',
      'about': 'مميزات جديدة والمزيد',
    };
    return AppVersion.fromJson(appVersion);
  }
}
