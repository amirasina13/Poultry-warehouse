import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../config/config.dart';
import '../../../custom_page_route.dart';
import '../../../data/local/local.dart';
import '../../../helper/helper.dart';
import '../../widgets/extensions/extensions.dart';
import '../../widgets/independent/independent.dart';
import '../good_record/good_record.dart';
import '../home_view.dart';
import 'grn_add_view.dart';

class GRNListView extends StatefulWidget {
  const GRNListView({super.key});

  @override
  State<GRNListView> createState() => _GRNListViewState();
}

class _GRNListViewState extends State<GRNListView> {
  Map<String, dynamic> getAllSelectedJobData = {};
  String documentListID = '', transactionType = '', transactionNo = '';
  int areaID = 0, docId = 0, totalDeletedItem = 0;
  bool isPageLoading = true, gotDeletedItem = false;
  Map<String, String> fieldMapping = {};
  List<dynamic> goodsDataList = [];
  List<dynamic> goodsDeletedList = [];

  @override
  void initState() {
    super.initState();

    initData();
  }

  Future<void> initData() async {
    isPageLoading = true;

    try {
      await getGoodsDBData();
      await fetchAllGoodsData();
      await fetchDeletedGoodsData();
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

  // Call Goods DB
  getGoodsDBData() async {
    // Job DB
    try {
      final value = await DBJobData().getAddJobFromType("IN", Storage().jobID);

      if (value != null) {
        List jobData = value;
        getAllSelectedJobData = jobData
            .firstWhereOrNull((element) => element['j_id'] == Storage().jobID);

        documentListID = getAllSelectedJobData['s_document'] ?? '';
        transactionType = getAllSelectedJobData['t_type'] ?? '';
        transactionNo = getAllSelectedJobData['tr_id'] ?? '';
        areaID = getAllSelectedJobData['ta_id'] ?? 0;
        docId = getAllSelectedJobData['sd_id'] ?? 0;
      }
    } finally {}
  }

  Future<void> fetchAllGoodsData() async {
    try {
      // We await the result so the data is ready before the UI builds
      final result =
          await DBGoodsData().getAllGoodsDataBasedJobID(Storage().jobID);
      goodsDataList = result ?? [];
    } catch (e) {
      debugPrint("Error fetching goods: $e");
      goodsDataList = [];
    }
  }

  Future<void> fetchDeletedGoodsData() async {
    try {
      // We await the result so the data is ready before the UI builds
      final result =
          await DBGoodsData().getAllDeleteGoodsDataBasedJobID(Storage().jobID);

      goodsDeletedList = result ?? [];

      if (goodsDeletedList.isNotEmpty) {
        setState(() {
          gotDeletedItem = true;
          totalDeletedItem = goodsDeletedList.length;
        });
      } else {
        setState(() => gotDeletedItem = false);
      }
    } catch (e) {
      debugPrint("Error fetching goods: $e");
      goodsDeletedList = [];
    }
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

    if (transactionType == 'Stock Transfer') {
      fieldMapping = {
        "sku_name": "skuNameCode".tr(),
        "pb_no": "prodBatchNo".tr(),
        "t_quantity": "quantity".tr(),
        "nt_weight": "weight".tr(),
        "remarks": "notes".tr(),
      };
    } else {
      fieldMapping = {
        "sku_name": "skuNameCode".tr(),
        "t_quantity": "quantity".tr(),
        "nt_weight": "weight".tr(),
        "remarks": "notes".tr(),
      };
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        handleBackButton(context);
      },
      child: PoultryScaffold(
          showAppbar: true,
          title: '${'view'.tr()} GRN',
          subtitle: transactionNo,
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
                    padding: EdgeInsets.only(bottom: device.height() * 0.05),
                    color: AppColors.whiteBg,
                    // margin: EdgeInsets.only(top: device.height() * 0.008),
                    child: Column(
                      children: [
                        // Header Section --> Job Info
                        ExpandableBox(
                          data: getAllSelectedJobData,
                          jobType: 'GRN',
                        ),
                        // secondary bar --> total task
                        SecondaryBar(
                          isShowDivider: false,
                          colorBox: AppColors.white,
                          leading: SizedBox(
                            width: device.width() * 0.3,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: TextUIDisplay(
                                labelText: '${'item'.tr()} ',
                                fontSize: AppSettings.fontSizeMain,
                              ),
                              subtitle: TextUIDisplay(
                                labelText: '(${goodsDataList.length})',
                                fontSize: AppSettings.fontSizeSubtitle,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          end: Row(
                            children: [
                              gotDeletedItem
                                  ? ButtonUIDisplay(
                                      labelText:
                                          '${'deletedDocItem'.tr()} ($totalDeletedItem)',
                                      fontSize: AppSettings.fontSizeSubtitle,
                                      backgroundColor: AppColors.deleteBtn,
                                      // icon: Icon(
                                      //   Icons.delete,
                                      //   color: AppColors.white,
                                      //   size: 20,
                                      // ),
                                      width: device.isTablet()
                                          ? device.width() * 0.2
                                          : device.width() * 0.29,
                                      // height: device.height() / 24,
                                      onPressed: () async {
                                        await fetchDeletedGoodsData();
                                        viewDeletedItem();
                                      },
                                    )
                                  : const SizedBox.shrink(),
                              SizedBox(width: device.width() * 0.02),
                              ButtonUIDisplay(
                                  labelText: 'addItem'.tr(),
                                  fontSize: AppSettings.fontSizeMain,
                                  backgroundColor: AppColors.addBtn,
                                  icon: Icon(
                                    Icons.add,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                  width: device.isTablet()
                                      ? device.width() * 0.2
                                      : device.width() * 0.29,
                                  onPressed: () {
                                    Storage().goodsReceive = 0;
                                    // Navigate
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      NoAnimationPageRoute(
                                          builder: (context) => GRNAddSkuView(
                                                transactionType:
                                                    transactionType,
                                                pageTitle: 'add'.tr(),
                                                areaID: areaID,
                                                docId: docId,
                                              )),
                                      (route) => false,
                                    );
                                  }),
                            ],
                          ),
                        ),

                        // List Section --> List of sku
                        Expanded(
                          child: goodsDataList.isEmpty
                              ? Center(child: Text('noItem'.tr()))
                              : ListView.builder(
                                  itemCount: goodsDataList.length,
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 0, 15, 20),
                                  itemBuilder: (itemContext, index) {
                                    final item = goodsDataList[index];

                                    // Map fields dynamically from Notifier
                                    final List<Map<String, dynamic>> fields =
                                        fieldMapping.entries
                                            .map((entry) {
                                              if (entry.key == 't_quantity') {
                                                return {
                                                  "label": entry.value,
                                                  "value":
                                                      '${item[entry.key]} ${item['uq_name']}',
                                                };
                                              } else if (entry.key ==
                                                  'nt_weight') {
                                                return {
                                                  "label": entry.value,
                                                  "value":
                                                      '${item[entry.key]} ${item['uw_name']}',
                                                };
                                              } else if (entry.key ==
                                                  'sku_name') {
                                                return {
                                                  "label": entry.value,
                                                  "value":
                                                      '${item[entry.key]}/ ${item['gs_name']}'
                                                };
                                              }

                                              return {
                                                "label": entry.value,
                                                "value":
                                                    (item[entry.key] != null &&
                                                            item[entry.key]
                                                                .toString()
                                                                .isNotEmpty)
                                                        ? item[entry.key]
                                                        : '-',
                                              };
                                            })
                                            .toList()
                                            .cast<Map<String, dynamic>>();

                                    return CardListview(
                                      cardItemList: [item],
                                      itemMappingList: fields,
                                      widerColumnIndex: 0,
                                      rowPattern: const [1, 3, 3],
                                      cardIndex: item['list_index'],
                                      onTap: () {
                                        handleTask(context, item);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
          floatingActionButton: FloatingActionButton.large(
            shape: const CircleBorder(),
            backgroundColor: AppColors.saveBtn,
            foregroundColor: AppColors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task,
                    size: device.height() * 0.027,
                  ),
                  Text(
                    'completeTask'.tr(),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            onPressed: () {
              completeTaskAction(context);
            },
          )),
    );
  }

  completeTaskAction(BuildContext context) async {
    // final pickingList =
    //     await ApiDocumentHelper().getPickingList(pickingListID: pickingListID);

    // String dBData = '';
    // String apiData = pickingList?.length.toString() ?? '0';

    final getGoodsData =
        await DBGoodsData().getAllGoodsDataBasedJobID(Storage().jobID);

    if (getGoodsData != null && getGoodsData.isNotEmpty) {
      // dBData = getGoodsData.length.toString();
      try {
        await DBJobData()
            .updateJobIndividually(Storage().jobID, "j_status", 'COMPLETE');
      } catch (e) {
        return;
      }

      // if (dBData != apiData || apiData == '0') {
      //   Storage().plStatusState = '1';
      // } else {
      //   Storage().plStatusState = '2';
      // }

      // Check if the widget is still present
      if (!mounted) return;

      // Navigate
      Navigator.pushAndRemoveUntil(
        context,
        NoAnimationPageRoute(builder: (context) => const GoodRecordView()),
        (route) => false,
      );
    } else {
      Fluttertoast.showToast(
          msg: 'missingItem'.tr(), fontSize: 14, backgroundColor: Colors.red);
    }
  }

  void handleTask(BuildContext context, dynamic skuData) {
    JobBottomSheet.show(
      context,
      onEdit: () => handleEditSku(context, skuData),
      onDelete: () => handleDeleteSku(context, skuData),
    );
    // TaskDialog.show(
    //   context,
    //   onEdit: () => handleEditSku(context, skuData),
    //   onDelete: () => handleDeleteSku(context, skuData),
    // );
  }

  handleEditSku(BuildContext context, dynamic skuData) async {
    Storage().goodsReceive = skuData['g_id'];

    Navigator.pushAndRemoveUntil(
      context,
      NoAnimationPageRoute(
          builder: (context) => GRNAddSkuView(
                transactionType: transactionType,
                pageTitle: 'edit'.tr(),
                areaID: areaID,
                docId: docId,
              )),
      (route) => false,
    );
  }

  Future<void> handleDeleteSku(BuildContext context, dynamic skuData) async {
    Navigator.pop(context);

    final resultvalue = await OptionDialog.show(
      context,
      title: "deleteItem".tr(),
      message: Text(
        "deleteItemMsg".tr(),
        style: TextStyle(
          fontSize: AppSettings.fontSizeMain,
          fontWeight: FontWeight.w500,
          color: AppColors.darkGrey,
        ),
      ),
      typeDialog: 'delete',
    );

    if (resultvalue == true) {
      deleteTask(skuData['g_id'], skuData['pb_no']);
    }
  }

  Future<void> deleteTask(taskId, String prodBatchNo) async {
    try {
      if (prodBatchNo.isNotEmpty) {
        await DBGoodsData().softDeleteGoodsDataBasedID(taskId);
      } else {
        await DBGoodsData().deleteGoodsDataBasedID(taskId);
      }
      // await DBGoodsData().deleteGoodsDataBasedID(taskId);

      await fetchAllGoodsData();
      await fetchDeletedGoodsData();
      setState(() {});
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  Future<void> restoreTask(taskId) async {
    try {
      // await DBGoodsData().deleteGoodsDataBasedID(taskId);
      await DBGoodsData().reactivateGoodsData(taskId);

      await fetchAllGoodsData();
      await fetchDeletedGoodsData();
      setState(() {});
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  viewDeletedItem() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              child: AlertDialog(
                  // Set product category
                  // contentPadding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  title: Text(
                    'deletedDocItemTitle'.tr(),
                    style: const TextStyle(
                        fontSize: AppSettings.fontSizeMain,
                        fontWeight: FontWeight.w700),
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return goodsDeletedList.isEmpty
                            ? Center(child: Text('noItem'.tr()))
                            : ListView.builder(
                                itemCount: goodsDeletedList.length,
                                // padding:
                                //     const EdgeInsets.fromLTRB(15, 0, 15, 20),
                                itemBuilder: (context, index) {
                                  final item = goodsDeletedList[index];

                                  // Map fields dynamically from Notifier
                                  final List<Map<String, dynamic>> fields =
                                      fieldMapping.entries
                                          .map((entry) {
                                            if (entry.key == 't_quantity') {
                                              return {
                                                "label": entry.value,
                                                "value":
                                                    '${item[entry.key]} ${item['uq_name']}',
                                              };
                                            } else if (entry.key ==
                                                'nt_weight') {
                                              return {
                                                "label": entry.value,
                                                "value":
                                                    '${item[entry.key]} ${item['uw_name']}',
                                              };
                                            } else if (entry.key ==
                                                'sku_name') {
                                              return {
                                                "label": entry.value,
                                                "value":
                                                    '${item[entry.key]}/ ${item['gs_name']}'
                                              };
                                            }
                                            return {
                                              "label": entry.value,
                                              "value":
                                                  item[entry.key]?.toString() ??
                                                      '-',
                                            };
                                          })
                                          .toList()
                                          .cast<Map<String, dynamic>>();

                                  return RestoreListview(
                                    cardItemList: [item],
                                    itemMappingList: fields,
                                    widerColumnIndex: 0,
                                    rowPattern: const [1, 3, 3],
                                    cardIndex: item['list_index'],
                                    onTap: () async {
                                      await restoreTask(item['g_id']);

                                      if (!context.mounted) return;
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              );
                      },
                    ),
                  )),
            ),
          );
        });
  }
}
