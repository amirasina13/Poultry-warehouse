// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../config/config.dart';
import '../../../custom_page_route.dart';
import '../../../data/local/local.dart';
import '../../../data/model/model.dart';
import '../../../helper/api_helper/transfer_transaction_helper.dart';
import '../../../helper/helper.dart';
import '../../widgets/data_driven/dropdown_widget.dart';
import '../../widgets/independent/independent.dart';
import '../home_view.dart';
import 'good_issue.dart';

class GINCreateJobView extends StatefulWidget {
  final String pageTitle;

  const GINCreateJobView({super.key, required this.pageTitle});

  @override
  State<GINCreateJobView> createState() => _GINCreateJobViewState();
}

class _GINCreateJobViewState extends State<GINCreateJobView> {
  // Controllers
  final ginDatetimeController = TextEditingController();
  final ginTransferTypeController = TextEditingController();
  final ginFromLocController = TextEditingController();
  final ginFromAreaController = TextEditingController();
  final ginToLocationController = TextEditingController();
  final ginToAreaController = TextEditingController();
  final ginPickingListController = TextEditingController();
  final ginReasonCodeController = TextEditingController();
  final ginTxnNoController = TextEditingController();
  final ginIssueByController = TextEditingController();
  final ginUploadController = TextEditingController();
  final ginRemarkController = TextEditingController();

  // int
  int oldPickingListId = 0,
      pickingListId = 0,
      typeId = 0,
      productionLocId = 0,
      toLocationId = 0,
      fromLocationId = 0,
      fromAreaId = 0,
      toAreaId = 0,
      reasonId = 0,
      transferTypeKey = 0;

  // IDs & State
  String? pickingListFromArea, ginIssuedById, createdAt;
  String? selectedTransferType,
      selectedPickingList,
      selectedToLocation,
      selectedFromArea,
      selectedToArea,
      selectedReasonCode;

  bool showExtraField = false;
  bool showReasonField = false;
  bool showImportantSymbol = false;
  bool showLocationField = false;
  bool isPageLoading = true;
  bool ispickingListSelected = false;

  bool isLoadingFromArea = false;
  bool isLoadingToLocation = false;
  bool isLoadingToArea = false;
  bool isLoadingPickingList = false;
  bool isLoadingReason = false;
  bool isClosed = false;
  bool isContinueClick = false;
  bool get isEdit => widget.pageTitle == 'edit'.tr();

  List<dynamic> transferTypeList = [
    {"id": 2, "name": "Production"},
    {"id": 3, "name": "Stock Transfer"},
    {"id": 6, "name": "Logistic"},
    {"id": 7, "name": "Return to Supplier"},
  ];
  List<dynamic> locationList = [];
  List<dynamic> areaList = [];
  List<dynamic> toAreaList = [];
  List<dynamic> filterPickingList = [];
  List<dynamic> reasonCodeList = [];

  var dateTime = DateTimeParser();

  @override
  void initState() {
    super.initState();

    initData();
  }

  Future<void> initData() async {
    isPageLoading = true;

    try {
      await Future.wait<dynamic>([
        getMasterDataFromAPI(),
        loadJobData(),
      ]);

      await getPickingList(
          fromAreaID: fromAreaId, transferType: typeId, isList: true);
    } catch (e, stacktrace) {
      debugPrint("Init Error: $e");
      debugPrint("Stacktrace: $stacktrace");
    } finally {
      setState(() {
        isPageLoading = false; // Data is ready
      });
    }
  }

  getMasterDataFromAPI() async {
    locationList = await ApiGlobalHelper().getLocationFromAPI();
    areaList =
        await ApiGlobalHelper().getAreaList(Storage().selectedLocationID);
  }

  getPickingList(
      {int? fromAreaID,
      required int transferType,
      required bool isList}) async {
    setState(() => isLoadingPickingList = true);

    // Assuming pickingList is the Map containing the "data" key from JSON
    final response = await ApiDocumentHelper().getPickingList(
        transferType: transferType,
        areaID: fromAreaID,
        isList: true,
        isPagination: false);

    if (mounted) {
      setState(() {
        filterPickingList = List.from(response);
        isLoadingPickingList = false;
      });
    }
  }

  getReasonCodeAPI() async {
    setState(() {
      isLoadingReason = true;
    });

    final reasonResult = await ApiGlobalHelper().getReasonCodeList();

    if (mounted) {
      setState(() {
        reasonCodeList = reasonResult;
        isLoadingReason = false;
      });
    }
  }

