import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class StoreConfigOpeningHours {
  final bool isManual;
  final bool isManualOpen;
  final StoreConfigTime start;
  final StoreConfigTime end;

  StoreConfigOpeningHours({
    required this.isManual,
    required this.isManualOpen,
    required this.start,
    required this.end,
  });
  StoreConfigOpeningHours.fromJson(Map<String, dynamic> dataJson)
      : isManual = dataJson['isManual'],
        isManualOpen = dataJson['isManualOpen'],
        start = StoreConfigTime.fromJson(dataJson['start']),
        end = StoreConfigTime.fromJson(dataJson['end']);

  Map toJson() => {
        'isManual': isManual,
        'isManualOpen': isManualOpen,
        'start': start.toJson(),
        'end': end.toJson(),
      };

  bool isOpenAt(DateTime t) {
    if (isManual) {
      return isManualOpen;
    }
    tz.initializeTimeZones();
    final hcmTimeZone = tz.getLocation('Asia/Ho_Chi_Minh');
    var tInHcmTime = tz.TZDateTime.from(t, hcmTimeZone);
    var tCfgTime = StoreConfigTime(tInHcmTime.hour, tInHcmTime.minute, tInHcmTime.second);

    return tCfgTime.after(start) && tCfgTime.before(end);
  }
}

class StoreConfigTime {
  int hour;
  int min;
  int sec;

  StoreConfigTime(this.hour, this.min, this.sec);
  StoreConfigTime.fromJson(Map<String, dynamic> dataJson)
      : hour = dataJson["hour"],
        min = dataJson["min"],
        sec = dataJson["sec"];

  Map toJson() => {'hour': hour, 'min': min, 'sec': sec};

  bool before(StoreConfigTime other) {
    return compare(other) < 0;
  }

  bool after(StoreConfigTime other) {
    return compare(other) > 0;
  }

  int compare(StoreConfigTime other) {
    if (hour != other.hour) return hour - other.hour;
    if (min != other.min) return min - other.min;
    return sec - other.sec;
  }
}
