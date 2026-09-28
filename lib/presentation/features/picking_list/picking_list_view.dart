import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/config.dart';
import '../../../custom_page_route.dart';
import '../../../helper/api_helper/document_helper.dart';
import '../../../helper/orientation_helper.dart';
import '../../widgets/data_driven/data_driven.dart';
import '../../widgets/extensions/extensions.dart';
import '../../widgets/independent/independent.dart';
import '../home_view.dart';

class PickingListView extends StatefulWidget {
  const PickingListView({super.key});

  @override
  State<PickingListView> createState() => _PickingListViewState();
}

class _PickingListViewState extends State<PickingListView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // late Future<dynamic> _future;

  Map<String, String> fieldMapping = {};
  List<dynamic> selectedItem = [];
  List<dynamic> jobOrders = [];

  String selectedPickingList = '';

  bool isDetailLoading = false;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;

  int totalPickingList = 0;
  int currentPage = 1;
  int pageLimit = 10;
  int requestMore = 0;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(_onScroll);
    _loadPickingListData();
  }

  // void _loadPickingListData() {
  //   _future = ApiDocumentHelper()
  //       .getPickingList(isList: true, isPagination: true, pageCount: 1);
  // }

  Future<void> _loadPickingListData() async {
    if (isLoading) return;

    // Increment generation to invalidate any pending 'loadMore' requests
    final currentMore = ++requestMore;

    setState(() {
      isLoading = true;
      currentPage = 1;
      hasMore = true;
      jobOrders.clear();
    });

    try {
      final response = await ApiDocumentHelper().getPickingList(
          isList: true, isPagination: true, pageLimit: pageLimit, pageCount: 1);

      // Discard result if screen unmounted OR if a newer request started
      if (!mounted || currentMore != requestMore) return;

      final List<dynamic> newItems = response['data'] ?? [];

      setState(() {
        jobOrders.addAll(newItems);

        totalPickingList = response['total'];

        if (newItems.length < pageLimit) {
          hasMore = false;
        }

        isLoading = false;
      });

      // Check if large screen/tablet needs more items to become scrollable
      checkAndLoadMoreIfSpaceAvailable();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadMorePickingList() async {
    if (isLoadingMore || !hasMore) return;

    final currentMore = requestMore;

    setState(() => isLoadingMore = true);

    try {
      final nextPage = currentPage + 1;

      final response = await ApiDocumentHelper().getPickingList(
          isList: true,
          isPagination: true,
          pageLimit: pageLimit,
          pageCount: nextPage);

      // If _loadPickingListData() was called while this was loading, discard this response
      if (!mounted || currentMore != requestMore) return;

      final List<dynamic> newItems = response['data'] ?? [];

      setState(() {
        jobOrders.addAll(newItems);
        currentPage = nextPage;
        // hasMore = response['has_more'];

        // Update hasMore safely based on item count or response flag
        if (newItems.length < pageLimit || response['has_more'] == false) {
          hasMore = false;
        }

        isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  refreshPickingList() async {
    // setState(() {
    await _loadPickingListData();
    // });
  }

  void checkAndLoadMoreIfSpaceAvailable() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // If the scroll view has no scroll range (maxScrollExtent == 0)
      // and there are more items to fetch, load the next page automatically.
      if (scrollController.hasClients &&
          scrollController.position.maxScrollExtent == 0 &&
          hasMore &&
          !isLoading &&
          !isLoadingMore) {
        loadMorePickingList();
      }
    });
  }

  getPickingListDetails(String pickingListNo) async {
    setState(() => isDetailLoading = true);

    try {
      final response =
          await ApiDocumentHelper().getPickingListDetails(docNo: pickingListNo);

      if (!mounted) return;
      setState(() {
        selectedPickingList = pickingListNo;
        selectedItem = response ?? [];
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scaffoldKey.currentState?.openEndDrawer();
      });

      // Wait for the drawer slide-in animation to complete smoothly before removing loading state
      await Future.delayed(const Duration(milliseconds: 250));

      if (!mounted) return;
      setState(() => isDetailLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => isDetailLoading = false);
    }
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMorePickingList();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = OrientationHelper(context);
    context.locale;

    fieldMapping = {
      "status": 'status'.tr(),
      "transaction_no": 'pickingListNo'.tr(),
      "job_order_no": 'jobOrderNo'.tr(),
      "from_area_name": 'area'.tr(),
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors
            .white, // Set to transparent to make it part of the app's background
        statusBarIconBrightness:
            Brightness.dark, // Use dark icons for a light background
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Opacity(
              opacity: isDetailLoading
                  ? 0.6
                  : 1.0, // Subtly fade the background content
              child: AbsorbPointer(
                absorbing:
                    isDetailLoading, // Prevents clicking buttons while uploading
                child: PoultryScaffold(
                  scaffoldKey: _scaffoldKey,
                  showAppbar: true,
                  title: 'pickingList'.tr(),
                  isShowLeading: true,
                  onBackPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      NoAnimationPageRoute(
                          builder: (context) => const HomeView()),
                      (route) => false,
                    );
                  },
                  body: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: Column(
                            children: [
                              OperatorAndLocation(
                                onLocationChanged: refreshPickingList,
                              ),
                              SecondaryBar(
                                isShowDivider: false,
                                leading: SizedBox(
                                  width: device.width() * 0.3,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: TextUIDisplay(
                                      labelText: '${'pickingList'.tr()}(s)',
                                      fontSize: AppSettings.fontSizeMain,
                                    ),
                                    subtitle: TextUIDisplay(
                                      labelText: '($totalPickingList)',
                                      fontSize: AppSettings.fontSizeSubtitle,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                end: ButtonUIDisplay(
                                  labelText: 'refresh'.tr(),
                                  fontSize: AppSettings.fontSizeMain,
                                  backgroundColor: AppColors.royalBlue,
                                  icon: Icon(
                                    Icons.refresh,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                  width: device.isTablet()
                                      ? device.width() * 0.26
                                      : device.width() * 0.29,
                                  onPressed: refreshPickingList,
                                ),
                              ),
                              SizedBox(
                                height: device.height() * 0.75,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      bottom: device.height() * 0.025),
                                  child: _buildListContent(
                                    isLoading: isLoading,
                                    hasError: false,
                                    jobOrders: jobOrders,
                                    fieldMapping: fieldMapping,
                                    device: device,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  endDrawer: DrawerListview(
                    transactions: selectedItem,
                    pickingList: selectedPickingList,
                  ),
                ),
              ),
            ),
            if (isDetailLoading)
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

  // Extracted content builder to clean up nested code
  Widget _buildListContent({
    required bool isLoading,
    required bool hasError,
    required List<dynamic> jobOrders,
    required Map<String, String> fieldMapping,
    required OrientationHelper device,
  }) {
    if (isLoading && jobOrders.isEmpty) {
      return Center(child: LoadingWidget());
    }

    if (hasError) {
      return Center(
        child: Text(
          'somethingWentWrong'.tr(),
          style: const TextStyle(
            fontSize: AppSettings.fontSizeTitle,
            color: Color(0xff6C707B),
          ),
        ),
      );
    }

    if (jobOrders.isEmpty) {
      return Center(
        child: Container(
          margin: EdgeInsets.only(bottom: device.height() * 0.1),
          child: Text(
            'noItem'.tr(),
            style: const TextStyle(
              fontSize: AppSettings.fontSizeTitle,
              fontFamily: "PublicSansMedium",
              color: Color(0xff6C707B),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(8),
        // itemCount: jobOrders.length,
        itemCount: jobOrders.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading indicator at bottom
          if (index == jobOrders.length) {
            if (!isLoadingMore) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: LoadingWidget(),
              ),
            );
          }

          final item = jobOrders[index];

          final changeValue = {
            "status": (String value) {
              var statusMapping = {
                '1': 'jobStatusPending'.tr(),
                '5': 'jobStatusInProgress'.tr(),
                '3': 'jobStatusCompleted'.tr(),
              };
              return statusMapping[value] ?? value;
            },
          };

          final fields = fieldMapping.entries.map((entry) {
            var value = item[entry.key] ?? "";

            // apply transformer if exists
            if (changeValue.containsKey(entry.key)) {
              value = changeValue[entry.key]!(value.toString());
            }
            return {
              "label": entry.value,
              "value": value,
            };
          }).toList();

          return CardListview(
            cardItemList: jobOrders,
            itemMappingList: fields,
            crossAxisCount: 3,
            rowPattern: const [3],
            cardIndex: index,
            pickingListStatus: true,
            onTap: () {
              setState(() {
                // Storage().selectedPickingID = item['id'];

                getPickingListDetails(item['transaction_no']);
              });
            },
          );
        },
      ),
    );
  }
}
