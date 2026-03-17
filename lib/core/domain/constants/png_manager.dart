class ImageManager {
  ImageManager._();
  static final ImageManager _instance = ImageManager._();
  factory ImageManager() => _instance;

  // These map to existing assets in this app.
  // (The reference project expects these names for auth UI.)
  String get logo => 'assets/images/logo.png';
  String get logoIconColored => 'assets/images/logo-icon-colored.png';

  // Auth hero images (fallback to existing images)
  String get loginHero => 'assets/images/join-yotel-community.png';
  String get registerHero => 'assets/images/join-yotel-community.png';
}

