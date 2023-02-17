import 'package:utopia_logger/src/log.dart';
import 'package:utopia_logger/src/log/environment.dart';
import 'package:utopia_logger/src/log/log_type.dart';

abstract class Adapter {
  Future<int> push(Log log);
  List<LogType> getSupportedTypes();
  List<Environment> getSupportedEnvironments();
  List<LogType> getSupportedBreadcrumbTypes();

  bool validate(Log log) {
    final supportedTypes = getSupportedTypes();
    final supportedEnvironments = getSupportedEnvironments();
    final supportedBreadcrumbTypes = getSupportedBreadcrumbTypes();

    if (!supportedTypes.contains(log.type)) {
      throw 'Supported types for this adapter are: ${supportedTypes.join(',')}';
    }
    if (!supportedEnvironments.contains(log.environment)) {
      throw 'Supported environments for this adapter are: ${supportedEnvironments.join(',')}';
    }

    for (var breadcrumb in log.breadcrumbs) {
      if (!supportedBreadcrumbTypes.contains(breadcrumb.type)) {
        throw 'Supported breadcrumb types for this adapter are: ${supportedBreadcrumbTypes.join(',')}';
      }
    }
    return true;
  }
}
