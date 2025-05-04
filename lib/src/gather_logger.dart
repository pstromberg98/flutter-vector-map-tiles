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

typedef WriteOutFunction = Future<void> Function(String file, Uint8List bytes);

class GatherLogger {
  static final StreamController<Log> _controller = StreamController();
  static final Stream<Log> logStream = _controller.stream;

  static WriteOutFunction? writeOutFunction;

  static void info(String tag, String message) {
    print('[$tag] $message');
    _controller.add(Log(tag: tag, message: message));
  }

  static void error(String tag, String message) {
    print('\x1B[31m[$tag] $message\x1B[0m');
    _controller.add(Log(tag: tag, message: message));
  }

  static void writeOut(String file, Uint8List bytes) {
    if (writeOutFunction != null) {
      writeOutFunction!(file, bytes);
    }
  }
}
