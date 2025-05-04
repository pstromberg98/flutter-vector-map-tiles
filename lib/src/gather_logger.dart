import 'dart:async';
import 'dart:typed_data';

class Log {
  Log({
    required this.tag,
    required this.message,
  }) : timestamp = DateTime.now();

  String tag;
  String message;
  DateTime timestamp;
}

class GatherLogger {
  static final StreamController<Log> _controller = StreamController();
  static final Stream<Log> logStream = _controller.stream;

  static void info(String tag, String message) {
    print('[$tag] $message');
    _controller.add(Log(tag: tag, message: message));
  }

  static void writeOut(String file, Uint8List bytes) {}
}
