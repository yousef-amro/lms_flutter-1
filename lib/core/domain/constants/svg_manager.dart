class SvgManager {
  SvgManager._();
  static final SvgManager _instance = SvgManager._();
  factory SvgManager() => _instance;

  final String cart = 'assets/svg/cart-icon.svg';
  final String explore = 'assets/svg/explore-icon.svg';
  final String favorite = 'assets/svg/favorite-icon.png';
  final String profile = 'assets/svg/profile-icon.svg';
  final String shop = 'assets/svg/shop-icon.png';
  final String emptyCart = 'assets/svg/empty-cart.svg';
  final String emptyFavorite = 'assets/svg/empty-favourite.svg';
  final String emptyResults = 'assets/svg/empty-result.svg';
  final String emptyOrders = 'assets/svg/empty-orders.svg';
  final String emptyAddresses = 'assets/svg/empty-addresses.svg';

  // Reference auth UI assets (ported)
  String get loginIconCall => 'assets/images/svg/login-icon-call.svg';
  String get loginIconEyeSlash => 'assets/images/svg/login-icon-eye-slash.svg';
  String get loginIconLock => 'assets/images/svg/login-icon-lock.svg';
  String get loginIconToggleOff =>
      'assets/images/svg/login-icon-toggle-off.svg';
  String get loginHeroFrame => 'assets/images/svg/login-hero-frame.svg';
  String get loginHeroEllipse => 'assets/images/svg/login-hero-ellipse.svg';
  String get loginTitleUnderline => 'assets/images/svg/login-title-underline.svg';

  String get registerHeroFrame => 'assets/images/svg/register-hero-frame.svg';
  String get registerHeroEllipse =>
      'assets/images/svg/register-hero-ellipse.svg';
  String get registerTitleUnderline =>
      'assets/images/svg/register-title-underline.svg';
  String get registerIconProfile =>
      'assets/images/svg/register-icon-profile.svg';
  String get registerIconGeneration =>
      'assets/images/svg/register-icon-generation.svg';
  String get registerIconLocation =>
      'assets/images/svg/register-icon-location.svg';
  String get registerIconArrowLeft =>
      'assets/images/svg/register-icon-arrow-left.svg';
}
