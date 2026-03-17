enum NetworkRouter {
  // Authentication
  login(path: '/api/auth/login/'),
  checkUpdate(path: '/api/shared/app/version/check/'),

  // Dashboard
  sensors(path: '/api/my-sensors/'),

  // Core
  webview(path: '/api/shared/static-pages/'),
  fcmRegister(path: '/api/fcm/register/'),
  privacyPolicy(path: '/api/system/pages/privacy_policy'),
  termsConditions(path: '/api/system/pages/terms_conditions'),
  aboutUs(path: '/api/system/pages/about_us'),

  // Oldest
  refreshToken(path: 'auth/refresh/'),

  // Helper (For external urls [Not base url])
  empty(path: '')
  // Don't remove this ; (It helps with formatting and adding more routes)
  ;

  final String path;
  const NetworkRouter({required this.path});
}
