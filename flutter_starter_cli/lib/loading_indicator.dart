import 'dart:async';
import 'dart:io';

class LoadingIndicator {
  bool _running = false;
  Timer? _timer;
  int _index = 0;
  final List<String> _frames = ['|', '/', '-', '\\'];
  final String label;

  LoadingIndicator({required this.label});

  void start() {
    _running = true;
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      stdout.write(
          '\r${_frames[_index % _frames.length]} $label');
      _index++;
    });
  }

  void stop() {
    if (_running) {
      _timer?.cancel();
      _running = false;
      stdout.write('\r            \n');
      // stdout.write('\rOperations completed.            \n');
    }
  }
}
