class TvAuthSession {
  static bool _isPaired = false;
  static Map<String, dynamic>? _pairedUser;

  static bool get isPaired => _isPaired;
  static Map<String, dynamic>? get pairedUser => _pairedUser;

  static void setSession(Map<String, dynamic> user) {
    _isPaired = true;
    _pairedUser = user;
  }

  static void clearSession() {
    _isPaired = false;
    _pairedUser = null;
  }
}
