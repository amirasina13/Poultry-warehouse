import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../config/config.dart';
import '../../config/environment.dart';
import '../../helper/helper.dart';
import '../widgets/independent/independent.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String? lang;
  String errorfield = '';
  String errorTextUsername = '', errorTextPwd = '';
  bool errorUsername = false, errorPwd = false;
  bool isProcessing = false;
  late FocusNode usernameFocus, pwFocus;

  // Initialize Text editing
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Initialize function
  @override
  void initState() {
    super.initState();

    usernameFocus = FocusNode();
    pwFocus = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();

    usernameController.dispose();
    passwordController.dispose();
  }

  void setProcessingStatus(bool processing) {
    setState(() {
      isProcessing = processing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final device = OrientationHelper(context);
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    context.locale;

    return Theme(
      data: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor:
              errorfield == '' ? AppColors.darkGrey : AppColors.deleteBtn,
          selectionHandleColor: AppColors.darkGrey,
        ),
      ),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: PoultryScaffold(
          background: AppColors.whiteBg,
          isFullFooter: true,
          body: Column(
            children: [
              // Top SVG Illustration
              Expanded(
                // flex: 3,
                child: SizedBox(
                  width: device.width(),
                  child: const Image(
                    image: AssetImage(
                      'assets/images/background.webp',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Bottom Section
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      color: AppColors.whiteBg,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(top: keyboardVisible ? 50 : 0),
                            child: Column(
                              children: [
                                showTestingTitle(keyboardVisible),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 30),
                                  child: Text(
                                    '${EnvironmentConfig.brandName} Warehouse',
                                    style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: device.height() * 0.07),
                                  child: Column(
                                    children: [
                                      SizedBox(height: device.height() * 0.05),
                                      TextFieldInput(
                                        contentVertical: 5,
                                        controller: usernameController,
                                        labelText: 'usernameTitle'.tr(),
                                        // obscureToggleEnabled: false,
                                        focusNode: usernameFocus,
                                        hasError: errorUsername,
                                        textError: errorTextUsername,
                                        onChanged: (value) {
                                          if (value != '') {
                                            setState(() {
                                              errorUsername = false;
                                              errorfield = '';
                                            });
                                          }
                                        },
                                      ),
                                      SizedBox(height: device.height() * 0.02),
                                      TextFieldInput(
                                        controller: passwordController,
                                        labelText: 'passwordTitle'.tr(),
                                        obscureToggleEnabled: true,
                                        focusNode: pwFocus,
                                        hasError: errorPwd,
                                        textError: errorTextPwd,
                                        onChanged: (value) {
                                          if (value != '') {
                                            setState(() {
                                              errorPwd = false;
                                              errorfield = '';
                                            });
                                          }
                                        },
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: device.height() * 0.03),
                                        child: ButtonUIDisplay(
                                          labelText: 'loginText'.tr(),
                                          height: device.height() / 22,
                                          width: device.width(),
                                          backgroundColor: isProcessing
                                              ? AppColors.manageBtn
                                              : AppColors.mainColor,
                                          onPressed: isProcessing
                                              ? () {}
                                              : () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  _validateAndSend();
                                                },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showTestingTitle(bool keyboardVisible) {
    const env = String.fromEnvironment('ENV');
    bool isStagingEnv = env == 'farStaging' || env == 'wsiStaging';
    bool isInternalEnv = env == 'internal' || env.isEmpty;
    bool isfarUatEnv = env == 'farUat' || env.isEmpty;
    bool isProductionEnv = env == 'farProd' || env == 'wsiProd';

    debugPrint('ENV: $env');

    return Padding(
        padding: EdgeInsets.only(
          top: keyboardVisible ? 30 : 0,
        ),
        child: Center(
          child: Text(
            isStagingEnv
                ? 'STAGING'
                : isInternalEnv
                    ? 'INTERNAL'
                    : isfarUatEnv
                        ? 'INTERNAL UAT'
                        : isProductionEnv
                            ? 'LIVE'
                            : '',
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.red),
          ),
        ));
  }

  void _validateAndSend() {
    if (isProcessing) return;
    setProcessingStatus(true);

    if (usernameController.text.isEmpty && passwordController.text.isEmpty) {
      setState(() {
        errorUsername = true;
        errorPwd = true;
        errorTextUsername = 'usernameRequired'.tr();
        errorTextPwd = 'passwordRequired'.tr();
      });
      errorfield = 'username';
      usernameFocus.requestFocus();
      pwFocus.requestFocus();
      setProcessingStatus(false);
    } else if (usernameController.text.isEmpty) {
      setState(() {
        errorUsername = true;
        errorTextUsername = 'usernameRequired'.tr();
      });
      errorfield = 'username';
      usernameFocus.requestFocus();

      setProcessingStatus(false);
    } else if (passwordController.text.isEmpty) {
      setState(() {
        errorPwd = true;
        errorTextPwd = 'passwordRequired'.tr();
      });
      errorfield = 'password';
      pwFocus.requestFocus();

      setProcessingStatus(false);
    } else {
      // usernameFocus.dispose;
      // pwFocus.dispose;
      loginCredential();
    }
  }

  Future<void> loginCredential() async {
    try {
      await ApiLoginHelper()
          .loginAcc(usernameController.text, passwordController.text, context);
    } finally {
      // The 'finally' block ensures this runs even if there's an error,
      // but the 'mounted' check prevents the crash.
      if (mounted) {
        setProcessingStatus(false);
      }
    }
  }
}
