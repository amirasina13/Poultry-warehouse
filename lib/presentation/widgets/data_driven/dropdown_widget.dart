import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../config/config.dart';

class DropDownUI<T> extends StatefulWidget {
  final String labelText;
  final String hintText;
  final List<T> allItems;
  final bool isRequired;
  final bool isLoading;
  final String Function(T) itemToString;
  final void Function(T) onItemSelected;
  final VoidCallback? onRefresh;
  final T? initialSelection;
  // final Widget Function(BuildContext context, T? item)? labelWidget;
  final Widget Function(BuildContext, T, BoxConstraints)? labelWidget;
  final bool readOnly;
  final Color? readOnlyColor;
  final bool? hasOuterBorder;
  final String? emptyText;
  final bool isClear;
  final VoidCallback? onTapClear;
  final bool hideBorder;
  final bool Function()? onTapValidation;
  final bool disableSort;

  const DropDownUI({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.allItems,
    required this.itemToString,
    required this.onItemSelected,
    this.isRequired = false,
    this.isLoading = false,
    this.onRefresh,
    this.initialSelection,
    this.labelWidget,
    this.readOnly = false,
    this.readOnlyColor,
    this.hasOuterBorder = true,
    this.emptyText,
    this.isClear = false,
    this.onTapClear,
    this.hideBorder = false,
    this.onTapValidation,
    this.disableSort = false,
  }) : super(key: key);

  @override
  State<DropDownUI<T>> createState() => _DropDownUIState<T>();
}

class _DropDownUIState<T> extends State<DropDownUI<T>> {
  late T? _selectedItem;
  final MenuController _menuController = MenuController();
  final TextEditingController _searchController = TextEditingController();
  late List<T> _filteredItems;

  List<T> _sortItems(List<T> items) {
    if (widget.disableSort) {
      return List<T>.from(items);
    }

    final sorted = List<T>.from(items);

    sorted.sort((a, b) {
      final aText = widget.itemToString(a).trim();
      final bText = widget.itemToString(b).trim();

      final aIsNone = aText.toLowerCase().startsWith('none');
      final bIsNone = bText.toLowerCase().startsWith('none');

      // Keep "None" at the top always
      if (aIsNone && !bIsNone) return -1;
      if (!aIsNone && bIsNone) return 1;

      final aNum = num.tryParse(aText);
      final bNum = num.tryParse(bText);

      // Numeric sort
      if (aNum != null && bNum != null) {
        return aNum.compareTo(bNum);
      }

      // Text sort (Alphabetical)
      return aText.toLowerCase().compareTo(
            bText.toLowerCase(),
          );
    });

    return sorted;
  }

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialSelection;
    // _filteredItems = widget.allItems;
    _filteredItems = _sortItems(widget.allItems);
    _searchController.addListener(_filterItems);

