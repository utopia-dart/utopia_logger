import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:utopia_logger/src/adapter.dart';
import 'package:utopia_logger/src/log/log_type.dart';
import 'package:utopia_logger/src/log/environment.dart';
import 'package:utopia_logger/src/log.dart';
import 'package:utopia_logger/src/logger.dart';

class Sentry extends Adapter {
  late final String _sentryKey;
  late final String _projectId;
  late final String _sentryHost;

  Sentry(String configKey) {
    final chunks = configKey.split(';');
    _sentryKey = chunks.first;
    _projectId = chunks[1];
    _sentryHost = chunks.length > 2 && chunks[2].isNotEmpty
        ? chunks[2]
        : 'https://sentry.io';
  }

  static String getName() => 'sentry';

  @override
  List<LogType> getSupportedBreadcrumbTypes() {
    return [
      LogType.info,
      LogType.debug,
      LogType.warning,
      LogType.error,
    ];
  }

  @override
  List<Environment> getSupportedEnvironments() {
    return Environment.values;
  }

  @override
  List<LogType> getSupportedTypes() {
    return [
      LogType.info,
      LogType.debug,
      LogType.warning,
      LogType.error,
    ];
  }

  @override
  Future<int> push(Log log) async {
    List breadcrumbs = [];
    for (var breadcrum in log.breadcrumbs) {
      breadcrumbs.add({
        'category': breadcrum.category,
        'message': breadcrum.message,
        'level': breadcrum.type.name,
        'type': 'default',
        'timestamp': breadcrum.timestamp,
      });
    }

    var stackFrames = [];
    if (log.extra['detailedTrace'] != null) {
      final detailedTrace = log.extra['detailedTrace'];

      if (detailedTrace.runtimeType != List) {
        throw 'detailedTrace must be a List';
      }
      detailedTrace.forEach((trace) {
        if (trace.runtimeType != Map) {
          throw 'detailedTrace items must be a Map';
        }

        stackFrames.add({
          'filename': trace['file'] ?? '',
          'lineno': trace['line'] ?? '',
          'function': trace['function'] ?? ''
        });
      });

      stackFrames = stackFrames.reversed.toList();
    }

    final requestBody = {
      'timestamp': log.timestamp,
      'platform': 'Dart',
      'level': log.type.name,
      'logger': log.namespace,
      'transaction': log.action,
      'server_name': log.server,
      'release': log.version,
      'environment': log.environment.name,
      'message': {
        'message': log.message,
      },
      'exception': {
        'values': [
          {
            'type': log.message,
            'stacktrace': {
              'frames': stackFrames,
            }
          }
        ],
      },
      'tags': log.tags,
      'extra': log.extra,
      'breadcrumbs': breadcrumbs,
      'user': log.user != null
          ? {
              'id': log.user?.id,
              'email': log.user?.email,
              'username': log.user?.name,
            }
          : null,
    };

    try {
      final response = await http.post(
          Uri.parse('$_sentryHost/api/$_projectId/store/'),
          body: jsonEncode(requestBody),
          headers: {
            // 'content-type': 'application/json',
            'X-Sentry-Auth':
                'Sentry sentry_version=7, sentry_key=$_sentryKey, sentry_client=utopia-dart-logger/${Logger.libraryVersion}',
          });

      if (response.statusCode > 400) {
        throw 'Log could not be pushed with status code ${response.statusCode}: ${response.body}';
      }
      return response.statusCode;
    } catch (e) {
      throw 'Log could not be pushed with error: ${e.toString()}';
    }
  }
}
