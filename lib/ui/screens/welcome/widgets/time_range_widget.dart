import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_gem/task_bloc/task_bloc.dart';
import 'package:time_gem/task_bloc/task_event.dart';

class TimeRangeWidget extends StatefulWidget {
  const TimeRangeWidget({super.key});

  @override
  State<TimeRangeWidget> createState() => _TimeRangeWidgetState();
}

class _TimeRangeWidgetState extends State<TimeRangeWidget> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 17, minute: 0)),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
      _updateBloc();
    }
  }

  void _updateBloc() {
    if (_startTime != null && _endTime != null) {
      context.read<TaskBloc>().add(SetTimeRange(_startTime!, _endTime!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, size: 64, color: Colors.blueAccent),
          const SizedBox(height: 24),
          Text(
            'Set Your Working Hours',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tell us when you prefer to work so we can schedule your tasks accordingly.',
            style: TextStyle(fontSize: 16, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildTimePickerButton(
            context: context,
            label: 'Start Time',
            time: _startTime,
            onTap: () => _selectTime(context, true),
          ),
          const SizedBox(height: 16),
          _buildTimePickerButton(
            context: context,
            label: 'End Time',
            time: _endTime,
            onTap: () => _selectTime(context, false),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerButton({
    required BuildContext context,
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              time != null ? time.format(context) : 'Select',
              style: TextStyle(
                fontSize: 16,
                color:
                    time != null ? Theme.of(context).primaryColor : Colors.grey,
                fontWeight: time != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
