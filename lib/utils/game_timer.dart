import 'dart:async';

class GameTimer {
  int elapsedTime = 0;
  Timer? _timer;
  final void Function(int) onTick;

  GameTimer({required this.onTick});

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedTime++;
      onTick(elapsedTime);
    });
  }

  void stop() {
    _timer?.cancel();
  }

  void reset() {
    stop();
    elapsedTime = 0;
    onTick(elapsedTime);
  }

  void dispose() {
    _timer?.cancel();
  }
}
