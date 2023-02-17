import 'package:utopia_logger/utopia_logger.dart';

void main() {
  final log = Log(
    action: 'user.delete',
    environment: Environment.production,
    namespace: 'api',
    message: 'User 00ffdd not found',
    type: LogType.error,
    version: '0.12.0',
    user: User(id: '00ff22'),
    server: 'dart-server',
    timestamp: DateTime.now().millisecondsSinceEpoch,
  );

  log.addBreadcrumb(Breadcrumb(
      type: LogType.debug,
      category: 'http',
      message: 'DELETE /api/users',
      timestamp: DateTime.now().millisecondsSinceEpoch));

  log
      .addTag('sdk', 'flutter')
      .addTag('sdkVersion', '0.0.1')
      .addExtra('urgent', false);

  Adapter adapter = Sentry('YOUR_SENTRY_KEY', 'YOUR_SENTRY_PROJECT_ID');
  Logger logger = Logger(adapter);
  logger.addLog(log);

  adapter = Raygun('YOUR_API_KEY');
  logger = Logger(adapter);
  logger.addLog(log);

}
