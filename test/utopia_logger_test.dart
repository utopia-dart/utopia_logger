import 'dart:io';

import 'package:utopia_logger/utopia_logger.dart';
import 'package:test/test.dart';

void main() {

  

  group('testAdapters', () {
    final log = Log(
        action: 'delete.user',
        environment: Environment.production,
        namespace: 'api',
        server: 'utopia-us-1',
        type: LogType.error,
        version: '0.1.1',
        message: 'Unknown user 0023asdf',
        user: User(id: 'abcd1234'));

    log
        .addBreadcrumb(Breadcrumb(
          type: LogType.debug,
          category: 'http',
          message: 'DELETE /api/users',
          timestamp: DateTime.now().millisecondsSinceEpoch - 500,
        ))
        .addBreadcrumb(Breadcrumb(
          type: LogType.debug,
          category: 'auth',
          message: 'Using API key',
          timestamp: DateTime.now().millisecondsSinceEpoch - 400,
        ))
        .addBreadcrumb(Breadcrumb(
          type: LogType.info,
          category: 'auth',
          message: 'Authenticated with * using API Key',
          timestamp: DateTime.now().millisecondsSinceEpoch - 350,
        ));

    log
        .addTag('sdk', 'Flutter')
        .addTag('sdkVersion', '0.0.1')
        .addTag('authMode', 'default')
        .addTag('authMethod', 'cookie')
        .addTag('authProvier', 'MagicLink')
        .addExtra('urgent', false)
        .addExtra('isExpected', true)
        .addExtra('file', '/src/app/server.dart')
        .addExtra('line', 15);
    test('Sentry Adapter Test', () async {
      final adapter = Sentry(
          '${Platform.environment["SENTRY_KEY"]};${Platform.environment["SENTRY_PROJECT"]}');
      final logger = Logger(adapter);
      final response = await logger.addLog(log);
      expect(response, 200);
    });
  });
}
