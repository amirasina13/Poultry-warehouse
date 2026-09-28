import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/config.dart';
import 'independent.dart';

/* Widget class for custom scaffold. */
class PoultryScaffold extends StatelessWidget {
  final Color? background;
  final Widget? leading;
  final String title;
  final String subtitle;
  final double? elevation;
  final Widget body;
  final FloatingActionButton? floatingActionButton;
  final bool extendBodyBehindAppBar;
  final bool isShowLeading;
  final List<Widget>? appbarAction;
  final bool? showAppbar;
  final bool canClick;
  final bool isCenterTitle;
  final bool? showBottomNavigator;
  final Widget? startDrawer;
  final Widget? endDrawer;
  final bool endDrawerEnableOpenDragGesture;
  final Key? scaffoldKey;
  final SystemUiOverlayStyle? systemUiOverlayStyle;
  final VoidCallback? onBackPressed;
  final bool isFullFooter;
  final bool showLogout;
  final Widget? bottomBar;

  const PoultryScaffold({
    super.key,
    this.background,
    this.leading,
    this.title = '',
    this.subtitle = '',
    this.elevation = 0.0,
    required this.body,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
    this.isShowLeading = false,
    this.appbarAction,
    this.showAppbar = false,
    this.canClick = true,
    this.isCenterTitle = true,
    this.showBottomNavigator = true,
    this.startDrawer,
    this.endDrawer,
    this.endDrawerEnableOpenDragGesture = false,
    this.scaffoldKey,
    this.systemUiOverlayStyle,
    this.onBackPressed,
    this.isFullFooter = false,
    this.showLogout = false,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    // context.watch<LanguageController>();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: background ?? AppColors.whiteBg,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
        appBar: showAppbar == true
            ? CustomAppBar(
                title: title,
                subtitle: subtitle,
                onBackPressed: onBackPressed,
                showLogout: showLogout,
              )
            : null,
        body: body,
        resizeToAvoidBottomInset: true,
        floatingActionButton: floatingActionButton,
        // drawerEnableOpenDragGesture: false,
        drawer: const DrawerMain(),
        endDrawer: endDrawer,
        bottomNavigationBar: isFullFooter
            ? Footerbar(
                isFullFooter: isFullFooter,
              )
            : bottomBar,
      ),
    );
  }
}
