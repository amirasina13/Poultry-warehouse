import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'
    as barcode;

import '../../../config/config.dart';
import '../../../custom_page_route.dart';
import '../../../data/local/local.dart';
import '../../../data/model/model.dart';
import '../../../helper/helper.dart';
import '../../widgets/data_driven/data_driven.dart';
import '../../widgets/data_driven/dropdown_widget.dart';
import '../../widgets/independent/independent.dart';
import 'grn_list_view.dart';

class GRNAddSkuView extends StatefulWidget {
  final String transactionType;
  final String pageTitle;
  final int areaID;
  final int docId;

  const GRNAddSkuView({
    super.key,
    required this.transactionType,
    required this.pageTitle,
    required this.areaID,
    required this.docId,
  });

  @override
  State<GRNAddSkuView> createState() => _GRNAddSkuViewState();
}

class _GRNAddSkuViewState extends State<GRNAddSkuView> {
  // Controllers
  final grnCategoryController = TextEditingController();
  final grnSkuController = TextEditingController();
  final grnProdDateController = TextEditingController();
  final grnExpiredDateController = TextEditingController();
  final grnQtyController = TextEditingController();
  final grnWeightController = TextEditingController();
  final grnWeightNetController = TextEditingController();
  final grnBluetoothWeightController = TextEditingController();
  final grnProdBatchController = TextEditingController();
  final grnNoTrayController = TextEditingController();
  final grnTrolleyController = TextEditingController();
  final grnClientController = TextEditingController();
  final grnVendorController = TextEditingController();
  final grnRackController = TextEditingController();
  final grnTrayTypeController = TextEditingController();
  final grnDocNoController = TextEditingController();

  Key trolleyKey = UniqueKey();

  // selected
  String selectedCategory = '',
      selectedSku = '',
      selectedProdBatch = '',
      selectedTrayType = '',
      selectedRack = '',
      selectedClient = '',
      selectedVendor = '';

  // ID & item
  String transactionType = '',
      grnSkuDesc = '',
      grnUomQtyName = '',
      grnUomWeightName = '',
      grnBrandName = '',
      // grnTrayWeight = '',
      createdAt = '',
      groupId = '';

  // Int value
  int plDetailId = 0,
      grnTrolley = 0,
      grnAvailableQty = 0,
      grnClientId = 0,
      grnVendorId = 0,
      isGrouped = 0,
      itemExpired = 0,
      grnCategoryId = 0,
      grnUomQtyId = 0,
      grnProdBatchId = 0,
      grnBrandId = 0,
      grnRackId = 0,
      grnSkuId = 0,
      grnUomWeightId = 0,
      grnTrayId = 0,
      skuStatus = 0,
      grnQtyControl = 0,
      grnWeightControl = 0,
      grnStockBalanceId = 0,
      grnStockBalanceQty = 0,
      existingListindex = 0;

  // Double value
  double goodsWeightMax = 0.0;
  double grnAvailableWeight = 0.0;
  double grnTrayWeight = 0.0;
  double grnStockBalanceWeight = 0.0;

  // List
  List<dynamic> categoryList = [];
  List<dynamic> skuNameList = [];
  List<dynamic> prodBatchNoList = [];
  List<dynamic> clientList = [];
  List<dynamic> vendorList = [];
  List<dynamic> trayBakulList = [];
  List<dynamic> rackList = [];
  List<dynamic> trolleyList = [];
  List<dynamic> trolleyResult = [];

  // final List<dynamic> trolleyOptions = [
  //   {"index": 0, "label": "None", "value": 0.0},
  //   // {"index": 1, "label": "Small (5KG)", "value": 5.0},
  //   // {"index": 2, "label": "Medium (5.5KG)", "value": 5.5},
  //   // {"index": 3, "label": "Large (6KG)", "value": 6.0},
  //   // {"index": 4, "label": "Special (6.8KG)", "value": 6.8},
  // ];
  final List<dynamic> trolleyOptions = [
    // {"area": "", "id": 0, "name": "None", "type": "Pallet", "weight": "0.0"}
  ];

  // bool
  bool isPageLoading = true;
  bool isLoadingCategory = false;
  bool isLoadingSku = false;
  bool isLoadingProdBatchNo = false;
  bool isLoadingClient = false;
  bool isLoadingVendor = false;
  bool isLoadingTray = false;
  bool isLoadingRack = false;
  bool isLoadingTrolley = false;
  bool isSkuSaved = false;
  bool isReadOnly = false;

  bool quantityControl = true;
  bool weightControl = true;
  bool isSaving = false;
  bool hasLoadError = false;

  // FocusNode
  final bluetoothFocus = FocusNode();

  // DateTime
  // Initialize dateTime
  late DateTime expiredDate;

  // Get Date and Time
  DateTime currentDatetime = DateTime.now();
  late var formatDatetime =
      DateFormat("yyyy-MM-dd").add_Hms().format(currentDatetime);

