import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../config/config.dart';

enum JobStatus {
  pending,
  completed,
  ongoing,
  inProgress,
  unknown;

  static JobStatus fromString(String status) {
    switch (status.trim().toLowerCase()) {
      case 'pending':
        return JobStatus.pending;
      case 'complete':
      case 'completed':
        return JobStatus.completed;
      case 'ongoing':
        return JobStatus.ongoing;
      case 'in progress':
        return JobStatus.inProgress;
      default:
        return JobStatus.unknown;
    }
  }

  String get localizedName {
    switch (this) {
      case JobStatus.pending:
        return "jobStatusPending".tr();
      case JobStatus.completed:
        return "jobStatusCompleted".tr();
      case JobStatus.ongoing:
        return "jobStatusInProgress".tr();
      case JobStatus.inProgress:
        return "jobStatusInProgress".tr();
      case JobStatus.unknown:
        return "";
    }
  }

  Color get textColor {
    switch (this) {
      case JobStatus.pending:
        return AppColors.pendingStatus;
      case JobStatus.completed:
        return AppColors.completeStatus;
      case JobStatus.ongoing:
        return AppColors.inProgressStatus;
      case JobStatus.inProgress:
        return AppColors.inProgressStatus;
      case JobStatus.unknown:
        return AppColors.black;
    }
  }
}
