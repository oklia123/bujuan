class TimeUtils {
  static String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}