  Future<void> loadJobData() async {
    final value = await DBJobData().getAddJobFromJOID(Storage().jobID);

    var job = JobModel.defaultData();

    if (value != null && value.isNotEmpty) {
      final found = value.firstWhere(
        (e) => e['j_id'] == Storage().jobID,
        orElse: () => <String, dynamic>{},
      );
      if (found.isNotEmpty) {
        job = job.merge(JobModel.fromJson(found));
      }
    }

    ginTxnNoController.text = job.transactionID;
    ginDatetimeController.text = job.dateTime;
    typeId = job.typeOfTransferId;
    selectedTransferType = job.typeOfTransfer;
    ginTransferTypeController.text = job.typeOfTransfer;
    oldPickingListId = job.pickingListID;
    pickingListId = job.pickingListID;
    selectedPickingList = job.pickingListNo;
    ginPickingListController.text = job.pickingListNo;
    productionLocId = job.pickingListLocationId;
    fromLocationId = job.fromLocationID == 0
        ? Storage().selectedLocationID
        : job.fromLocationID;
    ginFromLocController.text = job.fromLocationName.isEmpty
        ? Storage().selectedLocation
        : job.fromLocationName;
    toLocationId = job.toLocationID;
    selectedToLocation = job.toLocationName;
    ginToLocationController.text = job.toLocationName;
    ginRemarkController.text = job.remark;
    ginIssuedById = Storage().loginId.toString();
    ginIssueByController.text = Storage().loginName;
    ginUploadController.text = Storage().loginName;
    fromAreaId = job.fromAreaID;
    selectedFromArea = job.fromAreaName;
    ginFromAreaController.text = job.fromAreaName;
    toAreaId = job.toAreaID;
    selectedToArea = job.toAreaName;
    ginToAreaController.text = job.toAreaName;
    pickingListFromArea = job.fromAreaName;
    createdAt = job.createdAt;
    reasonId = job.reasonId;
    selectedReasonCode = job.reasonName;
    ginReasonCodeController.text = job.reasonName;

    showImportantSymbol = (job.typeOfTransfer == "Production");
    showExtraField = (job.typeOfTransfer == "Stock Transfer");
    showReasonField = (job.typeOfTransfer == "Return to Supplier");
    showLocationField = job.pickingListNo.isNotEmpty;
    isClosed = showLocationField;
    ispickingListSelected = selectedPickingList?.isNotEmpty ?? false;

    await Future.wait<dynamic>([
      getToAreaAPI(toLocationId),
      getReasonCodeAPI(),
    ]);
  }

  Future<void> getToAreaAPI(int locId) async {
    if (mounted) setState(() => isLoadingToArea = true);

    final getToArea = await ApiGlobalHelper().getAreaList(locId);

    setState(() {
      toAreaList = getToArea;
      isLoadingToArea = false;
    });
  }

