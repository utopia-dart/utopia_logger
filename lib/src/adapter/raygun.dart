import 'package:http/http.dart' as http;
import 'package:utopia_logger/src/adapter.dart';
import 'package:utopia_logger/src/log/log_type.dart';
import 'package:utopia_logger/src/log/environment.dart';
import 'package:utopia_logger/src/log.dart';
import 'package:utopia_logger/src/logger.dart';

class Raygun extends Adapter {
  final String _apiKey;

  Raygun(this._apiKey);

  static String getName() {
    return 'raygun';
  }

  @override
  List<LogType> getSupportedBreadcrumbTypes() {
    return LogType.values;
  }

  @override
  List<Environment> getSupportedEnvironments() {
    return Environment.values;
  }

  @override
  List<LogType> getSupportedTypes() {
    return LogType.values;
  }

  @override
  Future<int> push(Log log) async {
    List breadcrumbs = [];
    for (var breadcrum in log.breadcrumbs) {
      breadcrumbs.add({
        'category': breadcrum.category,
        'message': breadcrum.message,
        'type': breadcrum.type.name,
        'level': 'request',
        'timestamp': breadcrum.timestamp,
      });
    }

    final tags = [];
    log.tags.forEach((key, value) {
      tags.add('$key: $value');
    });

    tags.add('type: ${log.type.name}');
    tags.add('environment: ${log.environment.name}');
    tags.add('sdk: utopia-dart-logger/${Logger.libraryVersion}');

    final requestBody = {
      'occurredOn': log.timestamp,
      'details': {
        'machineName': log.server,
        'groupingKey': log.namespace,
        'version': log.version,
        'error': {
          'className': log.action,
          'message': log.message,
        },
        'tags': tags,
        'userCustomData': log.extra,
        'user': {
          'isAnonymous': log.user == null,
          'identifier': log.user?.id,
          'email': log.user?.email,
          'fullName': log.user?.name,
        },
        'breadcrumbs': breadcrumbs,
      },
    };

    try {
      final response = await http.post(
          Uri.parse('https://api.raygun.com/entries'),
          body: requestBody,
          headers: {
            'content-type': 'application/json',
            'X-ApiKey': _apiKey,
          });
      if (response.statusCode >= 400) {
        throw 'Log could not be pushed with status code ${response.statusCode}: ${response.body}';
      }
      return response.statusCode;
    } catch (e) {
      throw 'Log could not be pushed with error: ${e.toString()}';
    }
  }
}
