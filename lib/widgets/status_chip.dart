import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/backlog_entry.dart';

/// Color used for each status on chips and the Stats screen.
Color statusColor(BacklogStatus status) {
  switch (status) {
    case BacklogStatus.playing:
      return AppColors.playing;
    case BacklogStatus.completed:
      return AppColors.completed;
    case BacklogStatus.dropped:
      return AppColors.dropped;
  }
}

/// Small colored label showing a backlog status.
class StatusChip extends StatelessWidget {
  final BacklogStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}