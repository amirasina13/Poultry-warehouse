class VersionLog {
  final String version;
  final Map<String, List<String>> features;

  VersionLog({required this.version, required this.features});

  factory VersionLog.fromJson(Map<String, dynamic> json) {
    return VersionLog(
      version: json['version'] as String,
      features: (json['features'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          List<String>.from(value), // cast each list properly
        ),
      ),
    );
  }
}
