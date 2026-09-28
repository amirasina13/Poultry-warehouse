import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../config/config.dart';
import '../../../custom_page_route.dart';
import '../../../data/local/local.dart';
import '../../../helper/api_helper/upload_helper.dart';
import '../../../helper/helper.dart';
import '../../widgets/data_driven/data_driven.dart';
import '../../widgets/extensions/extensions.dart';
import '../../widgets/independent/independent.dart';
import '../good_issue/good_issue.dart';
import '../good_receive/grn_list_view.dart';
import '../home_view.dart';

class GoodRecordView extends StatefulWidget {
  const GoodRecordView({super.key});

  @override
  State<GoodRecordView> createState() => _GoodRecordViewState();
}

class _GoodRecordViewState extends State<GoodRecordView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, String> fieldMapping = {};

  bool isPageLoading = true;
  bool isUploading = false;

  List<dynamic> jobsDataList = [];
  List combinedList = [];
  List jobAllList = [];

  @override
  void initState() {
    super.initState();

    initData();
  }

  Future<void> initData() async {
    isPageLoading = true;

    try {
      await fetchAllJobsData();
    } catch (e) {
      debugPrint("Init Error: $e");
    } finally {
      setState(() {
        isPageLoading = false; // Data is ready
      });
    }
  }

  Future<void> fetchAllJobsData() async {
    try {
      // We await the result so the data is ready before the UI builds
      final result = await DBJobData().getAllAddJob();

      setState(() {
        jobsDataList = result ?? [];
      });
    } catch (e) {
      debugPrint("Error fetching goods: $e");
      jobsDataList = [];
    }
  }

  void handleBackButton(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      NoAnimationPageRoute(builder: (context) => const HomeView()),
      (route) => false,
    );
  }

  void showErrorToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      fontSize: 16,
      backgroundColor: AppColors.deleteBtn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final device = OrientationHelper(context);
    context.locale;

    fieldMapping = {
      "t_type": "type".tr(),
      "tr_id": "transactionNo".tr(),
      "tl_name": "toLocation".tr(),
      "j_status": "status".tr(),
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
        statusBarIconBrightness:
            Brightness.dark, // Use dark icons for a light background
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Opacity(
              opacity:
                  isUploading ? 0.6 : 1.0, // Subtly fade the background content
              child: AbsorbPointer(
                absorbing:
                    isUploading, // Prevents clicking buttons while uploading
                child: PoultryScaffold(
                  scaffoldKey: _scaffoldKey,
                  showAppbar: true,
                  title: 'goodRecord'.tr(),
                  // bluetoothState: bluetoothState,
                  isShowLeading: true,
                  onBackPressed: () {
                    handleBackButton(context);
                  },
                  body: isPageLoading
                      ? LoadingWidget()
                      : SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Container(
                            height: device.height() * 0.95,
                            padding:
                                EdgeInsets.only(bottom: device.height() * 0.02),
                            color: AppColors.whiteBg,
                            child: Column(
                              children: [
                                OperatorAndLocation(
                                  onLocationChanged: fetchAllJobsData,
                                ),
                                SecondaryBar(
                                  isShowDivider: false,
                                  leading: SizedBox(
                                    width: device.width() * 0.3,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: TextUIDisplay(
                                        labelText: '${'totalJob'.tr()}(s): ',
                                        fontSize: AppSettings.fontSizeMain,
                                      ),
                                      subtitle: TextUIDisplay(
                                        labelText: '(${jobsDataList.length})',
                                        fontSize: AppSettings.fontSizeSubtitle,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  end: uploadJobAllButton(device),
                                ),
                                Expanded(
                                  child: jobsDataList.isEmpty
                                      ? Center(child: Text('noItem'.tr()))
                                      : ListView.builder(
                                          itemCount: jobsDataList.length,
                                          padding: const EdgeInsets.fromLTRB(
                                              15, 0, 15, 20),
                                          itemBuilder: (context, index) {
                                            final item = jobsDataList[index];

                                            final fields = fieldMapping.entries
                                                .map((entry) {
                                              if (entry.key == "t_type") {
                                                // Combine type + status
                                                final type =
                                                    item["t_type"] ?? '-';
                                                final subType =
                                                    item["t"] == 'OUT'
                                                        ? 'GIN'
                                                        : 'GRN';

                                                return {
                                                  "label": entry.value,
                                                  "value": "$subType - $type",
                                                };
                                              }

                                              // Default mapping
                                              return {
                                                "label": entry.value,
                                                "value":
                                                    item[entry.key].isNotEmpty
                                                        ? item[entry.key]
                                                        : '-',
                                              };
                                            }).toList();

                                            return CardListview(
                                              cardItemList: jobsDataList,
                                              itemMappingList: fields,
                                              crossAxisCount: 3,
                                              rowPattern: const [3, 3],
                                              cardIndex: index,
                                              onTap: () {
                                                if (!isUploading) {
                                                  handleTask(context, item);
                                                } else {
                                                  showErrorToast(
                                                      'uploadingJob'.tr());
                                                }
                                              },
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
            if (isUploading)
              Positioned.fill(
                child: Container(
                  color: Colors.black26, // Light dark tint
                  child: Center(
                    child: LoadingWidget(
                      backgroundColor: Colors.transparent,
                      textColor: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget uploadJobAllButton(device) {
    return ButtonUIDisplay(
      labelText: 'uploadJob'.tr(),
      fontSize: AppSettings.fontSizeMain,
      backgroundColor:
          isUploading ? AppColors.greyShade300 : AppColors.downloadBtn,
      icon: Icon(
        Icons.file_upload_outlined,
        color: AppColors.white,
        size: 20,
      ),
      width: device.isTablet() ? device.width() * 0.26 : device.width() * 0.29,
      onPressed: () {
        uploadConfirmationDialog(context, {});
      },
    );
  }

  void handleTask(BuildContext context, dynamic jobData) {
    JobBottomSheet.show(
      context,
      onEdit: () => handleEditJob(context, jobData),
      onUpload: () => handleUploadByJob(jobData),
      onDelete: () => handleDeleteJob(jobData),
    );
  }

  handleEditJob(context, dynamic jobData) async {
    final jobId = jobData['j_id']; // JOB ID
    final trId = jobData['tr_id']; // TRANSACTION ID
    final type = jobData['t']; // IN or OUT

    // Update Storage
    Storage().jobID = jobId;
    Storage().transactionNo = trId;
    if (type == 'OUT') Storage().areaIssueID = jobData['fa_id'];

    // Check for ongoing jobs of the same type
    final ongoingJobs = await DBJobData().getAddJobFromStatus(type, 'ONGOING');

    if (ongoingJobs != null && ongoingJobs.isNotEmpty) {
      // Check if the selected job is already the ongoing one
      bool isSameJob = ongoingJobs.any((job) => job['j_id'] == jobId);

      if (isSameJob) {
        await _handleJobNavigation(context, jobId, type);
      } else {
        // Another job is already ongoing - block entry
        final currentTrId = ongoingJobs.first['tr_id'];
        final msgKey1 = type == 'IN' ? 'similarGRNMsg1' : 'similarGINMsg1';
        final msgKey2 = type == 'IN' ? 'similarGRNMsg2' : 'similarGINMsg2';

        showErrorToast(
          "${msgKey1.tr()}$currentTrId${msgKey2.tr()}",
        );
      }
    } else {
      // No ongoing jobs exist - start this one
      await _handleJobNavigation(context, jobId, type);
      Fluttertoast.showToast(
        msg: "${'editJobToast'.tr()} $trId.",
        backgroundColor: Colors.lightBlue,
      );
    }
  }

  Future<void> _handleJobNavigation(context, int jobId, String type) async {
    await DBJobData().updateJobIndividually(jobId, "j_status", 'ONGOING');

    Widget targetPage =
        (type == 'IN') ? const GRNListView() : const GINListView();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
      (route) => false,
    );
  }

  handleUploadByJob(dynamic jobData) {
    if (jobData['j_status'] == 'ONGOING') {
      Navigator.pop(context);

      showErrorToast('ongoingJob'.tr());
    } else if (jobData['j_status'] == 'COMPLETE') {
      Navigator.pop(context);
      uploadConfirmationDialog(context, jobData);
    }
  }

  Future<void> uploadConfirmationDialog(
      context, Map<String, dynamic>? jobData) async {
    final resultvalue = await OptionDialog.show(
      context,
      title: jobData == null || jobData.isEmpty
          ? "uploadAllTitle".tr()
          : "uploadJobTitle".tr(),
      message: Text(
        jobData == null || jobData.isEmpty
            ? "uploadAllMsg".tr()
            : "uploadJobMsg".tr(),
        style: TextStyle(
          fontSize: AppSettings.fontSizeMain,
          fontWeight: FontWeight.w500,
          color: AppColors.darkGrey,
        ),
      ),
      typeDialog: 'upload',
    );

    if (resultvalue == true) {
      // uploadJob(context, jobData);
      if (jobData == null || jobData.isEmpty) {
        uploadAll();
      } else {
        uploadAll(singleJob: jobData);
      }
    }
  }

  uploadAll({Map? singleJob}) async {
    // Prevent double clicks
    if (isUploading) {
      Fluttertoast.showToast(
          msg: 'ongoingUpload'.tr(), backgroundColor: Colors.lightBlue);
      return;
    }

    setState(() => isUploading = true);
    // Clear global lists before starting the bulk process
    jobAllList.clear();

    try {
      List allJob;

      if (singleJob != null) {
        //  Single Upload
        allJob = [singleJob];
      } else {
        //  Bulk Upload
        allJob = await DBJobData().getAddJobFromStatusOnly('COMPLETE') ?? [];
      }

      if (allJob.isEmpty) {
        Fluttertoast.showToast(
            msg: 'noCompletedData'.tr(), backgroundColor: Colors.red);
        setState(() => isUploading = false);
        return;
      }

      // Loop through and prepare the payload for EVERY job
      for (var jobData in allJob) {
        final jobId = jobData['j_id'];

        // Fetch goods for this specific job
        final goodsData = await DBGoodsData().getAllGoodsDataBasedJobID(jobId);

        if (goodsData != null && goodsData.isNotEmpty) {
          // Map items for THIS job only
          List<Map<String, dynamic>> currentJobGoods = goodsData
              .map((item) => _mapGoodsItem(item))
              .toList()
              .cast<Map<String, dynamic>>();

          // Create payload for THIS job
          Map jobPayload = {
            "transaction_no": ValueParser.formatStringPayload(jobData['tr_id']),
            "type": ValueParser.formatStringPayload(jobData['tt_id']),
            "picking_list_no":
                ValueParser.formatStringPayload(jobData['pl_no']),
            "picking_list_id":
                ValueParser.formatStringPayload(jobData['pl_id']),
            "doc_no": ValueParser.formatStringPayload(jobData['sd_id']),
            "from": ValueParser.formatStringPayload(jobData['fl_id']),
            "to": ValueParser.formatStringPayload(jobData['tl_id']),
            "from_area": ValueParser.formatStringPayload(jobData['fa_id']),
            "to_area": ValueParser.formatStringPayload(jobData['ta_id']),
            "issue_by": ValueParser.formatStringPayload(Storage().loginId),
            "reason_id": ValueParser.formatStringPayload(jobData['reasonId']),
            "status": "3",
            "remark": ValueParser.formatStringPayload(jobData['remark']),
            "data": currentJobGoods, // Attach only this job's goods
          };

          jobAllList.add(jobPayload);
        }
      }

      // Final Internet Check & Bulk Upload
      if (jobAllList.isEmpty) {
        showErrorToast('failUpload'.tr());
        setState(() => isUploading = false);
        return;
      }

      var connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        showErrorToast('noInternet'.tr());
        setState(() => isUploading = false);
        return;
      }

      // Send the entire list of jobs in one API call
      final response = await ApiUploadhelper().uploadJob(jobAllList);

      if (response.isNotEmpty && response['success'] == true) {
        // Bulk Delete local records upon success
        for (var job in allJob) {
          await deleteJob(job['j_id']);
        }
        // final jobIDs =
        //     allJob.map((job) => job['j_id']).where((id) => id != null).toList();

        // await DBJobData().deleteBulksAddJob(jobIDs);
        // await DBGoodsData().deleteGoodsDataBasedIDs(jobIDs);

        // Refresh the list only once after the entire cleanup is completed.
        await fetchAllJobsData();

        Fluttertoast.showToast(
            msg: 'successUpload'.tr(), backgroundColor: Colors.green);
        setState(() => isUploading = false);
      }
    } catch (e) {
      showErrorToast('failUpload'.tr());
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  Map<String, dynamic> _mapGoodsItem(dynamic goodsData) {
    return {
      "pl_detail_id": ValueParser.formatStringPayload(goodsData['pld_id']),
      "stock_id": ValueParser.formatStringPayload(goodsData['sb_id']),
      "is_grouped": goodsData['is_grouped'] == 1 ? true : false,
      "grouped_ids": _safeJsonDecode(goodsData['grouped_ids']),
      "sku_code": ValueParser.formatStringPayload(goodsData['gs_name']),
      "uom_id": ValueParser.formatStringPayload(goodsData['uq_id']),
      "uom_weight_id": ValueParser.formatStringPayload(goodsData['uw_id']),
      "qty": ValueParser.formatNumberPayload(goodsData['t_quantity']),
      "weight": ValueParser.formatNumberPayload(goodsData['t_weight']),
      "tray_id": ValueParser.formatStringPayload(goodsData['p_id']),
      "tray_no": ValueParser.formatStringPayload(goodsData['tt_tray']),
      "tray_weight": ValueParser.formatNumberPayload(goodsData['tray_weight']),
      "trolley_weight": ValueParser.formatNumberPayload(goodsData['st_weight']),
      "nett_weight": ValueParser.formatNumberPayload(goodsData['nt_weight']),
      "production_date": ValueParser.formatStringPayload(goodsData['p_date']),
      "exp_date": ValueParser.formatStringPayload(goodsData['e_date']),
      "vendor_id": ValueParser.formatStringPayload(goodsData['v_id']),
      "client_id": ValueParser.formatStringPayload(goodsData['c_id']),
      "area_id": ValueParser.formatStringPayload(goodsData['a_id']),
      "rack_id": ValueParser.formatStringPayload(goodsData['r_id']),
      "batch_no": ValueParser.formatStringPayload(goodsData['pb_no']),
      "note": ValueParser.formatStringPayload(goodsData['remarks']),
    };
  }

  // Safety helper
  dynamic _safeJsonDecode(dynamic value) {
    try {
      if (value == null || value.toString().isEmpty) return [];
      return jsonDecode(value.toString());
    } catch (e) {
      return []; // Return empty list if decode fails
    }
  }

  Future<void> handleDeleteJob(dynamic jobData) async {
    Navigator.pop(context);

    final resultvalue = await OptionDialog.show(
      context,
      title: "deleteJobTitle".tr(),
      message: Text(
        "deleteJobMsg".tr(),
        style: TextStyle(
          fontSize: AppSettings.fontSizeMain,
          fontWeight: FontWeight.w500,
          color: AppColors.darkGrey,
        ),
      ),
      typeDialog: 'delete',
    );

    if (resultvalue == true) {
      deleteJob(jobData['j_id']);
    }
  }

  Future<void> deleteJob(jobID) async {
    try {
      Storage().transactionNo = '';
      await DBJobData().deleteIDAddJob(jobID);
      await DBGoodsData().deleteGoodsBasedJobId(jobID);

      // await fetchAllJobsData();

      // setState(() {});
    } catch (e) {
      debugPrint("Delete Error: $e");
      rethrow;
    }
  }
}
