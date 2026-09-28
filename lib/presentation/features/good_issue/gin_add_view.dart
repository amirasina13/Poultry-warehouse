import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
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
import 'good_issue.dart';

class GINAddSkuView extends StatefulWidget {
  final String transactionType;
  final String pageTitle;
  final int areaID;
  final int pickingListID;

  const GINAddSkuView(
      {super.key,
      required this.transactionType,
      required this.pageTitle,
      required this.areaID,
      required this.pickingListID});

  @override
  State<GINAddSkuView> createState() => _GINAddSkuViewState();
}

class _GINAddSkuViewState extends State<GINAddSkuView> {
  // Controllers
  final ginCategoryController = TextEditingController();
  final ginSkuController = TextEditingController();
  final ginProdDateController = TextEditingController();
  final ginExpiredDateController = TextEditingController();
  final ginQtyController = TextEditingController();
  final ginWeightController = TextEditingController();
  final ginWeightNetController = TextEditingController();
  final ginBluetoothWeightController = TextEditingController();
  final ginProdBatchController = TextEditingController();
  final ginNoTrayController = TextEditingController();
  final ginTrolleyController = TextEditingController();
  final ginClientController = TextEditingController();
  final ginVendorController = TextEditingController();
  final ginRackController = TextEditingController();
  final ginTrayTypeController = TextEditingController();

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
      ginSkuDesc = '',
      ginUomQtyName = '',
      ginUomWeightName = '',
      ginBrandName = '',
      // ginTrayWeight = '',
      createdAt = '',
      groupId = '';

  // Int value
  int ginTrolley = 0,
      ginAvailableQty = 0,
      ginClientId = 0,
      ginVendorId = 0,
      isGrouped = 0,
      ginQtyControl = 0,
      ginWeightControl = 0,
      ginCategoryId = 0,
      ginSkuId = 0,
      plDetailId = 0,
      ginUomQtyId = 0,
      ginUomWeightId = 0,
      ginBrandId = 0,
      ginTrayId = 0,
      ginRackId = 0,
      skuStatus = 0,
      ginProdBatchId = 0,
      ginStockBalanceId = 0,
      ginStockBalanceQty = 0,
      pickingListQty = 0,
      existingListindex = 0;

  // Double value
  double goodsWeightMax = 0.0;
  double ginAvailableWeight = 0.0;
  double ginTrayWeight = 0.0;
  double ginStockBalanceWeight = 0.0;
  double pickingListWeight = 0.0;

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