  void handleBackButton(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      NoAnimationPageRoute(builder: (context) => const HomeView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    var device = OrientationHelper(context);
    context.locale;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        handleBackButton(context);
      },
      child: PoultryScaffold(
        showAppbar: true,
        title: '${widget.pageTitle} GIN',
        isShowLeading: true,
        onBackPressed: () {
          handleBackButton(context);
        },
        background: AppColors.whiteBg,
        body: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: device.isPotrait() ? 10 : 50,
                  vertical: device.height() * 0.01,
                ),
                color: AppColors.white,
                child: isPageLoading
                    ? LoadingWidget()
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(device.width() * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            rowExpanded(
                              // TEXTFIELD DATE & TIME
                              TextFieldInput(
                                controller: ginDatetimeController,
                                labelText: 'datetime'.tr(),
                                obscureToggleEnabled: false,
                                readOnly: true,
                              ),
                              // TEXTFIELD TRANSACTION NO
                              TextFieldInput(
                                controller: ginTxnNoController,
                                labelText: 'transactionNo'.tr(),
                                obscureToggleEnabled: false,
                                readOnly: true,
                              ),
                            ),

                            rowExpanded(
                              // TEXTFIELD ISSUED BY
                              TextFieldInput(
                                controller: ginIssueByController,
                                labelText: 'issueBy'.tr(),
                                obscureToggleEnabled: false,
                                readOnly: true,
                              ),
                              // TEXTFIELD UPLOADED BY
                              TextFieldInput(
                                controller: ginUploadController,
                                labelText: 'uploadBy'.tr(),
                                obscureToggleEnabled: false,
                                readOnly: true,
                              ),
                            ),

                            const Divider(),

                            // DROPDOWN TYPE OF TRANSACTION
                            buildDropDown(
                              key: ValueKey('transferType-$transferTypeKey'),
                              labelText: 'typeTransaction'.tr(),
                              hintText: ginTransferTypeController.text,
                              allItems: transferTypeList,
                              initialSelection: selectedTransferType,
                              isRequired: true,
                              isLoading: false,
                              isMultipleText: false,
                              readOnly: isEdit,
                              isClear:
                                  isEdit && selectedPickingList!.isNotEmpty,
                              onItemSelected: (item) {
                                transferTypeAction(item);
                              },
                              codeKey: 'name',
                              onTapClear: () {
                                setState(() {
                                  if (isEdit &&
                                      selectedPickingList!.isNotEmpty) {
                                    removePickinglistDialog(
                                        context, 'transferType');
                                  }
                                });
                              },
                            ),

                            // DROPDOWN PICKING LIST & REASON CODE
                            buildPickingReasonFieldsSection(),

                            rowExpanded(
                              // TEXTFIELD FROM LOCATION
                              TextFieldInput(
                                controller: ginFromLocController,
                                labelText: 'fromLocation'.tr(),
                                obscureToggleEnabled: false,
                                readOnly: true,
                              ),
                              // DROPDOWN FROM AREA
                              buildDropDown(
                                labelText: 'fromArea'.tr(),
                                hintText: '${'select'.tr()} ${'fromArea'.tr()}',
                                isLoading: isLoadingFromArea,
                                allItems: areaList,
                                isRequired: true,
                                readOnly: ispickingListSelected,
                                isMultipleText: true,
                                initialSelection: selectedFromArea,
                                isClear:
                                    isEdit && selectedPickingList!.isNotEmpty,
                                onItemSelected: (item) {
                                  updateFromArea(item);
                                },
                                codeKey: 'name',
                                onTapClear: () {
                                  if (isEdit &&
                                      selectedPickingList!.isNotEmpty) {
                                    removePickinglistDialog(
                                        context, 'fromArea');
                                  }
                                },
                              ),
                            ),

                            // DROPDOWN TO LOCATION & TO AREA
                            buildExtraFieldsSection(),

                            // // DROPDOWN PICKING LIST & REASON CODE
                            // if (showReasonField) buildReasonFieldsSection(),

                            // TEXTFIELD REMARK
                            TextFieldInput(
                              controller: ginRemarkController,
                              labelText: 'remark'.tr(),
                              obscureToggleEnabled: false,
                              isLargeTextfield: true,
                            ),
                          ]
                              .where((widget) => widget is! SizedBox)
                              .expand((widget) sync* {
                                yield const SizedBox(height: 5);
                                yield widget;
                                yield const SizedBox(height: 5);
                              })
                              .toList()
                              .cast<Widget>(),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(device.width() * 0.02),
              child: buildSaveCancelSection(device),
            ),
          ],
        ),
      ),
    );
  }

  Widget rowExpanded(Widget start, Widget end) {
    return Row(
      children: [
        Expanded(
          child: start,
        ),
        Expanded(
          child: end,
        ),
      ].expand((widget) sync* {
        yield widget;
        yield const SizedBox(width: 15);
      }).toList()
        ..removeLast(),
    );
  }

  Widget buildPickingReasonFieldsSection() {
    if (!showReasonField) {
      return buildDropDown(
        labelText: 'pickingList'.tr(),
        codeKey: 'transaction_no',
        hintText: '', //${'select'.tr()} ${'pickingList'.tr()}',
        allItems: filterPickingList,
        isRequired: selectedTransferType == 'Production' ? true : false,
        isLoading: isLoadingPickingList,
        isMultipleText: false,
        isClear: selectedPickingList!.isNotEmpty && createdAt!.isNotEmpty,
        initialSelection: selectedPickingList,
        onItemSelected: (item) {
          onPickingListSelected(item);
        },
        onTapClear: () {
          if (selectedPickingList!.isNotEmpty) {
            removePickinglistDialog(context, 'pickingList');
          }
          // if (isEdit &&
          //     selectedPickingList!.isNotEmpty) {
          //   removePickinglistDialog(context, 'pickingList');
          // } else {}
        },
        onTapValidation: () {
          if (selectedTransferType == null || selectedTransferType!.isEmpty) {
            showErrorToast('missingTypeTransactionFirst'.tr());
            return false; // Prevents dropdown from opening
          }
          return true;
        },
      ); // Return empty list if hidden
    }

    return buildDropDown(
      labelText: 'reasonCode'.tr(),
      codeKey: 'name',
      descText: 'desc',
      hintText: ginReasonCodeController.text,
      allItems: reasonCodeList,
      isRequired: true,
      isMultipleText: true,
      isLoading: isLoadingReason,
      initialSelection: selectedReasonCode,
      onItemSelected: (item) {
        if (item != null) {
          setState(() {
            ginReasonCodeController.text = item['name'];
            selectedReasonCode = item['name'];
            reasonId = item['id'];
          });
        }
      },
    );
  }

  Widget buildExtraFieldsSection() {
    if (!showExtraField) return const SizedBox(); // Return empty list if hidden

    return Row(
      children: [
        Expanded(
          child: buildDropDown(
            labelText: 'toLocation'.tr(),
            codeKey: 'name',
            hintText: '${'select'.tr()} ${'toLocation'.tr()}',
            allItems: locationList,
            isRequired: true,
            isMultipleText: true,
            isLoading: isLoadingToLocation,
            initialSelection: selectedToLocation,
            onItemSelected: (item) {
              if (item != null) {
                setState(() {
                  selectedToLocation = item['name'];
                  toLocationId = item['location_id'];

                  selectedToArea = '';
                  toAreaId = 0;
                  ginToAreaController.clear();

                  getToAreaAPI(toLocationId);
                });
              }
            },
          ),
        ),
        Expanded(
          child: buildDropDown(
            labelText: 'toArea'.tr(),
            codeKey: 'name',
            hintText: '${'select'.tr()} ${'toArea'.tr()}',
            allItems: toAreaList,
            isRequired: true,
            isMultipleText: true,
            readOnly: selectedToLocation!.isEmpty,
            isLoading: isLoadingToArea,
            initialSelection: selectedToArea,
            onItemSelected: (item) {
              if (item != null) {
                setState(() {
                  selectedToArea = item['name'];
                  ginToAreaController.text = item['name'];
                  toAreaId = item['id'];
                });
              }
            },
          ),
        ),
      ].where((widget) => widget is! SizedBox).expand((widget) sync* {
        yield widget;
        yield const SizedBox(width: 15);
      }).toList()
        ..removeLast(),
    );
  }

  void transferTypeAction(dynamic value) {
    if (value == null) return;

    if (selectedPickingList!.isNotEmpty) {
      removePickinglistDialog(context, 'transferType');
    } else {
      setState(() {
        selectedTransferType = value['name'];
        ginTransferTypeController.text = value['name'];
        typeId = value['id'];

        showExtraField = (selectedTransferType == "Stock Transfer");
        showReasonField = (selectedTransferType == "Return to Supplier");
        showImportantSymbol = (selectedTransferType == "Production");

        if (selectedTransferType != 'Return to Supplier') {
          selectedReasonCode = '';
          reasonId = 0;
          ginReasonCodeController.clear();
        }

        if (!showExtraField) {
          selectedToLocation = '';
          ginToLocationController.clear();
          toLocationId = 0;
          selectedToArea = '';
          ginToAreaController.clear();
          toAreaId = 0;
        }

        if (showReasonField) {
          getReasonCodeAPI();
        }

        getPickingList(
            fromAreaID: fromAreaId, transferType: typeId, isList: true);
      });
    }
  }

  void updateFromArea(dynamic item) {
    if (item == null) return;

    if (selectedPickingList!.isNotEmpty) {
      removePickinglistDialog(context, 'fromArea');
    } else {
      DBGoodsData().deleteGoodsDataBasedPLID(Storage().transactionNo);

      ginPickingListController.clear();
      selectedPickingList = '';
      pickingListId = 0;
      Storage().plStatusState = '';

      selectedFromArea = item['name'];
      ginFromAreaController.text = item['name'];
      fromAreaId = item['id'];
      Storage().areaIssueID = fromAreaId;

      getPickingList(
          fromAreaID: fromAreaId, transferType: typeId, isList: true);
    }
  }

  void onPickingListSelected(dynamic item) {
    if (item == null) return;

    setState(() {
      int responseFromLocID = item?['from_location_id'] ??
          item?['location_id'] ??
          Storage().selectedLocationID;
      // Safely check if details list exists and has elements
      List detailsList =
          (item != null && item['details'] is List) ? item['details'] : [];
      Map<String, dynamic>? detailArea =
          detailsList.isNotEmpty ? detailsList.first : null;

      int responseFromAreaId =
          item?['from_area_id'] ?? detailArea?['area_id'] ?? 0;
      String responseFromAreaName =
          item?['from_area_name'] ?? detailArea?['area_name'] ?? '';

      int responseToLocID = item?['to_location_id'] ?? 0;
      String responseToLocName = item?['to_location_name'] ?? '';
      int responseToAreaId = item?['to_area_id'] ?? 0;
      String responseToAreaName = item?['to_area_name'] ?? '';

      pickingListId = item['id'];
      selectedPickingList = item!['transaction_no'];
      ispickingListSelected = selectedPickingList?.isNotEmpty ?? false;

      fromLocationId = responseFromLocID;
      selectedFromArea = responseFromAreaName;

      fromAreaId = responseFromAreaId;
      ginFromAreaController.text = responseFromAreaName;
      pickingListFromArea = responseFromAreaName;
      toLocationId = responseToLocID;
      ginToLocationController.text = responseToLocName;
      selectedToLocation = responseToLocName;
      toAreaId = responseToAreaId;
      ginToAreaController.text = responseToAreaName;
      selectedToArea = responseToAreaName;
    });
  }

  buildSaveCancelSection(device) {
    return Row(
      children: [
        Expanded(
          child: ButtonUIDisplay(
            labelText: 'cancel'.tr(),
            backgroundColor: AppColors.greyShade400,
            height: device.height() * 0.04,
            onPressed: () {
              cancelAction();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ButtonUIDisplay(
            labelText: isContinueClick ? 'loading'.tr() : 'continue'.tr(),
            backgroundColor:
                isContinueClick ? AppColors.greyShade400 : AppColors.addBtn,
            height: device.height() * 0.04,
            icon: isContinueClick
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.white,
                  ),
            onPressed: isContinueClick == true
                ? () {}
                : () {
                    setState(() {
                      isContinueClick = true;
                      saveAndContinue(context);
                    });
                  },
          ),
        ),
      ],
    );
  }

  cancelAction() {
    if (ginTxnNoController.text.isEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        NoAnimationPageRoute(builder: (context) => const HomeView()),
        (route) => false,
      );
    } else {
      goNextPage();
    }
  }

  saveAndContinue(BuildContext context) async {
    if (ginTransferTypeController.text.isEmpty) {
      stopLoading();
      showErrorToast('missingTypeTransaction'.tr());
      return;
    } else if (ginFromAreaController.text.isEmpty) {
      stopLoading();
      showErrorToast('missingFromArea'.tr());
      return;
    } else if (selectedTransferType == 'Production' &&
        selectedPickingList!.isEmpty) {
      stopLoading();
      showErrorToast('missingPickingList'.tr());
      return;
    } else if (selectedTransferType == 'Stock Transfer' &&
        selectedToLocation!.isEmpty) {
      stopLoading();
      showErrorToast('missingToLocation'.tr());
      return;
    } else if (selectedTransferType == 'Stock Transfer' &&
        selectedToArea!.isEmpty) {
      stopLoading();
      showErrorToast('missingToArea'.tr());
      return;
    } else if (selectedTransferType == 'Return to Supplier' &&
        ginReasonCodeController.text.isEmpty) {
      stopLoading();
      showErrorToast('missingReasonCode'.tr());
      return;
    } else if (ginTxnNoController.text.isEmpty) {
      bool success = await getCreateTransferAPI(context);
      if (!success) {
        isContinueClick = false;
        return;
      }
    }

    bool success;
    if (!isEdit) {
      success = await insertCreateJobDb(context);
    } else {
      success = await insertUpdateJobDb(context);
    }

    if (!success) {
      stopLoading();
    }
  }

  void stopLoading() {
    if (mounted) setState(() => isContinueClick = false);
  }

  getCreateTransferAPI(BuildContext context) async {
    try {
      // Call API function
      final transactionNo = await ApiTransferTxnhelper().createTransaction(
          'OUT', typeId, fromLocationId, reasonId, ginRemarkController.text);
      // Storage().selectedLocationID

      if (transactionNo.isNotEmpty) {
        setState(() {
          ginTxnNoController.text = transactionNo;
        });

        return true;
      } else {
        showErrorToast('failGenerateTxnNo'.tr());
        return false;
      }
    } catch (e) {
      showErrorToast('failGenerateTxnNo'.tr());
      return false;
    }
  }

  insertCreateJobDb(BuildContext context) async {
    final txnNo = ginTxnNoController.text;

    final jobModel = JobModel(
      jobStatus: 'ONGOING',
      pickingListLocationId: fromLocationId, // Storage().selectedLocationID,
      pickingListLocation:
          ginFromLocController.text, // Storage().selectedLocation,
      transactionID: ginTxnNoController.text,
      type: 'OUT',
      dateTime: ginDatetimeController.text,
      pickingListID: pickingListId,
      pickingListNo: selectedPickingList ?? '',
      selectDocumentID: 0,
      selectDocument: '',
      documentNo: '',
      typeOfTransferId: typeId,
      typeOfTransfer: selectedTransferType ?? '',
      fromLocationID: fromLocationId,
      fromLocationName: ginFromLocController.text,
      toLocationID: toLocationId,
      toLocationName: selectedToLocation!,
      fromAreaID: fromAreaId,
      fromAreaName: ginFromAreaController.text,
      toAreaID: toAreaId,
      toAreaName: ginToAreaController.text,
      reasonId: reasonId,
      reasonName: selectedReasonCode ?? '',
      remark: ginRemarkController.text,
      issuedByID: Storage().loginId,
      issuedBy: ginIssueByController.text,
      createdAt: createdAt!.isEmpty ? dateTime.getCurrentDateTime() : createdAt,
      updatedAt: dateTime.getCurrentDateTime(),
    );

    try {
      final jobExist = await DBJobData().getAddJobFromJOID(Storage().jobID);

      if (jobExist != null) {
        // A job record already exists for this ID — this shouldn't happen
        // on the "create" path. Surface it instead of doing nothing.
        debugPrint(
            "insertCreateJobDb: job already exists for jobID ${Storage().jobID}");
        showErrorToast('failCreateRecord'.tr());
        return false;
      }

      bool success = await DBJobData().createAddJob(jobModel);

      if (!success) {
        setState(() {
          isContinueClick = false;
        });

        showErrorToast('failCreateRecord'.tr());
        return false;
      }

      // Sync local storage with new ID
      final newJobData = await DBJobData().getAddJobFromTrID(txnNo);
      if (newJobData == null || newJobData is! List) {
        showErrorToast('failCreateRecord'.tr());
        return false;
      }

      var getAllSelectedJob =
          newJobData.firstWhereOrNull((element) => element['tr_id'] == txnNo);
      if (getAllSelectedJob == null) {
        showErrorToast('failCreateRecord'.tr());
        return false;
      }

      Storage().jobID = getAllSelectedJob['j_id'];
      Storage().transactionNo = getAllSelectedJob['tr_id'];

      await savePickingListItem(context, Storage().jobID.toString(), txnNo);
      return true;
    } catch (e) {
      showErrorToast('failCreateRecord'.tr());
      return false;
    }
  }

  insertUpdateJobDb(BuildContext context) async {
    final txnNo = ginTxnNoController.text;

    final jobModel = JobModel(
      jobStatus: 'ONGOING',
      pickingListLocationId: fromLocationId, //Storage().selectedLocationID,
      pickingListLocation:
          ginFromLocController.text, //Storage().selectedLocation,
      transactionID: ginTxnNoController.text,
      type: 'OUT',
      dateTime: ginDatetimeController.text,
      pickingListID: pickingListId,
      pickingListNo: selectedPickingList ?? '',
      selectDocumentID: 0,
      selectDocument: '',
      documentNo: '',
      typeOfTransferId: typeId,
      typeOfTransfer: selectedTransferType ?? '',
      fromLocationID: fromLocationId,
      fromLocationName: ginFromLocController.text,
      toLocationID: toLocationId,
      toLocationName: selectedToLocation!,
      fromAreaID: fromAreaId,
      fromAreaName: ginFromAreaController.text,
      toAreaID: toAreaId,
      toAreaName: ginToAreaController.text,
      reasonId: reasonId,
      reasonName: selectedReasonCode ?? '',
      remark: ginRemarkController.text,
      issuedByID: Storage().loginId,
      issuedBy: ginIssueByController.text,
      createdAt: createdAt!.isEmpty ? dateTime.getCurrentDateTime() : createdAt,
      updatedAt: dateTime.getCurrentDateTime(),
    );

    try {
      await DBJobData().updateJob(jobModel, Storage().jobID);

      if (oldPickingListId != jobModel.pickingListID) {
        await savePickingListItem(context, Storage().jobID.toString(), txnNo);
      } else {
        goNextPage();
      }

      return true;
    } catch (e) {
      showErrorToast('failCreateRecord'.tr());
      return false;
    }
  }

  savePickingListItem(
      BuildContext context, String currentJobId, String currentTxnNo) async {
    if (selectedPickingList!.isNotEmpty) {
      try {
        await DBGoodsData().deleteGoodsDataBasedPLID(currentTxnNo);

        final pickingListDetails =
            await ApiDocumentHelper().getPickingListDetails(
          docNo: selectedPickingList,
        );

        if (pickingListDetails != null && pickingListDetails is List) {
          List<GoodsModel> goodsToInsert = pickingListDetails
              .asMap()
              .entries
              // .where((entry) => entry.value['status'] != 3)
              .map((entry) {
            int index = entry.key; // 0-based index (0, 1, 2, ...)
            var detail = entry.value;

            return GoodsModel(
              listIndex: index,
              goodsType: 'ISSUES',
              goodsCategoryId: 0,
              goodsCategoryName: '',
              plDetailID: ValueParser.parseInt(detail['pl_detail_id']),
              goodsSKUID: ValueParser.parseInt(detail['sku_id']),
              goodsSKUName: ValueParser.formatValue(detail['sku']),
              skuDisplayName: ValueParser.formatValue(detail['desc']),
              totalQuantity: ValueParser.parseInt(detail['qty']),
              totalQuantityMax: detail.containsKey('stock_balance')
                  ? ValueParser.parseInt(
                      detail['stock_balance']['InTransitQty'])
                  : 0,
              totalQuantityNewMax: ValueParser.parseInt(
                  detail['qty']), // Original value from picking list
              totalWeight: ValueParser.parseDouble(detail['weight']),
              totalWeightMax: detail.containsKey('stock_balance')
                  ? ValueParser.parseDouble(
                      detail['stock_balance']['InTransitWeight'])
                  : 0.0,
              totalWeightNewMax: ValueParser.parseDouble(
                  detail['weight']), // Original value from picking list
              totalTray: 1, // No data from API
              trayWeight: 0.0, // No data from API
              selectTrolley: ValueParser.parseInt(detail['s_trolley']),
              trolleyWeight: ValueParser.parseDouble(detail['st_weight']),
              nettWeight: ValueParser.parseDouble(detail['weight']),
              uomQtyID: ValueParser.parseInt(detail['qty_uom_id']),
              uomQtyName: ValueParser.formatValue(detail['qty_uom_unit']),
              uomWeightID: ValueParser.parseInt(detail['weight_uom_id']),
              uomWeightName: ValueParser.formatValue(detail['weight_uom_unit']),
              qtyControl: detail['qty_control'] == true ? 1 : 0,
              weightControl: detail['weight_control'] == true ? 1 : 0,
              stockBalanceID: 0,
              productionBatchNo: ValueParser.formatValue(detail['batch_no']),
              productionDate: ValueParser.formatValue(detail['prod_date']),
              expirationDate: DateTimeParser()
                  .parseDate(ValueParser.formatValue(detail['exp_date'])),
              expireDays: 0,
              brandId: ValueParser.parseInt(detail['brand_id']),
              brandName: ValueParser.formatValue(detail['brand_name']),
              customerId: 0,
              customerName: '',
              vendorId: 0,
              vendorName: '',
              remarks: ValueParser.formatValue(detail['note']),
              rackID: ValueParser.parseInt(detail['rack_id']),
              rackName: ValueParser.formatValue(detail['rack_name']),
              palletID: 0,
              palletName: '',
              isGrouped: 0,
              groupId: '',
              status: detail['status'], // 3,
              jobId: Storage().jobID,
              transactionID: currentTxnNo,
              stockId: detail.containsKey('stock_balance')
                  ? ValueParser.parseInt(
                      detail['stock_balance']['StockBalanceID'])
                  : 0,
              stockQty: detail.containsKey('stock_balance')
                  ? ValueParser.parseInt(
                      detail['stock_balance']['InTransitQty'])
                  : 0,
              stockWeight: detail.containsKey('stock_balance')
                  ? ValueParser.parseDouble(
                      detail['stock_balance']['InTransitWeight'])
                  : 0.0,
              createdAt: dateTime.getCurrentDateTime(),
              updatedAt: dateTime.getCurrentDateTime(),
            );
          }).toList();

          await DBGoodsData().insertAllGoodsData(goodsToInsert);
        }
      } catch (e, stacktrace) {
        isContinueClick = false;
        debugPrint("Save goods pickinglist error: $e | $stacktrace");
        return;
      }
    }

    if (!mounted) return;
    goNextPage();
  }

  Future<void> removePickinglistDialog(
      BuildContext context, String typeRemove) async {
    String title = '', subtitle = '';

    if (typeRemove == 'pickingList') {
      title = 'pickingList'.tr();
      subtitle = 'changePickingList'.tr();
    } else if (typeRemove == 'transferType') {
      title = 'typeTransaction'.tr();
      subtitle = 'changeTransferType'.tr();
    } else if (typeRemove == 'fromArea') {
      title = 'fromArea'.tr();
      subtitle = 'changeFromArea'.tr();
    }

    await OptionDialog.show(
      context,
      title: title, // 'pickingList'.tr(),
      message: RichText(
        text: TextSpan(
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGrey),
          children: [
            TextSpan(
              text: subtitle, //'changePickingList'.tr(),
            ),
            TextSpan(
              text: ' ${"continue".tr()}?',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black),
            ),
          ],
        ),
      ),
      typeDialog: 'reminder',
    ).then((value) async {
      if (value == true) {
        if (typeRemove == 'pickingList' || typeRemove == 'fromArea') {
          setState(() {
            selectedPickingList = '';
            pickingListId = 0;
            ginPickingListController.clear();
            selectedFromArea = '';
            fromAreaId = 0;
            pickingListFromArea = '';
            ginFromAreaController.clear();
            toLocationId = 0;
            ginToLocationController.clear();
            selectedToLocation = '';
            toAreaId = 0;
            ginToAreaController.clear();
            selectedToArea = '';

            ispickingListSelected = selectedPickingList?.isNotEmpty ?? false;

            getPickingList(
                fromAreaID: fromAreaId, transferType: typeId, isList: true);
          });
        } else if (typeRemove == 'transferType') {
          setState(() {
            selectedPickingList = '';
            pickingListId = 0;
            selectedFromArea = '';
            fromAreaId = 0;
            pickingListFromArea = '';
            ginFromAreaController.clear();

            typeId = 0;
            selectedTransferType = '';
            ginTransferTypeController.clear();

            getPickingList(
                fromAreaID: fromAreaId, transferType: typeId, isList: true);
          });
        }
      } else {
        setState(() {
          if (typeRemove == 'transferType') {
            transferTypeKey++;
          }
        });
      }
    });
  }

  goNextPage() {
    Navigator.pushAndRemoveUntil(
      context,
      NoAnimationPageRoute(builder: (context) => const GINListView()),
      (route) => false,
    );
  }

  Widget buildDropDown({
    Key? key,
    required String labelText,
    required bool isLoading,
    required List allItems,
    required dynamic initialSelection,
    required String hintText,
    required String codeKey, // 'location_code' or 'code'
    required bool isRequired,
    required bool isMultipleText,
    required void Function(dynamic) onItemSelected,
    String descText = '',
    bool isClear = false,
    VoidCallback? onTapClear,
    bool Function()? onTapValidation,
    bool readOnly = false,
  }) {
    // --- LOADING STATE ---
    if (isLoading) {
      return DropDownUI(
        key: key,
        labelText: labelText,
        hintText: '${'loading'.tr()}...',
        allItems: ['${'loading'.tr()}...'],
        isRequired: isRequired,
        itemToString: (p) => p.toString(),
        onItemSelected: (value) {},
      );
    }

    // --- VALUE STATE ---
    return DropDownUI<dynamic>(
      key: key,
      labelText: labelText,
      hintText: hintText,
      allItems: allItems,
      initialSelection: initialSelection,
      isRequired: isRequired,
      isLoading: false,
      readOnly: readOnly,
      emptyText: "${'noDataFor'.tr()} '$labelText'",
      itemToString: (item) {
        if (item == null) return "";
        if (item is String) return item;

        return item[codeKey]?.toString() ?? "";
      },
      labelWidget: !isMultipleText
          ? null
          : (context, item, constraints) {
              if (item == null) return const Text("N/A");
              if (item is String) return Text(item);

              // Cast the item to a Map so Dart allows the [] operator
              final mapItem = item as Map<String, dynamic>;

              return SizedBox(
                width: constraints.maxWidth - 40,
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: mapItem[codeKey].toString(),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    TextSpan(
                        text: descText.isEmpty
                            ? ' - '
                            : mapItem[descText] == null
                                ? ''
                                : ' - ',
                        style: const TextStyle(color: Colors.black)),
                    TextSpan(
                      text: descText.isEmpty
                          ? mapItem['name'].toString()
                          : mapItem[descText] == null
                              ? ''
                              : mapItem[descText].toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ]),
                ),
              );
            },
      onItemSelected: onItemSelected,
      isClear: isClear,
      onTapClear: onTapClear,
      onTapValidation: onTapValidation,
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
  void dispose() {
    super.dispose();

    ginDatetimeController.dispose();
    ginTxnNoController.dispose();
    ginTransferTypeController.dispose();
    ginFromAreaController.dispose();
    ginToLocationController.dispose();
    ginToAreaController.dispose();
    ginPickingListController.dispose();
    ginIssueByController.dispose();
    ginUploadController.dispose();
    ginRemarkController.dispose();
  }
}
