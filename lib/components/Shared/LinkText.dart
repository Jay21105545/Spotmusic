import 'package:flutter/material.dart';
import 'package:spotube/components/Shared/AnchorButton.dart';
import 'package:spotube/utils/service_utils.dart';

class LinkText<T> extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final String route;
  final T? extra;
  const LinkText(
    this.text,
    this.route, {
    Key? key,
    this.textAlign,
    this.extra,
    this.overflow,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnchorButton(
      text,
      onTap: () {
        ServiceUtils.navigate(context, route, extra: extra);
      },
      key: key,
      overflow: overflow,
      style: style,
      textAlign: textAlign,
    );
  }
}
