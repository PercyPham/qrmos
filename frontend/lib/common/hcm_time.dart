import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

const dayInNanos = 24 * 60 * 60 * 1000000000;

int getNanoOfStartOfTodayInHcmTz() {
  var startOfToday = getStartOfTodayInHcmTz();
  return startOfToday.microsecondsSinceEpoch * 1000;
}

tz.TZDateTime getStartOfTodayInHcmTz() {
  var now = getNowInHcmTz();

  return now.subtract(Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
      milliseconds: now.millisecond,
      microseconds: now.microsecond));
}

tz.TZDateTime getNowInHcmTz() {
  var now = DateTime.now();
  tz.initializeTimeZones();
  final hcmTimeZone = tz.getLocation('Asia/Ho_Chi_Minh');
  var nowInHcmTime = tz.TZDateTime.from(now, hcmTimeZone);
  return nowInHcmTime;
}
