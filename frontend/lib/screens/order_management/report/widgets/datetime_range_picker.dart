import 'package:flutter/material.dart';
import 'package:qrmos/widgets/custom_button.dart';

class DateTimeRangePicker extends StatelessWidget {
  final DateTime initialStartDateTime;
  final DateTime initialEndDateTime;
  final void Function(DateTime) onStartChanged;
  final void Function(DateTime) onEndChanged;

  const DateTimeRangePicker({
    Key? key,
    required this.initialStartDateTime,
    required this.initialEndDateTime,
    required this.onStartChanged,
    required this.onEndChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _datetime(
          context,
          label: 'Bắt đầu:',
          value: initialStartDateTime,
          onChanged: (val) => onStartChanged(val),
        ),
        const SizedBox(height: 10),
        _datetime(
          context,
          label: 'Kết thúc:',
          value: initialEndDateTime,
          onChanged: (val) => onEndChanged(val),
        ),
      ],
    );
  }

  _datetime(
    BuildContext context, {
    required String label,
    required DateTime value,
    required void Function(DateTime val) onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 80, child: Text(label)),
        Text(value.toLocal().toString()),
        const SizedBox(width: 10),
        CustomButton(
            'Thay đổi',
            () => _onPickerPressed(
                  context,
                  value,
                  onChanged,
                )),
      ],
    );
  }

  _onPickerPressed(
    BuildContext context,
    DateTime initialDate,
    void Function(DateTime val) onChanged,
  ) async {
    var date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
      lastDate: DateTime.now(),
    );
    if (date == null) {
      return;
    }
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) {
      return;
    }
    var newDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    onChanged(newDate);
  }
}
