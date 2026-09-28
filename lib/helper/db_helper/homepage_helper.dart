import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../config/secure_storage.dart';
import '../../../data/local/job_db.dart';

class DBHomepageHelper {
  final DBJobData dbJob;

  DBHomepageHelper() : dbJob = DBJobData();

  Future<dynamic> checkJobStatus(type, jobStatus, context) async {
    final value = await dbJob.getAddJobFromStatus(type, jobStatus);

    // await dbJob.getAddJobFromStatus(type, jobStatus).then((value) {
    if (value != null) {
      List ongoingOut = value;

      var getAllSelectedAddJob = ongoingOut
          .firstWhereOrNull((element) => element['j_status'] == 'ONGOING');

      // print('GETJOB 1: $getAllSelectedAddJob');

      if (getAllSelectedAddJob != null) {
        Storage().jobID = getAllSelectedAddJob['j_id'];
        Storage().transactionNo = getAllSelectedAddJob['tr_id'];

        // Navigator.push(context, NoAnimationPageRoute(builder: (context) => const GoodsReceiveViewPage()));
        Fluttertoast.showToast(
            msg:
                "${'homeEditJobMessage'.tr()} ${getAllSelectedAddJob['tr_id']}",
            fontSize: 14,
            backgroundColor: Colors.lightBlue);

        return getAllSelectedAddJob;
      }
    } else {
      Storage().jobID = 0;
      Storage().transactionNo = '';

      if (type == 'IN') {
        Fluttertoast.showToast(
            msg: 'homeCreateJobReceive'.tr(),
            fontSize: 14,
            backgroundColor: Colors.lightBlue);
      } else {
        Fluttertoast.showToast(
            msg: 'homeCreateJobIssues'.tr(),
            fontSize: 14,
            backgroundColor: Colors.lightBlue);
      }

      return;
    }
    // });
  }
}