  final dateFormat = DateFormat("yyyy-MM-dd");

  String formatDate(dynamic dateTime) {
    // Handle null, empty, or "null" string cases immediately
    if (dateTime == null || dateTime == '' || dateTime == 'null') {
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }

    try {
      final DateTime parsedDate = DateTime.parse(dateTime.toString());
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      // If parsing fails, fall back to current date instead of returning an error string
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  // Bluetooth weight provider
  final ValueNotifier<double> netWeightNotifier = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();

    initData();
  }

  Future<void> initData() async {
    isPageLoading = true;

    try {
      transactionType = widget.transactionType;
      isReadOnly = Storage().goodsReceive != 0;
      grnNoTrayController.text = '1'; // set default value = 1

      await getGlobalList();
      await loadGoodsData();
    } catch (e) {
      debugPrint("Init Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isPageLoading = false;
        });
      }
    }
  }

  // Call global api: Category, tray, rack, client, vendor
  getGlobalList() async {
    setState(() {
      isLoadingCategory = true;
      isLoadingTray = true;
      isLoadingRack = true;
      isLoadingTrolley = true;
    });

    try {
      // final results = await Future.wait([
      //   ApiGlobalHelper().getCategoryList(),
      //   ApiGlobalHelper().getRack(widget.areaID),
      //   ApiGlobalHelper().getTrayTrolleyList(),
      // ]);

      // final categoryResult = results[0];
      // final rackResult = results[1];
      // final trayTrolleyMap = results[2];

      final categoryResult = await ApiGlobalHelper().getCategoryList();
      final rackResult = await ApiGlobalHelper().getRack(widget.areaID);
      final trayTrolleyMap = await ApiGlobalHelper().getTrayTrolleyList();

      // Safe extraction with default empty lists if key is missing or map is empty
      final List rawTray = (trayTrolleyMap['tray'] as List?) ?? [];
      final List rawTrolley = (trayTrolleyMap['trolley'] as List?) ?? [];

      List rearrangeTrolley = List.from(rawTrolley);
      if (rearrangeTrolley.isNotEmpty) {
        rearrangeTrolley.sort((a, b) {
          if (a['name'] == 'None') return -1;
          if (b['name'] == 'None') return 1;
          return 0;
        });
      }

      if (!mounted) return;
      setState(() {
        categoryList = categoryResult;
        trayBakulList = rawTray;
        rackList = rackResult;
        trolleyList =
            rearrangeTrolley.isNotEmpty ? rearrangeTrolley : trolleyOptions;

        if (selectedTrayType.isEmpty && trayBakulList.isNotEmpty) {
          var defaultTray = trayBakulList.first;
          grnTrayId = defaultTray['id'];
          selectedTrayType =
              '${defaultTray['name']} (${defaultTray['weight']} KG)';
          grnTrayTypeController.text = defaultTray['name'];
          grnTrayWeight = double.parse(defaultTray['weight']);

          // Trigger calculation so the "unselected" item's weight is included
          calculateNettWeight();
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        hasLoadError = true;
      });
      showErrorToast('failedToLoadMasterData'.tr());
    } finally {
      if (mounted) {
        setState(() {
          isLoadingCategory = false;
          isLoadingTray = false;
          isLoadingRack = false;
          isLoadingTrolley = false;
        });
      }
    }

    /* CALL API ONLY IF TRANSACTION TYPE IS LOGISTIC OR RETURN TO SUPPLIER */
    if (transactionType == 'Return by Customer') {
      setState(() => isLoadingClient = true);

      final clientResult = await ApiGlobalHelper().getClientList();

      setState(() {
        clientList = clientResult;

        isLoadingClient = false;
      });
    }

    if (transactionType == 'Purchase') {
      setState(() => isLoadingVendor = true);

      final vendorResult = await ApiGlobalHelper().getVendorList();

      setState(() {
        vendorList = vendorResult;

        isLoadingVendor = false;
      });
    }
  }

  // Call inventory API
  getInventoryList(int category) async {
    setState(() => isLoadingSku = true);

    final results = await ApiGlobalHelper().getInventoryList(category);

    setState(() {
      skuNameList = results;

      isLoadingSku = false;
    });
  }

  loadGoodsData() async {
    final value =
        await DBGoodsData().getGoodsDataBasedID(Storage().goodsReceive);

    if (value == null) return;

    var goodsResult = value[0];

    existingListindex = goodsResult['list_index'];
    grnCategoryId = goodsResult['ct_id'] ?? 0;
    selectedCategory = goodsResult['ct_name'];
    grnCategoryController.text = goodsResult['ct_name'];
    plDetailId = goodsResult['pld_id'];
    grnSkuId = goodsResult['gs_id'] ?? 0;
    selectedSku = '${goodsResult['sku_name']} / ${goodsResult['gs_name']}';
    grnSkuController.text = goodsResult['gs_name'];
    grnQtyController.text = goodsResult['t_quantity'].toString();
    grnAvailableQty = goodsResult['tq_max'];
    grnWeightController.text = goodsResult['t_weight'].toString();
    grnAvailableWeight = goodsResult['tw_max'];
    grnNoTrayController.text = goodsResult['tt_tray'].toString();
    grnTrolley = goodsResult['s_trolley'] ?? 0;
    grnTrolleyController.text = goodsResult['st_weight'].toString();
    grnWeightNetController.text = goodsResult['nt_weight'].toString();
    netWeightNotifier.value = goodsResult['nt_weight'] ?? 0.0;
    grnUomQtyId = goodsResult['uq_id'];
    grnUomQtyName = goodsResult['uq_name'];
    grnUomWeightId = goodsResult['uw_id'];
    grnUomWeightName = goodsResult['uw_name'];
    quantityControl = goodsResult['q_control'] == 1;
    weightControl = goodsResult['w_control'] == 1;
    grnProdBatchId = goodsResult['sb_id'];
    grnProdBatchController.text = goodsResult['pb_no'];
    grnProdDateController.text =
        goodsResult['p_date'].isEmpty ? formatDate('') : goodsResult['p_date'];
    grnExpiredDateController.text =
        goodsResult['e_date'].isEmpty ? '-' : goodsResult['e_date'];
    itemExpired = goodsResult['expire_days'] ?? 0;
    grnBrandId = goodsResult['b_id'];
    grnBrandName = goodsResult['b_name'];
    grnClientId = goodsResult['c_id'] ?? 0;
    selectedClient = goodsResult['c_name'];
    grnClientController.text = goodsResult['c_name'];
    grnVendorId = goodsResult['v_id'] ?? 0;
    selectedVendor = goodsResult['v_name'];
    grnVendorController.text = goodsResult['v_name'];
    grnRackId = goodsResult['r_id'];
    selectedRack = goodsResult['r_name'];
    grnRackController.text = goodsResult['r_name'];
    grnTrayId = goodsResult['p_id'];
    grnTrayTypeController.text = goodsResult['p_name'];
    grnTrayWeight = goodsResult['tray_weight'];
    selectedTrayType = '${grnTrayTypeController.text} ($grnTrayWeight KG)';
    grnStockBalanceId = goodsResult['stockBalanceId'];
    grnStockBalanceQty = goodsResult['stockBalanceQty'];
    grnStockBalanceWeight = goodsResult['stockBalanceWeight'];
    skuStatus = goodsResult['status'];
    createdAt = goodsResult['created_at'];

    if (isReadOnly) {
      setState(() {
        getInventoryList(grnCategoryId);
        // getMasterDataBatchNoFromAPI(selectedSku);
      });
    }
  }

  void handleBackButton(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      NoAnimationPageRoute(builder: (context) => const GRNListView()),
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
    var device = OrientationHelper(context);
    context.locale;
    final bluetoothState = Provider.of<BluetoothHelper>(context, listen: false);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        handleBackButton(context);
      },
      child: PoultryScaffold(
        showAppbar: true,
        title: '${widget.pageTitle} ${'item'.tr()}',
        isShowLeading: true,
        onBackPressed: () {
          handleBackButton(context);
        },
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
                              // TEXTFIELD CATEGORY
                              buildCategoryFieldSection(),
                              // TEXTFIELD SKU
                              buildDropDown(
                                labelText: 'sku'.tr(),
                                hintText: grnSkuController.text,
                                allItems: skuNameList,
                                initialSelection: selectedSku,
                                isRequired: true,
                                isLoading: isLoadingSku,
                                isMultipleText: true,
                                disableSort: true,
                                readOnly: isReadOnly ? true : false,
                                spacerSymbol: ' / ',
                                onItemSelected: (item) {
                                  // prodBatchNoList = [];
                                  grnProdBatchController.text = '';

                                  onInventoryItemSelected(item);

                                  calculateExpiredDate(currentDatetime);
                                },
                                codeKey: 'inventory_name',
                                multipleText: 'sku_account',
                              ),
                            ),

                            // TEXTFIELD PRODUCTION BATCH NO
                            buildProdBatchFieldSection(),

                            buildProdExpireDateSection(),

                            rowExpanded(
                              // TEXTFIELD QUANTITY
                              buildQtyFieldSection(),
                              // DROPDOWN CLIENT / VENDOR
                              buildClientVendorSection(),
                            ),

                            WeightSectionWidget(
                              bluetoothState: bluetoothState,
                              device: device,
                              weightControl: weightControl,
                              goodsWeightMax: goodsWeightMax,
                              ginBluetoothWeightController:
                                  grnBluetoothWeightController,
                              ginWeightController: grnWeightController,
                              ginWeightNetController: grnWeightNetController,
                              bluetoothFocus: bluetoothFocus,
                              netWeightNotifier: netWeightNotifier,
                              availableWeight: grnAvailableWeight,
                              onWeightChanged: calculateNettWeight,
                              jobType: 'GRN',
                            ),

                            TextUIDisplay(
                              labelText: 'trayUpper'.tr(),
                              fontSize: AppSettings.fontSizeMain,
                              fontWeight: FontWeight.bold,
                            ),

                            rowExpanded(
                              // DROPDOWN TYPE OF TRAY
                              buildDropDown(
                                labelText: 'traytype'.tr(),
                                hintText: grnTrayTypeController.text,
                                allItems: trayBakulList,
                                // initialSelection: selectedTrayType,
                                initialSelection: trayBakulList.isNotEmpty
                                    ? (selectedTrayType.isEmpty
                                        ? '${trayBakulList.first['name']} (${trayBakulList.first['weight']} KG)'
                                        : selectedTrayType)
                                    : '',
                                isRequired: false,
                                isLoading: isLoadingTray,
                                isMultipleText: true,
                                isTray: true,
                                disableSort: true,
                                onItemSelected: (item) {
                                  grnTrayId = item['id'];
                                  // selectedTrayType = item['name'];
                                  selectedTrayType =
                                      '${item['name']} (${item['weight']} KG)';
                                  grnTrayTypeController.text = item['name'];

                                  grnTrayWeight = double.parse(item['weight']);

                                  if (grnTrayWeight == 0) {
                                    grnNoTrayController.text = '1';
                                  }

                                  calculateNettWeight();
                                },
                                codeKey: 'name',
                                multipleText: 'weight',
                              ),
                              // TEXTFIELD NO OF TRAY
                              TextFieldInput(
                                controller: grnNoTrayController,
                                labelText: 'numberTray'.tr(),
                                obscureToggleEnabled: false,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9]"))
                                ],
                                onTap: () {
                                  if (selectedTrayType.isEmpty) {
                                    Future.delayed(Duration.zero, () {
                                      FocusScope.of(context).unfocus();
                                    });
                                    showErrorToast('selecteTrayType'.tr());
                                  }
                                },
                                onChanged: (value) {
                                  calculateNettWeight();
                                },
                              ),
                            ),

                            // TEXTFIELD RACK
                            FieldButton(
                              fieldSection: buildDropDown(
                                labelText: 'rack'.tr(),
                                hintText: grnRackController.text,
                                allItems: rackList,
                                initialSelection: selectedRack,
                                isRequired: false,
                                isLoading: isLoadingRack,
                                isMultipleText: true,
                                hideBorder: true,
                                onItemSelected: (item) {
                                  grnRackId = item['id'];
                                  selectedRack = item['name'];
                                  grnRackController.text = item['name'];
                                },
                                codeKey: 'name',
                                multipleText: 'code',
                              ),
                              buttonIcon: Icons.qr_code_scanner,
                              buttonText: 'scan'.tr(),
                              onPressed: () {
                                // Trigger scan
                                scanRackID();
                              },
                            ),

                            if (trolleyList.isNotEmpty) ...[
                              TextUIDisplay(
                                labelText: 'selectTrolley'.tr(),
                                fontSize: AppSettings.fontSizeMain,
                                fontWeight: FontWeight.bold,
                              )
                            ] else ...[
                              const SizedBox.shrink()
                            ],

                            // RADIO BUTTON TROLLEY
                            CustomRadioButtonUI<dynamic>(
                              key: trolleyKey,
                              options: trolleyList, // trolleyOptions,
                              initialValue: trolleyList.isNotEmpty
                                  ? ((grnTrolley >= 0 &&
                                          grnTrolley < trolleyList.length)
                                      ? trolleyList[grnTrolley]
                                      : trolleyList[0])
                                  : null,
                              labelBuilder: (option) {
                                if (option['name'].toString().toLowerCase() ==
                                    'none') {
                                  return '${option['name']}';
                                } else {
                                  return '${option['name']} (${option['weight']} KG)';
                                }
                                // return '${option['name']} (${option['weight']}KG)';
                              }, // how to display text
                              direction: Axis.horizontal,
                              onChanged: (selected) {
                                onTrolleySelected(selected);
                              },
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
              child: buildSaveCompleteSection(device),
            ),
          ],
        ),
      ),
    );
  }

  // getMasterDataBatchNoFromAPI(String selectedSku) async {
  //   setState(() => isLoadingProdBatchNo = true);

  //   final prodBatchNo =
  //       await ApiGlobalHelper().getStockBalance(selectedSku, widget.areaID);

  //   setState(() {
  //     prodBatchNoList = prodBatchNo;

  //     isLoadingProdBatchNo = false;
  //   });
  // }

  void onInventoryItemSelected(dynamic items) {
    if (items == null) return;

    // selectedSku = items['sku_account'];
    selectedSku = '${items['inventory_name']} / ${items['sku_account']}';
    grnSkuController.text = items['sku_account'];
    grnSkuId = items['inventory_id'];
    grnSkuDesc = items['inventory_name'];
    grnUomQtyId = items['uom_qty_id'] ?? 0;
    grnUomQtyName = items['uom_qty'] ?? '';
    grnUomWeightId = items['uom_weight_id'] ?? 0;
    grnUomWeightName = items['uom_weight'] ?? '';
    grnQtyControl = items['quantity_control'] ?? 0;
    grnWeightControl = items['weight_control'] ?? 0;
    grnBrandId = items['brand_id'] ?? 0;
    grnBrandName = items['brand_name'] ?? '';

    // getMasterDataBatchNoFromAPI(selectedSku);

    setState(() {
      quantityControl = (grnQtyControl == 1);
      weightControl = (grnWeightControl == 1);

      if (!quantityControl) grnQtyController.text = '0';
      if (!weightControl) grnWeightController.text = '0';

      itemExpired = items['expire_date'] ?? 0;
    });
  }

  void onProdBatchItemSelected(dynamic items) {
    if (items == null) return;

    grnProdBatchController.text = items['batch_no'];
    selectedProdBatch = items['batch_no'];
    grnProdBatchId = items['id'];
    grnRackController.text = items['rack_name'] ?? '';
    selectedRack = items['rack_name'] ?? '';
    grnRackId = items['rack_id'] ?? '';
    grnProdDateController.text = items['prod_date'].isNotEmpty
        ? DateTimeParser().parseDate(items['prod_date'])
        : '-';
    grnExpiredDateController.text = items['exp_date'].isNotEmpty
        ? DateTimeParser().parseDate(items['exp_date'])
        : '-';

    isGrouped = items['is_grouped'] == true ? 1 : 0;
    groupId = items['grouped_ids'].toString();

    setState(() {
      grnAvailableQty = int.parse(items['qty']);
      grnAvailableWeight = double.parse(items['weight']);
    });
  }

  void onTrolleySelected(dynamic selectedItem) {
    grnTrolley = trolleyList.indexOf(selectedItem);

    grnTrolleyController.text = selectedItem['weight'].toString();

    calculateNettWeight();
  }

  void calculateNettWeight() {
    try {
      // double trayWeight = double.tryParse(grnTrayWeight) ?? 0.0;
      int noOfTray = int.tryParse(grnNoTrayController.text) ?? 0;
      double trolleyWeight = double.tryParse(grnTrolleyController.text) ?? 0.0;

      // Check if the weight input is actually filled
      String weightText = grnWeightController.text;

      double totalDeductions = trolleyWeight + (grnTrayWeight * noOfTray);

      if (weightText.isEmpty) {
        // Option A: Keep net weight at 0 until input weight is provided
        netWeightNotifier.value = 0.0;

        // Tip: You might want a separate notifier for 'totalDeductions'
        // to show the user that the trolley weight was accepted.
      } else {
        double inputWeight = double.tryParse(weightText) ?? 0.0;
        netWeightNotifier.value = inputWeight - totalDeductions;
      }
    } catch (e) {
      netWeightNotifier.value = 0.0;
    }
  }

  Widget buildCategoryFieldSection() {
    if (Storage().goodsReceive != 0 && grnCategoryId == 0) {
      return const SizedBox();
    }

    return buildDropDown(
      labelText: 'category'.tr(),
      hintText: grnCategoryController.text,
      allItems: categoryList,
      initialSelection: selectedCategory,
      isRequired: true,
      readOnly: isReadOnly,
      isLoading: isLoadingCategory,
      isMultipleText: false,
      disableSort: true,
      onItemSelected: (item) {
        grnCategoryController.text = item['name'];
        selectedCategory = item['name'];
        grnCategoryId = item['id'];
        // skuNameList.clear();
        selectedSku = '';
        grnSkuId = 0;
        grnSkuDesc = '';
        // prodBatchNoList = [];
        grnProdBatchController.text = '';
        grnProdDateController.clear();
        grnExpiredDateController.clear();

        getInventoryList(grnCategoryId);
      },
      codeKey: 'name',
    );
  }

  Widget buildProdBatchFieldSection() {
    if (grnProdBatchId == 0) return const SizedBox();

    if (isReadOnly) {
      return TextFieldInput(
        controller: grnProdBatchController,
        labelText: 'prodBatchNo'.tr(),
        obscureToggleEnabled: false,
        readOnly: true,
      );
    }

    return const SizedBox();

    // return buildDropDown(
    //   labelText: 'prodBatchNo'.tr(),
    //   hintText: grnProdBatchController.text,
    //   allItems: prodBatchNoList,
    //   initialSelection: selectedProdBatch,
    //   isRequired: true,
    //   isLoading: isLoadingProdBatchNo,
    //   isMultipleText: true,
    //   readOnly: isReadOnly ? true : false,
    //   onItemSelected: (item) {
    //     onProdBatchItemSelected(item);
    //   },
    //   codeKey: 'batch_no',
    //   isStockBalanceText: true,
    // );
  }

  Widget buildProdExpireDateSection() {
    if (transactionType == 'Stock Transfer') return const SizedBox();

    return rowExpanded(
      // TEXTFIRLD PRODUCTION DATE
      TextFieldInput(
        controller: grnProdDateController,
        labelText: 'productionDate'.tr(),
        obscureToggleEnabled: false,
        readOnly: true,
        readOnlyColor: AppColors.white,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000), // Earliest possible date
            lastDate: DateTime(2101), // Latest possible date
          );

          if (pickedDate != null) {
            calculateExpiredDate(pickedDate);
          }
        },
      ),
      // TEXTFIELD EXPIRED DATE
      TextFieldInput(
        controller: grnExpiredDateController,
        labelText: 'expireDate'.tr(),
        obscureToggleEnabled: false,
        readOnly: true,
        readOnlyColor: AppColors.white,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000), // Earliest possible date
            lastDate: DateTime(2101), // Latest possible date
          );

          if (pickedDate != null) {
            String formattedDate =
                "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
            grnExpiredDateController.text = formattedDate;
          }
        },
      ),
    );
  }

  Widget buildQtyFieldSection() {
    if (!quantityControl) return const SizedBox();

    return TextFieldInput(
      controller: grnQtyController,
      labelText: '${'quantity'.tr()} ',
      obscureToggleEnabled: false,
      keyboardType: TextInputType.number,
      isRequired: quantityControl,
      suffixIcon: Text(grnUomQtyName),
    );
  }

  Widget buildClientVendorSection() {
    if (transactionType == 'Production' ||
        transactionType == 'Stock Transfer') {
      return const SizedBox();
    }

    if (transactionType == 'Return by Customer') {
      return buildDropDown(
        labelText: 'client'.tr(),
        hintText: grnClientController.text,
        allItems: clientList,
        initialSelection: selectedClient,
        isRequired: true,
        isLoading: isLoadingClient,
        isMultipleText: false,
        onItemSelected: (item) {
          grnClientId = item['id'];
          selectedClient = item['name'];
          grnClientController.text = item['name'];
        },
        codeKey: 'name',
      );
    } else {
      return buildDropDown(
        labelText: 'vendor'.tr(),
        hintText: grnVendorController.text,
        allItems: vendorList,
        initialSelection: selectedVendor,
        isRequired: true,
        isLoading: isLoadingVendor,
        isMultipleText: false,
        onItemSelected: (item) {
          grnVendorId = item['id'];
          grnVendorController.text = item['name'];
          selectedVendor = item['name'];
          // selectedVendor = value['name'];
          // goodsIssuesVendorID = value['id'].toString();
        },
        codeKey: 'name',
      );
    }
  }

  Widget buildSaveCompleteSection(device) {
    return Row(
      children: [
        Expanded(
          child: !isSkuSaved
              ? ButtonUIDisplay(
                  labelText: 'cancel'.tr(),
                  backgroundColor: AppColors.greyShade400,
                  height: device.height() * 0.05,
                  onPressed: () {
                    cancelAction();
                  },
                )
              : ButtonUIDisplay(
                  labelText: 'complete'.tr(),
                  backgroundColor: AppColors.downloadBtn,
                  height: device.height() * 0.05,
                  icon: Icon(
                    Icons.check,
                    color: AppColors.white,
                  ),
                  onPressed: () {
                    completeAction();
                  },
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ButtonUIDisplay(
            labelText: isSaving ? 'saving'.tr() : 'save'.tr(),
            backgroundColor: AppColors.addBtn,
            height: device.height() * 0.05,
            icon: Icon(
              Icons.save,
              color: AppColors.white,
            ),
            onPressed: isSaving ? () {} : () => saveAction(),
          ),
        ),
      ],
    );
  }

  calculateExpiredDate(DateTime pickedDate) {
    String formattedDate =
        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
    grnProdDateController.text = formattedDate;

    expiredDate = pickedDate.add(Duration(days: itemExpired));

    setState(() {
      grnExpiredDateController.text =
          DateFormat("yyyy-MM-dd").format(expiredDate).toString();
    });
  }

  cancelAction() {
    Navigator.pushAndRemoveUntil(
      context,
      NoAnimationPageRoute(builder: (context) => const GRNListView()),
      (route) => false,
    );
  }

  bool validateInputs() {
    if (Storage().goodsReceive == 0 && selectedCategory.isEmpty) {
      showErrorToast('missingCategory'.tr());
      return false;
    }
    if (grnSkuController.text.isEmpty) {
      showErrorToast('missingSku'.tr());
      return false;
    }
    if (quantityControl && grnQtyController.text.isEmpty) {
      showErrorToast('missingQuantity'.tr());
      return false;
    }
    if (weightControl && grnWeightController.text.isEmpty) {
      showErrorToast('missingWeight'.tr());
      return false;
    }
    if (weightControl && (double.parse(grnWeightNetController.text) < 0)) {
      showErrorToast('invalidNetWeight'.tr());
      return false;
    }
    if (transactionType == 'Purchase' && grnVendorController.text.isEmpty) {
      showErrorToast('missingVendor'.tr());
      return false;
    }
    if (transactionType == 'Return by Customer' &&
        grnClientController.text.isEmpty) {
      showErrorToast('missingClient'.tr());
      return false;
    }
    if (widget.docId == 0 &&
        (grnNoTrayController.text.isEmpty || grnNoTrayController.text == '0')) {
      showErrorToast('missingNoTray'.tr());
      return false;
    }
    return true;
  }

  Future<void> saveAction() async {
    // Synchronous guard against double-taps
    if (isSaving) return;
    if (!validateInputs()) return;

    setState(() => isSaving = true);

    try {
      await insertUpdateGoodsDb(context);
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> insertUpdateGoodsDb(BuildContext context) async {
    try {
      bool isNewRecord = Storage().goodsReceive == 0;

      // Determine the index to save:
      int listIndexToSave;
      if (isNewRecord) {
        // Get the current total count of items in the local DB for this transaction
        int existingCount =
            await DBGoodsData().getGoodsCountByTxn(Storage().transactionNo);
        listIndexToSave = existingCount; // Auto-increment index
      } else {
        // Keep existing index when updating
        listIndexToSave = existingListindex;
      }

      final goodsModel = GoodsModel(
        listIndex: listIndexToSave,
        goodsType: 'RECEIVE',
        goodsCategoryId: grnCategoryId,
        goodsCategoryName: grnCategoryController.text,
        plDetailID: plDetailId,
        goodsSKUID: grnSkuId,
        goodsSKUName: grnSkuController.text,
        skuDisplayName: grnSkuDesc,
        totalQuantity: int.parse(grnQtyController.text),
        totalQuantityMax: 0,
        totalQuantityNewMax: 0,
        totalWeight: double.parse(grnWeightController.text),
        totalWeightMax: 0,
        totalWeightNewMax: 0,
        totalTray: int.parse(
            grnNoTrayController.text.isEmpty ? '1' : grnNoTrayController.text),
        trayWeight: grnTrayWeight,
        selectTrolley: grnTrolley,
        trolleyWeight: double.parse(grnTrolleyController.text.isEmpty
            ? '0'
            : grnTrolleyController.text),
        nettWeight: double.parse(grnWeightNetController.text),
        uomQtyID: grnUomQtyId,
        uomQtyName: grnUomQtyName,
        uomWeightID: grnUomWeightId,
        uomWeightName: grnUomWeightName.toString(),
        qtyControl: quantityControl == true ? 1 : 0,
        weightControl: weightControl == true ? 1 : 0,
        stockBalanceID: grnProdBatchId,
        productionBatchNo: grnProdBatchController.text,
        productionDate:
            grnProdDateController.text == '-' ? '' : grnProdDateController.text,
        expirationDate: grnExpiredDateController.text == '-'
            ? ''
            : grnExpiredDateController.text,
        expireDays: itemExpired,
        brandId: grnBrandId,
        brandName: grnBrandName.toString(),
        customerId: grnClientId,
        customerName: grnClientController.text,
        vendorId: grnVendorId,
        vendorName: grnVendorController.text,
        rackID: grnRackId,
        rackName: grnRackController.text,
        palletID: grnTrayId,
        palletName: grnTrayTypeController.text,
        isGrouped: isGrouped,
        groupId: groupId,
        status: skuStatus == 0 ? 1 : skuStatus, // 1= PENDING | 3= COMPLETE
        jobId: Storage().jobID,
        transactionID: Storage().transactionNo,
        stockId: grnStockBalanceId,
        stockQty: grnStockBalanceQty,
        stockWeight: grnStockBalanceWeight,
        createdAt: createdAt.isEmpty ? currentDatetime.toString() : createdAt,
        updatedAt: currentDatetime.toString(),
      );

      if (isNewRecord) {
        await DBGoodsData().createGoodsData(goodsModel);
      } else {
        await DBGoodsData().updateGoodsData(goodsModel, Storage().goodsReceive);
      }

      if (!mounted) return;
      setState(() {
        isSkuSaved = true;
        grnWeightController.clear();
      });
      Fluttertoast.showToast(
          msg: 'saveData'.tr(), fontSize: 16, backgroundColor: Colors.green);
    } catch (e) {
      if (mounted) showErrorToast('failToSave'.tr());
    }
  }

  completeAction() {
    Navigator.push(context,
        NoAnimationPageRoute(builder: (context) => const GRNListView()));
  }

  Future<void> scanRackID() async {
    //Initiate barcode variable to get result from scan
    String barcodeScanRes;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await barcode.FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // line color
        'Cancel', // cancel button
        true, // enable flash
        barcode.ScanMode.BARCODE, // scan mode
      );

      if (!mounted) return;

      if (barcodeScanRes != '-1') {
        // Check if got rack item in inventory
        var getRackName = rackList.firstWhereOrNull(
            (element) => element['name'].toString() == barcodeScanRes);

        setState(() {
          if (getRackName == null) {
            grnRackController.clear();
            selectedRack = '';
            grnRackId = 0;

            showErrorToast('missingRackId'.tr());
          } else {
            grnRackController.text = barcodeScanRes;
            selectedRack = barcodeScanRes;
            grnRackId = getRackName['id'];
          }
        });
      }
    } on PlatformException {
      if (!mounted) return;
      showErrorToast('noItemRack'.tr());
    }
  }

  Widget rowExpanded(Widget start, Widget end) {
    // Create list of the raw widgets
    List<Widget> children = [start, end];

    // Remove the SizedBox first
    List<Widget> filteredChildren =
        children.where((w) => w is! SizedBox).toList();

    if (filteredChildren.isEmpty) return const SizedBox();

    return Row(
      children: filteredChildren.map((widget) {
        // Wrap widget in Expanded
        return Expanded(child: widget);
      }).expand((widget) sync* {
        yield widget;
        yield const SizedBox(width: 15);
      }).toList()
        ..removeLast(),
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
    bool readOnly = false,
    bool isStockBalanceText = false,
    String? multipleText,
    bool isTray = false,
    bool hideBorder = false,
    String? spacerSymbol = ' - ',
    required void Function(dynamic) onItemSelected,
    bool disableSort = false,
  }) {
    // --- LOADING STATE ---
    if (isLoading) {
      return DropDownUI(
        labelText: labelText,
        hintText: '${'loading'.tr()}...',
        allItems: ['loading'.tr()],
        isRequired: isRequired,
        readOnly: readOnly,
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
      hideBorder: hideBorder,
      disableSort: disableSort,
      emptyText: "No data for '$labelText'",
      itemToString: (item) {
        if (item == null) return "";
        if (item is String) return item;

        if (isMultipleText) {
          if (isTray) {
            return '${item[codeKey]?.toString()} (${item[multipleText]?.toString()} KG)';
          }
          return '${item[codeKey]?.toString()} / ${item[multipleText]?.toString()}';
        }

        return item[codeKey]?.toString() ?? "";
      },
      labelWidget: !isMultipleText
          ? null
          : (context, item, constraints) {
              if (item == null) return const Text("N/A");
              if (item is String) return Text(item);

              final mapItem = item as Map<String, dynamic>;

              return SizedBox(
                width: constraints.maxWidth - 40,
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  text: TextSpan(children: [
                    TextSpan(
                      text: mapItem[codeKey].toString(),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    TextSpan(
                        text: isTray ? ' ' : spacerSymbol,
                        style: const TextStyle(color: Colors.black)),
                    isStockBalanceText
                        ? stockBalanceDetails(mapItem)
                        : TextSpan(
                            text: multipleText == null
                                ? mapItem['name'].toString()
                                : isTray
                                    ? '(${mapItem[multipleText]} KG)'
                                    : mapItem[multipleText],
                            style: const TextStyle(
                              fontSize: AppSettings.fontSizeMain,
                              color: Colors.black,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                  ]),
                ),
              );
            },
      onItemSelected: onItemSelected,
    );
  }

  TextSpan stockBalanceDetails(items) {
    String qtyText = items['qty'] != null
        ? 'Qty: ${items['qty']} ${items['qty_uom_unit'] ?? ''}'
        : '';

    String weightText = items['weight'] != null
        ? 'Weight: ${items['weight']} ${items['weight_uom_unit'] ?? ''}'
        : '';

    String prodDateText = items['prod_date'].isNotEmpty
        ? 'Prod: ${formatDate(items['prod_date'].toString())}'
        : '';

    String expDateText = items['exp_date'].isNotEmpty
        ? 'Exp: ${formatDate(items['exp_date'].toString())}'
        : '';

    // Join only non-empty parts
    String details = [qtyText, weightText, prodDateText, expDateText]
        .where((e) => e.isNotEmpty)
        .join(', ');

    return TextSpan(
      text: details,
      style: const TextStyle(
        fontSize: AppSettings.fontSizeMain,
        color: Colors.black,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose all your controllers...
    netWeightNotifier.dispose();

    grnCategoryController.dispose();
    grnSkuController.dispose();
    grnProdDateController.dispose();
    grnExpiredDateController.dispose();
    grnQtyController.dispose();
    grnWeightController.dispose();
    grnWeightNetController.dispose();
    grnBluetoothWeightController.dispose();
    grnProdBatchController.dispose();
    grnNoTrayController.dispose();
    grnTrolleyController.dispose();
    grnClientController.dispose();
    grnVendorController.dispose();
    grnRackController.dispose();
    grnTrayTypeController.dispose();
    grnDocNoController.dispose();
  }
}
