class AppConstants {
  AppConstants._();

  // Android Emulator  : http://10.0.2.2:8080/api/v1
  // iOS Simulator     : http://localhost:8080/api/v1
  // Physical Device   : http://<YOUR_LOCAL_IP>:8080/api/v1  ← ganti ini
  static const String baseUrl = 'http://192.168.10.244:8080/api/v1';
  static const String tasksEndpoint = '/tasks';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int defaultPerPage = 10;
  static const String cachedTasksKey = 'cached_tasks';
  static const String cacheTimestampKey = 'cache_timestamp';
  static const int cacheExpiryMinutes = 5;
}
