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
import 'good_issue.dart';

class GINListView extends StatefulWidget {
  const GINListView({super.key});

  @override
  State<GINListView> createState() => _GINListViewState();
}

class _GINListViewState extends State<GINListView> {
  Map<String, dynamic> getAllSelectedJobData = {};
  String transactionType = '', transactionNo = '';
  int areaID = 0, pickingListID = 0, totalDeletedItem = 0;
  bool isPageLoading = true, gotDeletedItem = false, isCompletingTask = false;
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
      await getJobDBData();
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
  getJobDBData() async {
    // Job DB
    try {
      final value = await DBJobData().getAddJobFromType("OUT", Storage().jobID);

      if (value != null) {
        List jobData = value;

        getAllSelectedJobData = jobData
            .firstWhereOrNull((element) => element['j_id'] == Storage().jobID);

        pickingListID = getAllSelectedJobData['pl_id'] ?? 0;
        transactionType = getAllSelectedJobData['t_type'] ?? '';
        transactionNo = getAllSelectedJobData['tr_id'] ?? '';
        areaID = getAllSelectedJobData['fa_id'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error getJobData: $e');
    }
  }

  Future<void> fetchAllGoodsData() async {
    try {
      // We await the result so the data is ready before the UI builds
      final result =
          await DBGoodsData().getAllGoodsDataBasedJobID(Storage().jobID);
      var filterList = result.where((entry) => entry['status'] != 3).toList();

      setState(() {
        goodsDataList = filterList ?? [];
      });
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

    fieldMapping = {
      "sku_name": "skuNameCode".tr(),
      "pb_no": "prodBatchNo".tr(),
      "t_quantity": "quantity".tr(),
      "nt_weight": "weight".tr(),
      "remarks": "notes".tr(),
    };

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        handleBackButton(context);
      },
      child: PoultryScaffold(
          showAppbar: true,
          title: '${'view'.tr()} GIN',
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
                          jobType: 'GIN',
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
                                          '${'deletedItem'.tr()} ($totalDeletedItem)',
                                      fontSize: AppSettings.fontSizeSubtitle,
                                      backgroundColor: AppColors.deleteBtn,
                                      width: device.isTablet()
                                          ? device.width() * 0.25
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
                                // height: device.height() / 24,
                                onPressed: () {
                                  Storage().goodsIssues = 0;
                                  // Navigate
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    NoAnimationPageRoute(
                                        builder: (context) => GINAddSkuView(
                                              transactionType: transactionType,
                                              pageTitle: 'add'.tr(),
                                              areaID: areaID,
                                              pickingListID: pickingListID,
                                            )),
                                    (route) => false,
                                  );
                                },
                              ),
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
                                  itemBuilder: (context, index) {
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
                                                "value": item[entry.key]
                                                        ?.toString() ??
                                                    '-',
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
            backgroundColor:
                isCompletingTask ? AppColors.grey : AppColors.saveBtn,
            foregroundColor: AppColors.white,
            onPressed: isCompletingTask
                ? null
                : () async {
                    setState(() => isCompletingTask = true);
                    await completeTaskAction(context);
                  },
            child: isCompletingTask
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Center(
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
          )),
    );
  }

  Future<void> completeTaskAction(BuildContext context) async {
    try {
      final getGoodsData =
          await DBGoodsData().getAllGoodsDataBasedJobID(Storage().jobID);

      if (getGoodsData != null && getGoodsData.isNotEmpty) {
        // Update local database status
        await DBJobData()
            .updateJobIndividually(Storage().jobID, "j_status", 'COMPLETE');

        if (!mounted) return;
        // Navigate to the records view cleanly
        Navigator.pushAndRemoveUntil(
          context,
          NoAnimationPageRoute(builder: (context) => const GoodRecordView()),
          (route) => false,
        );
      } else {
        // Re-enable button if data is missing
        setState(() => isCompletingTask = false);
        Fluttertoast.showToast(
          msg: 'missingItem'.tr(),
          fontSize: 14,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      // Make sure to reset loading status if anything crashes
      setState(() => isCompletingTask = false);
      debugPrint("Complete Task Error: $e");
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
    Storage().goodsIssues = skuData['g_id'];

    Navigator.pushAndRemoveUntil(
      context,
      NoAnimationPageRoute(
          builder: (context) => GINAddSkuView(
                transactionType: transactionType,
                pageTitle: 'edit'.tr(),
                areaID: areaID,
                pickingListID: pickingListID,
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
      deleteTask(skuData['g_id'], skuData['pld_id']);
    }
  }

  Future<void> deleteTask(taskId, pickingListId) async {
    try {
      if (ValueParser.parseInt(pickingListId) > 0) {
        await DBGoodsData().softDeleteGoodsDataBasedID(taskId);
      } else {
        await DBGoodsData().deleteGoodsDataBasedID(taskId);
      }

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
                    'deletedItemTitle'.tr(),
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
