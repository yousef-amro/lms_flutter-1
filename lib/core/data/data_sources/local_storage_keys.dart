enum LocalStorageKeys {
  accessToken('ACCESS_TOKEN'),
  refreshToken('REFRESH_TOKEN'),
  accessTokenForResetPassword('ACCESS_TOKEN_FOR_RESET_PASSWORD'),
  languageCode('LANGUAGE_CODE'),
  tokenExpiration('TOKEN_EXPIRATION'),
  themeMode('THEME_MODE'),
  versionName('APP_VERSION_NAME'),
  versionNumber('APP_VERSION_NUMBER'),
  deviceTimezone('DEVICE_TIMEZONE'),
  user('USER_DATA'),
  assignedChatSessions('ASSIGNED_CHAT_SESSIONS');

  final String key;

  const LocalStorageKeys(this.key);
}
