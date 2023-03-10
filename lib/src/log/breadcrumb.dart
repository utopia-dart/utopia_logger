import 'package:utopia_logger/src/log/log_type.dart';

class Breadcrumb {
  final LogType type;
  final String category;
  final String message;
  final int timestamp;

  Breadcrumb({
    required this.type,
    required this.category,
    required this.message,
    required this.timestamp,
  });
}