    // print('IS CLEAR: ${widget.isClear}');
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _sortItems(
        widget.allItems
            .where(
              (item) => widget.itemToString(item).toLowerCase().contains(query),
            )
            .toList(),
      );
      // _filteredItems = widget.allItems
      //     .where(
      //         (item) => widget.itemToString(item).toLowerCase().contains(query))
      //     .toList();
    });
  }

  @override
  void didUpdateWidget(covariant DropDownUI<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the parent provides a new list of items, update the filtered list
    if (oldWidget.allItems != widget.allItems) {
      setState(() {
        // _filteredItems = widget.allItems;
        _filteredItems = _sortItems(widget.allItems);
      });
    }

    // IMPORTANT: If the selection changes from the outside, update internal state
    if (oldWidget.initialSelection != widget.initialSelection) {
      setState(() {
        _selectedItem = widget.initialSelection;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // context.watch<LanguageController>();

    return LayoutBuilder(builder: ((context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MenuAnchor(
            controller: _menuController,
            style: MenuStyle(
              padding: const MaterialStatePropertyAll(EdgeInsets.zero),
              // fixedSize: MaterialStateProperty.all(Size.fromWidth(50)),
              backgroundColor: MaterialStatePropertyAll(AppColors.white),
              surfaceTintColor: MaterialStatePropertyAll(AppColors.white),
              elevation: const MaterialStatePropertyAll(2),
            ),
            builder: (context, controller, child) {
              return GestureDetector(
                  onTap: widget.readOnly == true
                      ? () {}
                      : () {
                          if (widget.onTapValidation != null &&
                              !widget.onTapValidation!()) {
                            return; // Stop execution if validation fails
                          }

                          if (widget.isClear) {
                            widget.onTapClear?.call();
                          } else {
                            _searchController.clear();
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          }
                        },

                  //  widget.isClear
                  //     ? widget.onTapClear
                  //     : () {
                  //         _searchController.clear();
                  //         if (controller.isOpen) {
                  //           controller.close();
                  //         } else {
                  //           controller.open();
                  //         }
                  //       },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                    decoration: BoxDecoration(
                      color: widget.readOnly == true
                          ? widget.readOnlyColor == null
                              ? AppColors.greyShade200
                              : AppColors.white
                          : widget.hasOuterBorder!
                              ? AppColors.white
                              : AppColors.whiteBg,
                      border: !widget.hideBorder
                          ? Border.all(color: AppColors.greyShade300)
                          : null,
                      borderRadius: !widget.hideBorder
                          ? BorderRadius.circular(8)
                          : BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.labelText,
                              style: TextStyle(
                                fontSize: AppSettings.fontSizeMain,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkGrey,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (widget.isRequired)
                              Text(
                                "*",
                                style: TextStyle(
                                  fontSize: AppSettings.fontSizeMain,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.deleteBtn,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            const SizedBox(width: 10),
                            if (widget.onRefresh != null)
                              IconButton(
                                icon: const Icon(Icons.refresh, size: 26),
                                onPressed: widget.onRefresh,
                                tooltip: 'refresh'.tr(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                (_selectedItem != null && _selectedItem != "")
                                    ? (_selectedItem is String
                                        ? _selectedItem as String
                                        : widget
                                            .itemToString(_selectedItem as T))
                                    : (widget.hintText),
                                style: TextStyle(
                                  fontSize: AppSettings.fontSizeMain,
                                  color: (_selectedItem != null &&
                                          _selectedItem != "")
                                      ? AppColors.black
                                      : AppColors.greyShade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            widget.readOnly == true
                                ? const SizedBox()
                                : widget.isClear && _selectedItem != null
                                    ? InkWell(
                                        onTap: () {
                                          widget.onTapClear?.call();
                                        },
                                        child: Icon(
                                          Icons.clear,
                                          color: AppColors.linkColor,
                                          size: 19,
                                        ),
                                      )
                                    : Icon(
                                        Icons.arrow_drop_down,
                                        color: widget.readOnly == true
                                            ? AppColors.greyShade400
                                            : AppColors.linkColor,
                                      )
                          ],
                        ),
                      ],
                    ),
                  ));
            },
            menuChildren: [
              Material(
                color: AppColors.white,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 300,
                    maxWidth: constraints.maxWidth,
                    minWidth: constraints.maxWidth,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔍 Search box
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: '${'search'.tr()}...',
                            prefixIconConstraints:
                                const BoxConstraints(minWidth: 0, minHeight: 0),
                            isDense: true,
                            filled: true,
                            fillColor: AppColors.white,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),

                      if (_filteredItems.isEmpty) ...[
                        Expanded(
                            child: Center(
                                child:
                                    Text(widget.emptyText ?? "noData".tr()))),
                      ] else ...[
                        SizedBox(
                          // height =  220 maxHeight - ~50px for the Search TextField
                          height: 170,
                          width: constraints.maxWidth,
                          // Change from SingleChildScrollView to Listview for faster dropdown
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              if (index >= _filteredItems.length) {
                                return const SizedBox.shrink();
                              }

                              final item = _filteredItems[index];

                              if (widget.isLoading) {
                                return Center(child: Text('loading'.tr()));
                              }

                              return MenuItemButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedItem = item;
                                  });
                                  widget.onItemSelected(item);
                                  _menuController.close();
                                  _searchController.clear();
                                },
                                child: widget.labelWidget != null
                                    ? widget.labelWidget!(
                                        context, item, constraints)
                                    : SizedBox(
                                        width: constraints.maxWidth - 40,
                                        child: Text(
                                          widget.itemToString(item),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      );
    }));
  }
}
