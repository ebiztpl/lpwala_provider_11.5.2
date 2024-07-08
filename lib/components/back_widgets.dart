
import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/images.dart';

class BackWidgets extends StatelessWidget {
  final Function()? onPressed;
  final Color? iconColor;

  BackWidgets({this.onPressed, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ??
          () {
            finish(context);
          },
      icon: ic_arrow_left.iconImage(color: iconColor ?? Colors.white),
    );
  }
}
