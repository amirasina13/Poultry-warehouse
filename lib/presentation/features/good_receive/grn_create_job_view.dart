// ignore_for_file: use_build_context_synchronously

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
import 'grn_list_view.dart';

class GRNCreateJobView extends StatefulWidget {
  final String pageTitle;
  const GRNCreateJobView({
    super.key,
    required this.pageTitle,
  });

  @override
  State<GRNCreateJobView> createState() => _GRNCreateJobViewState();
}

class _GRNCreateJobViewState extends State<GRNCreateJobView> {
  // Controllers
  final grnDatetimeController = TextEditingController();
  final grnTransferTypeController = TextEditingController();
  final grnFromLocController = TextEditingController();
  final grnFromAreaController = TextEditingController();
  final grnToLocationController = TextEditingController();
  final grnToAreaController = TextEditingController();
  final grnDocNoController = TextEditingController();
  final grnReasonCodeController = TextEditingController();
  final grnTxnNoController = TextEditingController();
  final grnIssueByController = TextEditingController();
  final grnUploadController = TextEditingController();
  final grnRemarkController = TextEditingController();

  int oldTypeId = 0,
      typeId = 0,
      fromLocationId = 0,
      toLocationId = 0,
      oldDocId = 0,
      docId = 0,
      fromAreaId = 0,
      toAreaId = 0,
      grnIssuedById = 0,
      reasonId = 0;

  // IDs & State
  String? createdAt;

  String? selectedTransferType,
      selectedDocNo,
      selectedFromLocation,
      selectedFromArea,
      selectedToArea,
      selectedReasonCode;

  bool isPageLoading = true;
  bool isLoadingFromArea = false;
  bool isLoadingDocNo = false;
  bool isLoadingReason = false;

  bool showExtraField = false;
  bool showReasonField = false;
  bool showImportantSymbol = false;
  bool isContinueClick = false;
  bool isDocSelected = false;
  bool get isEdit => widget.pageTitle == 'edit'.tr();

