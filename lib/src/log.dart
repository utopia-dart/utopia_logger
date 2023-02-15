import 'log/breadcrumb.dart';
import 'log/environment.dart';
import 'log/log_type.dart';
import 'log/user.dart';

class Log {
  late final int timestamp;
  final LogType type;
  final String message;
  final String version;
  final Environment environment;
  final String action;
  final Map<String, String> tags = {};
  final Map<String, dynamic> extra = {};
  final String namespace = 'UNKNOWN';
  final String? server = null;
  final User? user = null;
  final List<Breadcrumb> breadcrumbs = [];

  Log({
    int? timestamp,
    required this.type,
    required this.message,
    required this.version,
    required this.environment,
    required this.action,
  }) {
    this.timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
  }

  void addTag(String key, String value) {
    tags[key] = value;
  }

  void addExtra(String key, dynamic value) {
    extra[key] = value;
  }

  void addBreadcrumb(Breadcrumb breadcrumb) {
    breadcrumbs.add(breadcrumb);
  }
}
