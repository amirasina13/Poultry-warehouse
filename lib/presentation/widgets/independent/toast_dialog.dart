import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../config/config.dart';

/* Class for toast dialog.  */

FToast fToast = FToast();

void showSuccess(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: AppColors.royalBlue,
    textColor: AppColors.white,
    fontSize: 16.0,
  );
}

void cancelToast() {
  Fluttertoast.cancel();
}

void showCustomToast(String msg) {
  Widget toast = Container(
    margin: const EdgeInsets.only(bottom: 85),
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: AppColors.blueShade900,
    ),
    child: Text(
      msg,
      style: TextStyle(
        color: AppColors.white,
        fontSize: 16,
      ),
      // textScaleFactor: AppSettings.scaleFactor,
    ),
  );

  fToast.removeCustomToast();
  fToast.showToast(
    child: toast,
    toastDuration: const Duration(seconds: 2),
  );
}

void showErrorToast(String msg, BuildContext context) {
  var regExp = RegExp(r"\w+(\'\w+)?");
  int wordscount = regExp.allMatches(msg).length;
  // fToast = fToast.init(context);
  fToast.init(context);

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12.0),
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      color: AppColors.red,
    ),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
          ),
          child: Icon(
            Icons.close,
            color: AppColors.red,
            size: 20,
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            child: Text(
              msg,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
              maxLines: 4,
              // textScaleFactor: AppSettings.scaleFactor,
            ),
          ),
        ),
      ],
    ),
  );

  fToast.removeCustomToast();
  fToast.showToast(
    child: toast,
    toastDuration: Duration(
      seconds: wordscount <= 10
          ? 3
          : wordscount <= 15
              ? 4
              : wordscount <= 17
                  ? 5
                  : 6,
    ),
    // gravity: ToastGravity.TOP,
    positionedToastBuilder: (context, child) {
      return Positioned(
        top: 67.0,
        left: AppSettings.marginHorizontal,
        right: AppSettings.marginHorizontal,
        child: child,
      );
    },
  );
}

void showSuccessToast(String msg, BuildContext context) {
  fToast = fToast.init(context);

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12.0),
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      color: AppColors.successColor,
    ),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
          ),
          child: Icon(
            Icons.check,
            color: AppColors.successColor,
            size: 20,
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            child: Text(
              msg,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
              maxLines: 4,
              textScaler: TextScaler.linear(AppSettings.scaleFactor),
            ),
          ),
        ),
      ],
    ),
  );

  fToast.removeCustomToast();
  fToast.showToast(
    child: toast,
    toastDuration: const Duration(seconds: 3),
    positionedToastBuilder: (context, child) {
      return Positioned(
        top: 67.0,
        left: AppSettings.marginHorizontal,
        right: AppSettings.marginHorizontal,
        child: child,
      );
    },
  );
}

void showGeneralToast(String msg, BuildContext context) {
  fToast = fToast.init(context);

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12.0),
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      color: AppColors.editBtn,
    ),
    child: Row(
      children: [
        SizedBox(
          child: Icon(
            Icons.info,
            color: AppColors.white,
            size: 20,
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            child: Text(
              msg,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
              maxLines: 4,
              textScaler: TextScaler.linear(AppSettings.scaleFactor),
            ),
          ),
        ),
      ],
    ),
  );

  fToast.removeCustomToast();
  fToast.showToast(
    child: toast,
    toastDuration: const Duration(seconds: 3),
    positionedToastBuilder: (context, child) {
      return Positioned(
        top: 67.0,
        left: AppSettings.marginHorizontal,
        right: AppSettings.marginHorizontal,
        child: child,
      );
    },
  );
}

void showInProgressToast(String msg, BuildContext context) {
  fToast = fToast.init(context);

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12.0),
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0), color: AppColors.royalBlue),
    child: Row(
      children: [
        Icon(
          Icons.hourglass_empty_outlined,
          color: AppColors.white,
          size: 20,
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            child: Text(
              msg,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
              maxLines: 4,
              // textScaleFactor: AppSettings.scaleFactor,
            ),
          ),
        ),
      ],
    ),
  );

  fToast.removeCustomToast();
  fToast.showToast(
    child: toast,
    toastDuration: const Duration(seconds: 3),
    positionedToastBuilder: (context, child) {
      return Positioned(
        top: 67.0,
        left: AppSettings.marginHorizontal,
        right: AppSettings.marginHorizontal,
        child: child,
      );
    },
  );
}


// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '../../../config/config.dart';

// FToast fToast = FToast();

// /// 1. The Core Builder: Handles all the common logic and UI structure
// void _showBaseToast(
//   BuildContext context, {
//   required String msg,
//   required Color color,
//   required IconData icon,
//   Duration? duration,
// }) {
//   fToast.init(context);
//   fToast.removeCustomToast();

//   // Smart duration calculation
//   if (duration == null) {
//     int wordCount = RegExp(r"\w+(\'\w+)?").allMatches(msg).length;
//     duration = Duration(seconds: wordCount <= 10 ? 3 : wordCount <= 15 ? 4 : 5);
//   }

//   Widget toast = Container(
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12.0),
//     width: MediaQuery.of(context).size.width,
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(10.0),
//       color: color,
//     ),
//     child: Row(
//       children: [
//         Icon(icon, color: AppColors.white, size: 20),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             msg,
//             style: const TextStyle(color: AppColors.white, fontSize: 16),
//             maxLines: 4,
//             textScaler: TextScaler.linear(AppSettings.scaleFactor),
//           ),
//         ),
//       ],
//     ),
//   );

//   fToast.showToast(
//     child: toast,
//     toastDuration: duration,
//     positionedToastBuilder: (context, child) => Positioned(
//       top: 67.0,
//       left: AppSettings.marginHorizontal,
//       right: AppSettings.marginHorizontal,
//       child: child,
//     ),
//   );
// }

// /// 2. Clean Public Functions: Just pass the unique parts
// void showSuccessToast(String msg, BuildContext context) => _showBaseToast(
//       context,
//       msg: msg,
//       color: AppColors.successColor,
//       icon: Icons.check_circle_outline,
//     );

// void showErrorToast(String msg, BuildContext context) => _showBaseToast(
//       context,
//       msg: msg,
//       color: AppColors.red,
//       icon: Icons.error_outline,
//     );

// void showGeneralToast(String msg, BuildContext context) => _showBaseToast(
//       context,
//       msg: msg,
//       color: AppColors.editBtn,
//       icon: Icons.info_outline,
//     );

// void showInProgressToast(String msg, BuildContext context) => _showBaseToast(
//       context,
//       msg: msg,
//       color: AppColors.royalBlue,
//       icon: Icons.hourglass_empty,
//     );

// // Keep your simple native toast for non-context situations
// void showSuccess(String msg) {
//   Fluttertoast.showToast(
//     msg: msg,
//     backgroundColor: AppColors.royalBlue,
//     textColor: AppColors.white,
//   );
// }

// void cancelToast() => Fluttertoast.cancel();