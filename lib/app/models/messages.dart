import 'package:ble_esp32/utils.dart' show SourceId;

class Message implements Comparable {
  SourceId whom;
  String text;
  DateTime logTime;

  Message({required this.whom, required this.text, required this.logTime});

  @override
  int compareTo(other) {
    return logTime.compareTo(other.logTime);
  }
}