  final List<dynamic> trolleyOptions = [
    {"area": "", "id": 0, "name": "None", "type": "Pallet", "weight": "0.0"}
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

  bool quantityControl = true;
  bool weightControl = true;
  bool isSaving = false;
  bool hasLoadError = false;

  // FocusNode
  final bluetoothFocus = FocusNode();

  // DateTime
  // Get Date and Time
  DateTime currentDatetime = DateTime.now();
  late var formatDatetime =
      DateFormat("yyyy-MM-dd").add_Hms().format(currentDatetime);

  String formatDate(String dateTime) {
    try {
      // print('DATE 1: $dateTime');
      if (dateTime == '' || dateTime == 'null') {
        return DateFormat('yyyy-MM-dd')
            .format(currentDatetime); // Format to only show date
      } else {
        final DateTime parsedDate = DateTime.parse(dateTime);
        return DateFormat('yyyy-MM-dd')
            .format(parsedDate); // Format to only show date
      }
    } catch (e) {
      // print('Error parsing date: $e');
      return dateTime; // Return the original string if parsing fails
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
      ginNoTrayController.text = '1'; // set default value = 1

      await getGlobalList();
      await loadGoodsData();
    } catch (e, stacktrace) {
      debugPrint("Init Error: $e | $stacktrace");
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
      final categoryResult = await ApiGlobalHelper().getCategoryList();
      final rackResult = await ApiGlobalHelper().getRack(widget.areaID);
      final trayTrolleyMap = await ApiGlobalHelper().getTrayTrolleyList();

      // Safe extraction with default empty lists if key is missing or map is empty
      final List rawTray = (trayTrolleyMap['tray'] as List?) ?? [];
      final List rawTrolley = (trayTrolleyMap['trolley'] as List?) ?? [];

      List rearrangeTrolley = List.from(rawTrolley);

      // Rearrange back the list if 'None' is at the back
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
          ginTrayId = defaultTray['id'];
          selectedTrayType =
              '${defaultTray['name']} (${defaultTray['weight']} KG)';
          ginTrayTypeController.text = defaultTray['name'];
          ginTrayWeight = double.parse(defaultTray['weight']);

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
    if (transactionType == 'Logistic') {
      setState(() => isLoadingClient = true);

      final clientResult = await ApiGlobalHelper().getClientList();

      setState(() {
        clientList = clientResult;

        isLoadingClient = false;
      });
    }

    if (transactionType == 'Return to Supplier') {
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
    setState(() {
      isLoadingSku = true;
      skuNameList = [];
    });

    final results = await ApiGlobalHelper().getInventoryList(category);

    if (!mounted) return;
    // Only update if the user hasn't switched away to a different SKU while waiting
    // ignore: unnecessary_this
    if (this.ginCategoryId == category) {
      setState(() {
        skuNameList = results;
        isLoadingSku = false;
      });
    }
  }

  loadGoodsData() async {
    final value =
        await DBGoodsData().getGoodsDataBasedID(Storage().goodsIssues);

    if (value == null) return;

    var goodsResult = value[0];

    existingListindex = goodsResult['list_index'];
    ginCategoryId = goodsResult['ct_id'];
    selectedCategory = goodsResult['ct_name'];
    ginCategoryController.text = goodsResult['ct_name'];
    plDetailId = goodsResult['pld_id'];
    ginSkuId = goodsResult['gs_id'];
    selectedSku = '${goodsResult['sku_name']} / ${goodsResult['gs_name']}';
    ginSkuController.text = goodsResult['gs_name'];
    ginQtyController.text = goodsResult['t_quantity'].toString();
    ginAvailableQty = goodsResult['tq_max'] ?? 0;
    //goodsResult['stockBalanceQty'] ?? 0; //goodsResult['tq_max'] ?? 0;
    ginWeightController.text = goodsResult['t_weight'].toString();
    ginAvailableWeight = goodsResult['tw_max'] ??
        0.0; // goodsResult['stockBalanceWeight'] ?? 0.0; //goodsResult['tw_max'] ?? 0.0;
    ginNoTrayController.text = goodsResult['tt_tray'].toString();
    ginTrolley = goodsResult['s_trolley'] ?? 0;
    ginTrolleyController.text = goodsResult['st_weight'].toString();
    ginWeightNetController.text = goodsResult['nt_weight'].toString();
    netWeightNotifier.value = goodsResult['nt_weight'] ?? 0.0;
    ginUomQtyId = goodsResult['uq_id'];
    ginUomQtyName = goodsResult['uq_name'];
    ginUomWeightId = goodsResult['uw_id'];
    ginUomWeightName = goodsResult['uw_name'];
    quantityControl = goodsResult['q_control'] == 1;
    weightControl = goodsResult['w_control'] == 1;
    ginProdBatchId = goodsResult['sb_id'];
    selectedProdBatch = goodsResult['pb_no'];
    ginProdBatchController.text = goodsResult['pb_no'];
    ginProdDateController.text =
        goodsResult['p_date'].isEmpty ? '-' : goodsResult['p_date'];
    ginExpiredDateController.text = goodsResult['e_date'].isEmpty
        ? '-'
        : DateTimeParser().parseDate(goodsResult['e_date']);
    ginBrandId = goodsResult['b_id'];
    ginBrandName = goodsResult['b_name'];
    ginClientId = goodsResult['c_id'] ?? 0;
    selectedClient = goodsResult['c_name'];
    ginClientController.text = goodsResult['c_name'];
    ginVendorId = goodsResult['v_id'] ?? 0;
    selectedVendor = goodsResult['v_name'];
    ginVendorController.text = goodsResult['v_name'];
    ginRackId = goodsResult['r_id'];
    selectedRack = goodsResult['r_name'];
    ginRackController.text = goodsResult['r_name'];
    ginTrayId = goodsResult['p_id'];
    ginTrayTypeController.text = goodsResult['p_name'];
    ginTrayWeight = goodsResult['tray_weight'];
    selectedTrayType = '${ginTrayTypeController.text} ($ginTrayWeight KG)';
    ginStockBalanceId = goodsResult['stockBalanceId'];
    ginStockBalanceQty = goodsResult['stockBalanceQty'];
    ginStockBalanceWeight = goodsResult['stockBalanceWeight'];
    skuStatus = goodsResult['status'];
    createdAt = goodsResult['created_at'];
    isGrouped = goodsResult['is_grouped'];
    groupId = goodsResult['grouped_ids'];
    pickingListQty = goodsResult['tqn_max'];
    pickingListWeight = goodsResult['twn_max'];

    if (plDetailId == 0) {
      setState(() {
        getInventoryList(ginCategoryId);
        getMasterDataBatchNoFromAPI(goodsResult['gs_name']);
      });
    }
  }

  void handleBackButton(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      NoAnimationPageRoute(builder: (context) => const GINListView()),
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
                                hintText: ginSkuController.text,
                                allItems: skuNameList,
                                initialSelection: selectedSku,
                                isRequired: true,
                                isLoading: isLoadingSku,
                                isMultipleText: true,
                                disableSort: true,
                                readOnly: plDetailId != 0 ? true : false,
                                spacerSymbol: ' / ',
                                onItemSelected: (item) {
                                  prodBatchNoList = [];
                                  ginProdBatchId = 0;
                                  ginProdBatchController.text = '';
                                  selectedProdBatch = '';

                                  ginQtyController.clear();
                                  ginWeightController.clear();
                                  ginWeightNetController.clear();

                                  onInventoryItemSelected(item);
                                },
                                codeKey: 'inventory_name',
                                multipleText: 'sku_account',
                              ),
                            ),

                            // DROPDOWN PRODUCTION BATCH NO
                            buildDropDown(
                              labelText: 'prodBatchNo'.tr(),
                              hintText: ginProdBatchController.text,
                              allItems: prodBatchNoList,
                              initialSelection: selectedProdBatch,
                              isRequired: true,
                              isLoading: isLoadingProdBatchNo,
                              isMultipleText: true,
                              readOnly: plDetailId != 0 ? true : false,
                              onItemSelected: (item) {
                                onProdBatchItemSelected(item);
                              },
                              codeKey: 'batch_no',
                              isStockBalanceText: true,
                            ),

                            rowExpanded(
                              // TEXTFIRLD PRODUCTION DATE
                              TextFieldInput(
                                controller: ginProdDateController,
                                labelText: 'productionDate'.tr(),
                                obscureToggleEnabled: false,
                                readOnly: true,
                              ),
                              // TEXTFIELD EXPIRED DATE
                              TextFieldInput(
                                controller: ginExpiredDateController,
                                labelText: 'expireDate'.tr(),
                                obscureToggleEnabled: false,
                                readOnly: true,
                              ),
                            ),

                            rowExpanded(
                              // TEXTFIELD QUANTITY
                              buildQtyFieldSection(device),
                              // DROPDOWN CLIENT / VENDOR
                              buildClientVendorSection(device),
                            ),

                            WeightSectionWidget(
                              bluetoothState: bluetoothState,
                              device: device,
                              weightControl: weightControl,
                              goodsWeightMax: goodsWeightMax,
                              ginBluetoothWeightController:
                                  ginBluetoothWeightController,
                              ginWeightController: ginWeightController,
                              ginWeightNetController: ginWeightNetController,
                              bluetoothFocus: bluetoothFocus,
                              netWeightNotifier: netWeightNotifier,
                              availableWeight: ginAvailableWeight,
                              onWeightChanged: calculateNettWeight,
                              jobType: 'GIN',
                              availableView: availableDetails(
                                  ginAvailableWeight.toString(),
                                  pickingListWeight.toString()),
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
                                hintText: ginTrayTypeController.text,
                                allItems: trayBakulList,
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
                                  ginTrayId = item['id'];
                                  // selectedTrayType = item['name'];
                                  ginTrayTypeController.text = item['name'];
                                  selectedTrayType =
                                      '${item['name']} (${item['weight']} KG)';

                                  ginTrayWeight = double.parse(item['weight']);

                                  if (ginTrayWeight == 0) {
                                    ginNoTrayController.text = '1';
                                  }

                                  calculateNettWeight();
                                },
                                codeKey: 'name',
                                multipleText: 'weight',
                              ),
                              // TEXTFIELD NO OF TRAY
                              TextFieldInput(
                                controller: ginNoTrayController,
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
                                hintText: ginRackController.text,
                                allItems: rackList,
                                initialSelection: selectedRack,
                                isRequired: false,
                                isLoading: isLoadingRack,
                                isMultipleText: true,
                                hideBorder: true,
                                onItemSelected: (item) {
                                  ginRackId = item['id'];
                                  selectedRack = item['name'];
                                  ginRackController.text = item['name'];
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
                                  ? ((ginTrolley >= 0 &&
                                          ginTrolley < trolleyList.length)
                                      ? trolleyList[ginTrolley]
                                      : trolleyList[0])
                                  : null,
                              // initialValue: trolleyList.firstWhere(
                              //   (item) => item['name'] == ginTrolley,
                              //   orElse: () => trolleyList[0],
                              // ),
                              labelBuilder: (option) {
                                if (option['name'].toString().toLowerCase() ==
                                    'none') {
                                  return '${option['name']}';
                                } else {
                                  return '${option['name']} (${option['weight']} KG)';
                                }
                                // if (option['name'] == 'None') {
                                //   return '${option['name']}';
                                // } else {
                                // return '${option['name']} (${option['weight']} KG)';
                                // }
                                // if (option['name']
                                //         .toString()
                                //         .contains('None') ||
                                //     option['weight'] == "0.00") {
                                //   return '${option['name']}';
                                // } else {
                                //   return '${option['name']} (${option['weight']} KG)';
                                // }
                              },
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

  getMasterDataBatchNoFromAPI(String selectedSku) async {
    setState(() => isLoadingProdBatchNo = true);

    final prodBatchNo =
        await ApiGlobalHelper().getStockBalance(selectedSku, widget.areaID);

    if (!mounted) return;
    // Only update if the user hasn't switched away to a different SKU while waiting
    if (ginSkuController.text == selectedSku) {
      setState(() {
        prodBatchNoList = prodBatchNo;
        isLoadingProdBatchNo = false;
      });
    }
  }

  void onInventoryItemSelected(dynamic items) {
    if (items == null) return;

    // selectedSku = items['sku_account'];
    selectedSku = '${items['inventory_name']} / ${items['sku_account']}';
    ginSkuController.text = items['sku_account'];
    ginSkuId = items['inventory_id'];
    ginSkuDesc = items['inventory_name'];
    ginUomQtyId = items['uom_qty_id'] ?? 0;
    ginUomQtyName = items['uom_qty'] ?? '';
    ginUomWeightId = items['uom_weight_id'] ?? 0;
    ginUomWeightName = items['uom_weight'] ?? '';
    ginQtyControl = items['quantity_control'] ?? 0;
    ginWeightControl = items['weight_control'] ?? 0;
    ginBrandId = items['brand_id'] ?? 0;
    ginBrandName = items['brand_name'] ?? '';
    ginAvailableQty = 0;
    ginAvailableWeight = 0.0;

    getMasterDataBatchNoFromAPI(ginSkuController.text);

    setState(() {
      quantityControl = (ginQtyControl == 1);
      weightControl = (ginWeightControl == 1);

      if (!quantityControl) ginQtyController.text = '0';
      if (!weightControl) ginWeightController.text = '0';
    });
  }

  void onProdBatchItemSelected(dynamic items) {
    if (items == null) return;

    ginProdBatchController.text = items['batch_no'];
    selectedProdBatch = items['batch_no'];
    ginProdBatchId = items['id'];
    ginRackController.text = items['rack_name'] ?? '';
    selectedRack = items['rack_name'] ?? '';
    ginRackId = items['rack_id'] ?? 0;
    ginProdDateController.text = items['prod_date'].isNotEmpty
        ? DateTimeParser().parseDate(items['prod_date'])
        : '-';
    ginExpiredDateController.text = items['exp_date'].isNotEmpty
        ? DateTimeParser().parseDate(items['exp_date'])
        : '-';

    isGrouped = items['is_grouped'] == true ? 1 : 0;
    groupId = items['grouped_ids'].toString();

    setState(() {
      ginAvailableQty = int.parse(items['qty']);
      ginAvailableWeight = double.parse(items['weight']);
    });
  }

  void onTrolleySelected(dynamic selectedItem) {
    ginTrolley = trolleyList.indexOf(selectedItem);

    ginTrolleyController.text = selectedItem['weight'].toString();

    calculateNettWeight();
  }

  void calculateNettWeight() {
    try {
      // double trayWeight =ginTrayWeight ;
      int noOfTray = int.tryParse(ginNoTrayController.text) ?? 0;
      double trolleyWeight = double.tryParse(ginTrolleyController.text) ?? 0.0;

      // Check if the weight input is actually filled
      String weightText = ginWeightController.text;

      double totalDeductions = trolleyWeight + (ginTrayWeight * noOfTray);

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
    if (plDetailId != 0) return const SizedBox();

    return buildDropDown(
      labelText: 'category'.tr(),
      hintText: ginCategoryController.text,
      allItems: categoryList,
      initialSelection: selectedCategory,
      isRequired: true,
      isLoading: isLoadingCategory,
      isMultipleText: false,
      disableSort: true,
      onItemSelected: (item) {
        ginCategoryController.text = item['name'];
        selectedCategory = item['name'];
        ginCategoryId = item['id'];
        // skuNameList.clear();
        selectedSku = '';
        ginSkuId = 0;
        ginSkuDesc = '';
        ginSkuController.clear();
        prodBatchNoList = [];
        ginProdBatchController.clear();
        selectedProdBatch = '';

        getInventoryList(ginCategoryId);
      },
      codeKey: 'name',
    );
  }

  Widget buildQtyFieldSection(device) {
    if (!quantityControl) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldInput(
          controller: ginQtyController,
          labelText: '${'quantity'.tr()} ',
          obscureToggleEnabled: false,
          keyboardType: TextInputType.number,
          isRequired: quantityControl,
          suffixIcon: Text(ginUomQtyName),
        ),
        SizedBox(
            height: device.height() * 0.04,
            child: availableDetails(
                ginAvailableQty.toString(), pickingListQty.toString()))
      ],
    );
  }

  Widget buildClientVendorSection(device) {
    if (transactionType == 'Production' ||
        transactionType == 'Stock Transfer') {
      return const SizedBox();
    }

    return Column(
      children: [
        transactionType == 'Logistic'
            ? buildDropDown(
                labelText: 'client'.tr(),
                hintText: ginClientController.text,
                allItems: clientList,
                initialSelection: selectedClient,
                isRequired: widget.pickingListID == 0 && plDetailId == 0
                    ? true
                    : false, // plDetailId == 0 ? true : false,
                isLoading: isLoadingClient,
                isMultipleText: false,
                onItemSelected: (item) {
                  ginClientId = item['id'];
                  selectedClient = item['name'];
                  ginClientController.text = item['name'];
                },
                codeKey: 'name',
              )
            : buildDropDown(
                labelText: 'vendor'.tr(),
                hintText: ginVendorController.text,
                allItems: vendorList,
                initialSelection: selectedVendor,
                isRequired:
                    widget.pickingListID == 0 && plDetailId == 0 ? true : false,
                isLoading: isLoadingVendor,
                isMultipleText: false,
                onItemSelected: (item) {
                  ginVendorId = item['id'];
                  ginVendorController.text = item['name'];
                  selectedVendor = item['name'];
                },
                codeKey: 'name',
              ),
        SizedBox(
          height: device.height() * 0.04,
        )
      ],
    );

    // if (transactionType == 'Logistic') {
    //   return buildDropDown(
    //     labelText: 'client'.tr(),
    //     hintText: ginClientController.text,
    //     allItems: clientList,
    //     initialSelection: selectedClient,
    //     isRequired: widget.pickingListID == 0 && plDetailId == 0
    //         ? true
    //         : false, // plDetailId == 0 ? true : false,
    //     isLoading: isLoadingClient,
    //     isMultipleText: false,
    //     onItemSelected: (item) {
    //       ginClientId = item['id'];
    //       selectedClient = item['name'];
    //       ginClientController.text = item['name'];
    //     },
    //     codeKey: 'name',
    //   );
    // } else {
    //   return buildDropDown(
    //     labelText: 'vendor'.tr(),
    //     hintText: ginVendorController.text,
    //     allItems: vendorList,
    //     initialSelection: selectedVendor,
    //     isRequired: widget.pickingListID == 0 && plDetailId == 0 ? true : false,
    //     isLoading: isLoadingVendor,
    //     isMultipleText: false,
    //     onItemSelected: (item) {
    //       ginVendorId = item['id'];
    //       ginVendorController.text = item['name'];
    //       selectedVendor = item['name'];
    //     },
    //     codeKey: 'name',
    //   );
    // }
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
            backgroundColor:
                isSaving ? AppColors.greyShade400 : AppColors.addBtn,
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

  cancelAction() {
    Navigator.pushAndRemoveUntil(
      context,
      NoAnimationPageRoute(builder: (context) => const GINListView()),
      (route) => false,
    );
  }

  bool validateInputs() {
    if (plDetailId == 0 && selectedCategory.isEmpty) {
      showErrorToast('missingCategory'.tr());
      return false;
    }
    if (ginSkuController.text.isEmpty) {
      showErrorToast('missingSku'.tr());
      return false;
    }
    if (plDetailId == 0 && ginProdBatchId == 0) {
      showErrorToast('missingBatchNo'.tr());
      return false;
    }
    if (quantityControl && ginQtyController.text.isEmpty) {
      showErrorToast('missingQuantity'.tr());
      return false;
    }
    if (weightControl && ginWeightController.text.isEmpty) {
      showErrorToast('missingWeight'.tr());
      return false;
    }
    if (quantityControl &&
        (int.parse(ginQtyController.text) > pickingListQty) &&
        (int.parse(ginQtyController.text) > ginAvailableQty)) {
      if (ginAvailableQty == 0 && pickingListQty != 0) {
        showErrorToast('${'overQuantity'.tr()} Only $pickingListQty available');
      } else {
        showErrorToast(
            '${'overQuantity'.tr()} Only $ginAvailableQty available');
      }
      return false;
    }
    if (weightControl &&
        (double.parse(ginWeightNetController.text) > pickingListWeight) &&
        (double.parse(ginWeightNetController.text) > ginAvailableWeight)) {
      if (ginAvailableWeight == 0.0 && pickingListWeight != 0.0) {
        showErrorToast(
            '${'overWeight'.tr()} Only $pickingListWeight available');
      } else {
        showErrorToast(
            '${'overWeight'.tr()} Only $ginAvailableWeight available');
      }
      return false;
    }
    if (weightControl && (double.parse(ginWeightNetController.text) < 0)) {
      showErrorToast('invalidNetWeight'.tr());
      return false;
    }
    if (widget.pickingListID == 0 &&
        plDetailId == 0 &&
        transactionType == 'Logistic' &&
        selectedClient.isEmpty) {
      showErrorToast('missingClient'.tr());
      return false;
    }
    if (widget.pickingListID == 0 &&
        plDetailId == 0 &&
        transactionType == 'Return to Supplier' &&
        selectedVendor.isEmpty) {
      showErrorToast('missingVendor'.tr());
      return false;
    }
    if (widget.pickingListID == 0 &&
        (ginNoTrayController.text.isEmpty || ginNoTrayController.text == '0')) {
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

  insertUpdateGoodsDb(BuildContext context) async {
    try {
      bool isNewRecord = Storage().goodsIssues == 0;

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
        goodsType: 'ISSUES',
        goodsCategoryId: ginCategoryId,
        goodsCategoryName: ginCategoryController.text,
        plDetailID: plDetailId,
        goodsSKUID: ginSkuId,
        goodsSKUName: ginSkuController.text,
        skuDisplayName: ginSkuDesc,
        totalQuantity: int.parse(ginQtyController.text),
        totalQuantityMax: ginAvailableQty,
        totalQuantityNewMax: pickingListQty,
        totalWeight: double.parse(ginWeightController.text),
        totalWeightMax: ginAvailableWeight,
        totalWeightNewMax: pickingListWeight,
        totalTray: int.parse(
            ginNoTrayController.text.isEmpty ? '1' : ginNoTrayController.text),
        trayWeight: ginTrayWeight,
        selectTrolley: ginTrolley,
        trolleyWeight: double.parse(ginTrolleyController.text.isEmpty
            ? '0.0'
            : ginTrolleyController.text),
        nettWeight: double.parse(ginWeightNetController.text.isEmpty
            ? ' 0.0'
            : ginWeightNetController.text),
        uomQtyID: ginUomQtyId,
        uomQtyName: ginUomQtyName.toString(),
        uomWeightID: ginUomWeightId,
        uomWeightName: ginUomWeightName.toString(),
        qtyControl: quantityControl == true ? 1 : 0,
        weightControl: weightControl == true ? 1 : 0,
        stockBalanceID: ginProdBatchId,
        productionBatchNo: ginProdBatchController.text,
        productionDate:
            ginProdDateController.text == '-' ? '' : ginProdDateController.text,
        expirationDate: ginExpiredDateController.text == '-'
            ? ''
            : ginExpiredDateController.text,
        expireDays: 0,
        brandId: ginBrandId,
        brandName: ginBrandName.toString(),
        customerId: ginClientId,
        customerName: ginClientController.text,
        vendorId: ginVendorId,
        vendorName: ginVendorController.text,
        rackID: ginRackId,
        rackName: ginRackController.text,
        palletID: ginTrayId,
        palletName: ginTrayTypeController.text,
        isGrouped: isGrouped,
        groupId: groupId,
        status: skuStatus == 0 ? 1 : skuStatus, // 1= PENDING | 3= COMPLETE
        jobId: Storage().jobID,
        transactionID: Storage().transactionNo,
        stockId: ginStockBalanceId,
        stockQty: ginStockBalanceQty,
        stockWeight: ginStockBalanceWeight,
        createdAt: createdAt.isEmpty ? currentDatetime.toString() : createdAt,
        updatedAt: currentDatetime.toString(),
      );

      if (isNewRecord) {
        await DBGoodsData().createGoodsData(goodsModel);
      } else {
        await DBGoodsData().updateGoodsData(goodsModel, Storage().goodsIssues);
      }

      if (!mounted) return;
      setState(() {
        isSkuSaved = true;
        ginWeightController.clear();
      });
      Fluttertoast.showToast(
          msg: 'saveData'.tr(), fontSize: 16, backgroundColor: Colors.green);
    } catch (e) {
      if (mounted) showErrorToast('failToSave'.tr());
    }
  }

  completeAction() {
    Navigator.push(context,
        NoAnimationPageRoute(builder: (context) => const GINListView()));
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
            ginRackController.clear();
            selectedRack = '';
            ginRackId = 0;

            showErrorToast('noMatchRack'.tr());
          } else {
            ginRackController.text = barcodeScanRes;
            selectedRack = barcodeScanRes;
            ginRackId = getRackName['id'];
          }
        });
      }
    } on PlatformException {
      if (!mounted) return;
      // barcodeScanRes = 'noItemRack'.tr();
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
        allItems: ['${'loading'.tr()}...'],
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
      emptyText: "${'noDataFor'.tr()} '$labelText'",
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
    // double? weightNum = double.tryParse(items['weight']);

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

  RichText availableDetails(String freeStock, String pickingListStock) {
    return RichText(
      text: plDetailId == 0
          ? TextSpan(
              style: const TextStyle(
                  color: Colors.black), // Base text style inherit
              children: [
                // Title
                TextSpan(
                  text: '${'availability'.tr()}: ',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                // Bold Value
                TextSpan(
                  text: freeStock,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : TextSpan(
              style: const TextStyle(
                  color: Colors.black), // Base text style inherit
              children: [
                // Title
                TextSpan(
                  text: '${'availability'.tr()}: ',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                // Bold Value
                TextSpan(
                  text: freeStock,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Title
                TextSpan(
                  text: ' | ${'availablePLStock'.tr()}: ',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                // Bold Value
                TextSpan(
                  text: pickingListStock,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose all your controllers...
    netWeightNotifier.dispose();

    ginCategoryController.dispose();
    ginSkuController.dispose();
    ginProdDateController.dispose();
    ginExpiredDateController.dispose();
    ginQtyController.dispose();
    ginWeightController.dispose();
    ginWeightNetController.dispose();
    ginBluetoothWeightController.dispose();
    ginProdBatchController.dispose();
    ginNoTrayController.dispose();
    ginTrolleyController.dispose();
    ginClientController.dispose();
    ginVendorController.dispose();
    ginRackController.dispose();
    ginTrayTypeController.dispose();
  }
}
