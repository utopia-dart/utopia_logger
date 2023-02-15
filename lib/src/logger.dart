import 'package:utopia_logger/src/adapter.dart';
import 'package:utopia_logger/src/log.dart';

class Logger {
  static const String libraryVersion = '0.0.1';
  static const List<String> providers = [
    'sentry',
    'raygun',
  ];

  final Adapter adapter;

  static bool hasProvider(String name) {
    return providers.contains(name);
  }

  Logger(this.adapter);

  Future<int> addLog(Log log) async {
    if (adapter.validate(log)) {
      return adapter.push(log);
    }
    return 500;
  }
}
