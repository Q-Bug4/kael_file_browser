import 'dart:io';

class Util {
  static String getUserDirectory() {
    String home = "/";
    Map<String, String> envVars = Platform.environment;
    if (Platform.isMacOS) {
      home = envVars['HOME'] ?? home;
    } else if (Platform.isLinux) {
      home = envVars['HOME'] ?? home;
    } else if (Platform.isWindows) {
      home = envVars['UserProfile'] ?? home;
    }
    return home;
  }
}