  List<dynamic> transferTypeList = [
    {"id": 1, "name": "Purchase"},
    {"id": 3, "name": "Stock Transfer"},
    {"id": 4, "name": "Return by Customer"},
  ];
  // List<dynamic> locationList = [];
  List<dynamic> fromAreaList = [];
  List<dynamic> toAreaList = [];
  List<dynamic> filterDocNo = [];
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
      await getMasterDataFromAPI();
      await loadJobData();
    } catch (e) {
      debugPrint("Init Error: $e");
    } finally {
      setState(() {
        isPageLoading = false; // Data is ready
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

    grnTxnNoController.text = job.transactionID;
    grnDatetimeController.text = job.dateTime;
    oldTypeId = job.typeOfTransferId;
    typeId = job.typeOfTransferId;
    selectedTransferType = job.typeOfTransfer;
    grnTransferTypeController.text = job.typeOfTransfer;
    oldDocId = job.selectDocumentID;
    docId = job.selectDocumentID;
    selectedDocNo = job.selectDocument;
    grnDocNoController.text = job.selectDocument;
    fromLocationId = job.fromLocationID;
    selectedFromLocation = job.toLocationName;
    grnFromLocController.text = job.fromLocationName;
    toLocationId =
        job.toLocationID == 0 ? Storage().selectedLocationID : job.toLocationID;
    grnToLocationController.text = job.toLocationName.isEmpty
        ? Storage().selectedLocation
        : job.toLocationName;
    grnRemarkController.text = job.remark;
    grnIssuedById = Storage().loginId;
    grnIssueByController.text = Storage().loginName;
    grnUploadController.text = Storage().loginName;
    fromAreaId = job.fromAreaID;
    selectedFromArea = job.fromAreaName;
    grnFromAreaController.text = job.fromAreaName;
    toAreaId = job.toAreaID;
    selectedToArea = job.toAreaName;
    grnToAreaController.text = job.toAreaName;
    createdAt = job.createdAt;
    reasonId = job.reasonId;
    selectedReasonCode = job.reasonName;
    grnReasonCodeController.text = job.reasonName;

    showExtraField = (job.typeOfTransfer == "Stock Transfer");
    showReasonField = (job.typeOfTransfer == "Return by Customer");
    isDocSelected = selectedDocNo?.isNotEmpty ?? false;

    if (showExtraField) {
      getDocumentNoFromAPI(typeId, 'to');
    }

    if (showReasonField) {
      getReasonCodeAPI();
    }
  }

  getMasterDataFromAPI() async {
    toAreaList =
        await ApiGlobalHelper().getAreaList(Storage().selectedLocationID);
  }

  getReasonCodeAPI() async {
    setState(() {
      isLoadingReason = true;
    });

    final reasonResult = await ApiGlobalHelper().getReasonCodeList();

    setState(() {
      reasonCodeList = reasonResult;

      isLoadingReason = false;
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
        title: '${widget.pageTitle} GRN',
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
                                controller: grnDatetimeController,
                                labelText: 'datetime'.tr(),
                                obscureToggleEnabled: false,
                                readOnly: true,
                              ),
                              // TEXTFIELD TRANSACTION NO
                              TextFieldInput(
                                controller: grnTxnNoController,
                                labelText: 'transactionNo'.tr(),
                                obscureToggleEnabled: false,
                                readOnly: true,
                              ),
                            ),

                            rowExpanded(
                              // TEXTFIELD ISSUED BY
                              TextFieldInput(
                                controller: grnIssueByController,
                                labelText: 'issueBy'.tr(),
                                obscureToggleEnabled: false,
                                readOnly: true,
                              ),
                              // TEXTFIELD UPLOADED BY
                              TextFieldInput(
                                controller: grnUploadController,
                                labelText: 'uploadBy'.tr(),
                                obscureToggleEnabled: false,
                                readOnly: true,
                              ),
                            ),

                            const Divider(),

                            // DROPDOWN TRANSACTION TYPE
                            buildDropDown(
                              labelText: 'typeTransaction'.tr(),
                              hintText: grnTransferTypeController.text,
                              allItems: transferTypeList,
                              initialSelection: selectedTransferType,
                              isRequired: true,
                              isLoading: false,
                              isMultipleText: false,
                              readOnly: widget.pageTitle == 'edit'.tr(),
                              isClear: widget.pageTitle == 'edit'.tr() &&
                                  selectedDocNo!.isNotEmpty,
                              onItemSelected: (item) {
                                transferTypeAction(item);
                              },
                              codeKey: 'name',
                              onTapClear: () {
                                setState(() {
                                  if (widget.pageTitle == 'edit'.tr() &&
                                      selectedDocNo!.isNotEmpty) {
                                    changeTransactionDoc(
                                        context,
                                        'typeTransaction'.tr(),
                                        'changeGRNTransferType'.tr(),
                                        clearTransferTypeGRNInfo);
                                  }
                                });
                              },
                            ),

                            // DROPDOWN REASON CODE & DROPDOWN DOC NO
                            buildReasonDocFieldSection(),

                            // TEXTFIELD FROM LOCATION & FROM AREA
                            buildExtraFieldsSection(),

                            rowExpanded(
                              // TEXTFIELD TO LOCATION
                              TextFieldInput(
                                controller: grnToLocationController,
                                labelText: 'toLocation'.tr(),
                                obscureToggleEnabled: false,
                                readOnly: true,
                              ),
                              // DROPDOWN TO AREA
                              buildDropDown(
                                labelText: 'toArea'.tr(),
                                hintText: typeId == 3
                                    ? '${'select'.tr()} ${'document'.tr()}'
                                    : '${'select'.tr()} ${'toArea'.tr()}',
                                allItems: toAreaList,
                                initialSelection: selectedToArea,
                                isRequired: true,
                                isLoading: false,
                                readOnly: isDocSelected,
                                isMultipleText: true,
                                onItemSelected: (item) {
                                  selectedToArea = item['name'];
                                  grnToAreaController.text = item['name'];
                                  toAreaId = item['id'];
                                },
                                codeKey: 'name',
                              ),
                            ),

                            // TEXTFIELD REMARK
                            TextFieldInput(
                              controller: grnRemarkController,
                              labelText: 'remark'.tr(),
                              obscureToggleEnabled: false,
                              isLargeTextfield: true,
                            ),
                          ]
                              .where((widget) => widget is! SizedBox)
                              .expand((widget) sync* {
                                yield const SizedBox(height: 10);
                                yield widget;
                                yield const SizedBox(height: 10);
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

  Widget buildReasonDocFieldSection() {
    if (showExtraField) {
      // DROPDOWN DOCUMENT NO
      return buildDropDown(
        labelText: 'document'.tr(),
        codeKey: 'transfer_no',
        hintText: grnDocNoController.text,
        allItems: filterDocNo,
        isRequired: selectedTransferType == 'Stock Transfer' ? true : false,
        isLoading: isLoadingDocNo,
        isMultipleText: false,
        isClear: selectedDocNo!.isNotEmpty && createdAt!.isNotEmpty,
        initialSelection: selectedDocNo,
        onItemSelected: (item) {
          setState(() {
            docId = item['transfer_id'];
            selectedDocNo = item!['transfer_no'];
            grnDocNoController.text = item!['transfer_no'];

            isDocSelected = selectedDocNo?.isNotEmpty ?? false;

            grnFromLocController.text = item['from_name'];
            fromLocationId = item['from_location_id'];

            fromAreaId = item['from_area_id'];
            selectedFromArea = item['from_area_name'] ?? '';
            grnFromAreaController.text = item['from_area_name'];

            grnToLocationController.text = item['to_name'];
            toLocationId = item['to_location_id'];

            toAreaId = item['to_area_id'];
            selectedToArea = item['to_area_name'] ?? '';
            grnToAreaController.text = item['to_area_name'] ?? '';
          });
        },
        onTapClear: () {
          if (createdAt!.isNotEmpty) {
            changeTransactionDoc(context, 'document'.tr(),
                'changeDocument'.tr(), clearStockTransferInfo);
          }
        },
      );
    }

    if (showReasonField) {
      return buildDropDown(
        labelText: 'reasonCode'.tr(),
        codeKey: 'name',
        descText: 'desc',
        hintText: grnReasonCodeController.text,
        allItems: reasonCodeList,
        isRequired: true,
        isMultipleText: true,
        isLoading: isLoadingReason,
        initialSelection: selectedReasonCode,
        onItemSelected: (item) {
          if (item != null) {
            setState(() {
              grnReasonCodeController.text = item['name'];
              selectedReasonCode = item['name'];
              reasonId = item['id'];
            });
          }
        },
      ); // Return empty list if hidden
    }

    return const SizedBox();
  }

  Widget buildExtraFieldsSection() {
    if (!showExtraField) {
      return const SizedBox(); // Return empty list if hidden
    }

    // Will show only for transaction type = stock transfer
    return rowExpanded(
      // TEXTFIELD FROM LOCATION
      TextFieldInput(
        controller: grnFromLocController,
        labelText: 'fromLocation'.tr(),
        obscureToggleEnabled: false,
        readOnly: true,
        hintText: '${'select'.tr()} ${'document'.tr()}',
      ),
      // TEXTFIELD FROM AREA
      TextFieldInput(
        controller: grnFromAreaController,
        labelText: 'fromArea'.tr(),
        obscureToggleEnabled: false,
        readOnly: true,
        hintText: '${'select'.tr()} ${'document'.tr()}',
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

  Future<void> transferTypeAction(dynamic value) async {
    if (value == null) return;

    setState(() {
      selectedTransferType = value['name'];
      grnTransferTypeController.text = value['name'];
      typeId = value['id'];

      showExtraField = (selectedTransferType == "Stock Transfer");
      showReasonField = (selectedTransferType == "Return by Customer");
      isDocSelected = (selectedTransferType == "Stock Transfer");

      if (selectedTransferType != 'Return by Customer') {
        selectedReasonCode = '';
        reasonId = 0;
        grnReasonCodeController.clear();
      }

      if (selectedTransferType == "Stock Transfer") {
        getDocumentNoFromAPI(typeId, 'to');
      }

      clearStockTransferInfo();

      if (showReasonField) {
        getReasonCodeAPI();
      }
    });

    if (oldTypeId == 3 && typeId != 3) {
      await DBGoodsData().deleteGoodsDataBasedPLID(Storage().transactionNo);
    }
  }

  getDocumentNoFromAPI(int type, String locationType) async {
    setState(() => isLoadingDocNo = true);

    final docResult = await ApiDocumentHelper().getDocumentNoList(
        type: type,
        locationType: locationType,
        // getGinDoc: true,
        // ginDocNo: '',
        isList: true,
        isPagination: false);

    if (!mounted) return;
    setState(() {
      filterDocNo = docResult;
      isLoadingDocNo = false;
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
            onPressed: isContinueClick
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
    if (grnTxnNoController.text.isEmpty) {
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
    if (grnTransferTypeController.text.isEmpty) {
      isContinueClick = false;
      showErrorToast('missingTypeTransaction'.tr());
      return;
    } else if (selectedTransferType == 'Stock Transfer' &&
        selectedDocNo!.isEmpty) {
      isContinueClick = false;
      showErrorToast('missingSelectDocument'.tr());
      return;
    } else if (selectedTransferType == 'Return by Customer' &&
        grnReasonCodeController.text.isEmpty) {
      isContinueClick = false;
      showErrorToast('missingReasonCode'.tr());
      return;
    } else if (selectedToArea!.isEmpty) {
      isContinueClick = false;
      showErrorToast('missingToArea'.tr());
      return;
    } else if (grnTxnNoController.text.isEmpty) {
      // getCreateTransferAPI(context);
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

  getCreateTransferAPI(context) async {
    try {
      // Call API function
      final transactionNo = await ApiTransferTxnhelper().createTransaction(
          'IN',
          typeId,
          Storage().selectedLocationID,
          reasonId,
          grnRemarkController.text);

      if (transactionNo.isNotEmpty) {
        setState(() {
          grnTxnNoController.text = transactionNo;
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
    final txnNo = grnTxnNoController.text;

    final jobModel = JobModel(
      jobStatus: 'ONGOING',
      pickingListLocationId: Storage().selectedLocationID,
      pickingListLocation: Storage().selectedLocation,
      transactionID: grnTxnNoController.text,
      type: 'IN',
      dateTime: grnDatetimeController.text,
      pickingListID: 0,
      pickingListNo: '',
      selectDocumentID: docId,
      selectDocument: grnDocNoController.text,
      documentNo: grnDocNoController.text,
      typeOfTransferId: typeId,
      typeOfTransfer: selectedTransferType ?? '',
      fromLocationID: fromLocationId,
      fromLocationName: grnFromLocController.text,
      toLocationID: toLocationId,
      toLocationName: grnToLocationController.text,
      fromAreaID: fromAreaId,
      fromAreaName: grnFromAreaController.text,
      toAreaID: toAreaId,
      toAreaName: grnToAreaController.text,
      reasonId: reasonId,
      reasonName: selectedReasonCode ?? '',
      remark: grnRemarkController.text,
      issuedByID: Storage().loginId,
      issuedBy: grnIssueByController.text,
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
        isContinueClick = false;
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

      await saveDocListItem(context, typeId, txnNo);
      return true;
    } catch (e) {
      showErrorToast('failCreateRecord'.tr());
      return false;
    }
  }

  insertUpdateJobDb(context) async {
    final txnNo = grnTxnNoController.text;

    final jobModel = JobModel(
      jobStatus: 'ONGOING',
      pickingListLocationId: Storage().selectedLocationID,
      pickingListLocation: Storage().selectedLocation,
      transactionID: grnTxnNoController.text,
      type: 'IN',
      dateTime: grnDatetimeController.text,
      pickingListID: 0,
      pickingListNo: '',
      selectDocumentID: docId,
      selectDocument: grnDocNoController.text,
      documentNo: grnDocNoController.text,
      typeOfTransferId: typeId,
      typeOfTransfer: selectedTransferType ?? '',
      fromLocationID: fromLocationId,
      fromLocationName: grnFromLocController.text,
      toLocationID: toLocationId,
      toLocationName: grnToLocationController.text,
      fromAreaID: fromAreaId,
      fromAreaName: grnFromAreaController.text,
      toAreaID: toAreaId,
      toAreaName: grnToAreaController.text,
      reasonId: reasonId,
      reasonName: selectedReasonCode ?? '',
      remark: grnRemarkController.text,
      issuedByID: Storage().loginId,
      issuedBy: grnIssueByController.text,
      createdAt: createdAt!.isEmpty ? dateTime.getCurrentDateTime() : createdAt,
      updatedAt: dateTime.getCurrentDateTime(),
    );

    try {
      await DBJobData().updateJob(jobModel, Storage().jobID);

      if (oldDocId != jobModel.selectDocumentID) {
        await saveDocListItem(context, typeId, txnNo);
      } else {
        goNextPage();
      }

      return true;
    } catch (e) {
      isContinueClick = false;
      showErrorToast('failCreateRecord'.tr());
      return false;
    }
  }

  saveDocListItem(BuildContext context, int typeId, String currentTxnNo) async {
    if (selectedDocNo!.isNotEmpty) {
      try {
        await DBGoodsData().deleteGoodsDataBasedPLID(currentTxnNo);

        final documentDetails = await ApiDocumentHelper().getDocumentNoDetails(
          docNo: selectedDocNo,
        );

        if (documentDetails != null && documentDetails is List) {
          List<GoodsModel> goodsToInsert = documentDetails
              .asMap()
              .entries
              // .where((entry) => entry.value['status'] != 3)
              .map((entry) {
            int index = entry.key; // 0-based index (0, 1, 2, ...)
            var detail = entry.value;

            return GoodsModel(
              listIndex: index,
              goodsType: 'RECEIVE',
              goodsCategoryId: 0,
              goodsCategoryName: '',
              plDetailID: ValueParser.parseInt(detail['pl_detail_id']),
              goodsSKUID: ValueParser.parseInt(detail['sku_id']),
              goodsSKUName: ValueParser.formatValue(detail['sku']),
              skuDisplayName: ValueParser.formatValue(detail['desc']),
              totalQuantity: ValueParser.parseInt(detail['qty']),
              totalQuantityMax: ValueParser.parseInt(detail['qty']),
              totalQuantityNewMax: 0,
              totalWeight: ValueParser.parseDouble(detail['weight']),
              totalWeightMax: ValueParser.parseDouble(detail['weight']),
              totalWeightNewMax: 0,
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
              expirationDate: ValueParser.formatValue(detail['exp_date']),
              expireDays: 0,
              brandId: ValueParser.parseInt(detail['brand_id']),
              brandName: ValueParser.formatValue(detail['brand_name']),
              customerId: ValueParser.parseInt(detail['client_id']),
              customerName: ValueParser.formatValue(detail['client_name']),
              vendorId: ValueParser.parseInt(detail['vendor_id']),
              vendorName: ValueParser.formatValue(detail['vendor_name']),
              remarks: ValueParser.formatValue(detail['note']),
              rackID: ValueParser.parseInt(detail['rack_id']),
              rackName: ValueParser.formatValue(detail['rack_name']),
              palletID: 0,
              palletName: '',
              isGrouped: 0,
              groupId: '',
              status: detail['status'] ?? 1,
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
      } catch (e, stack) {
        isContinueClick = false;
        debugPrint("saveDocListItem error: $e");
        debugPrint("$stack");
      }
    }

    if (!mounted) return;
    goNextPage();
  }

  Future changeTransactionDoc(
    BuildContext context,
    String title,
    String message,
    Function onConfirm,
  ) async {
    await OptionDialog.show(
      context,
      title: title,
      message: RichText(
        text: TextSpan(
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGrey),
          children: [
            TextSpan(
              text: message,
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
        setState(() {
          onConfirm();
          isDocSelected = selectedDocNo?.isNotEmpty ?? false;
        });
      }
    });
  }

  clearTransferTypeGRNInfo() {
    selectedTransferType = '';
    grnTransferTypeController.clear();
    typeId = 0;
    showExtraField = false;
    showReasonField = false;

    docId = 0;
    selectedDocNo = '';
    grnDocNoController.text = '';

    grnFromLocController.text = '';
    fromLocationId = 0;

    fromAreaId = 0;
    selectedFromArea = '';
    grnFromAreaController.text = '';

    toAreaId = 0;
    selectedToArea = '';
    grnToAreaController.text = '';
  }

  clearStockTransferInfo() {
    docId = 0;
    selectedDocNo = '';
    grnDocNoController.text = '';

    grnFromLocController.text = '';
    fromLocationId = 0;

    fromAreaId = 0;
    selectedFromArea = '';
    grnFromAreaController.text = '';

    toAreaId = 0;
    selectedToArea = '';
    grnToAreaController.text = '';
  }

  goNextPage() {
    Navigator.pushAndRemoveUntil(
      context,
      NoAnimationPageRoute(builder: (context) => const GRNListView()),
      (route) => false,
    );
  }

  Widget buildDropDown({
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
    bool readOnly = false,
  }) {
    // --- LOADING STATE ---
    if (isLoading) {
      return DropDownUI(
        labelText: labelText,
        hintText: '${'loading'.tr()}...',
        allItems: ['loading'.tr()],
        isRequired: isRequired,
        itemToString: (p) => p.toString(),
        onItemSelected: (value) {},
      );
    }

    // --- VALUE STATE ---
    return DropDownUI<dynamic>(
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

              // 1. Cast the item to a Map so Dart allows the [] operator
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
                    const TextSpan(
                        text: ' - ', style: TextStyle(color: Colors.black)),
                    TextSpan(
                      text: descText.isEmpty
                          ? mapItem['name'].toString()
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

    grnDatetimeController.dispose();
    grnTxnNoController.dispose();
    grnTransferTypeController.dispose();
    grnFromAreaController.dispose();
    grnToLocationController.dispose();
    grnToAreaController.dispose();
    grnDocNoController.dispose();
    grnIssueByController.dispose();
    grnUploadController.dispose();
    grnRemarkController.dispose();
  }
}
