import 'package:flutter/material.dart';

class HelperSize {
  static const minScreenWidth = 275;
  static const minScreenHeight = 375;

  static bool hasScreenSafeArea(BuildContext context) {
    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;
    final EdgeInsets viewPadding = MediaQuery.of(context).viewPadding;

    // ? SafeArea is effective if any of these is non-zero
    return viewInsets.top > 0 ||
        viewInsets.bottom > 0 ||
        viewInsets.left > 0 ||
        viewInsets.right > 0 ||
        viewPadding.top > 0 ||
        viewPadding.bottom > 0 ||
        viewPadding.left > 0 ||
        viewPadding.right > 0;
  }

  static bool isInLandscapeMobileScreen(BuildContext context) {
    return hasScreenSafeArea(context) &&
        MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool hasLessThanMinimumScreen(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    if (isInLandscapeMobileScreen(context)) {
      return screenSize.width < minScreenHeight ||
          screenSize.height < minScreenWidth;
    }

    return screenSize.width < minScreenWidth ||
        screenSize.height < minScreenHeight;
  }

  static bool hasNearMinimumScreen(BuildContext context) {
    const nearMinWidth = minScreenWidth + 200;
    const nearMinHeight = minScreenHeight + 200;
    final Size screenSize = MediaQuery.of(context).size;

    if (isInLandscapeMobileScreen(context)) {
      return screenSize.width <= nearMinHeight ||
          screenSize.height <= nearMinWidth;
    }

    return screenSize.width <= nearMinWidth ||
        screenSize.height <= nearMinHeight;
  }
}
