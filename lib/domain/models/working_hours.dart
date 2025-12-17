import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class WorkingHours extends Equatable {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const WorkingHours({
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [startTime, endTime];
}
