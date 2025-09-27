import 'package:flutter/material.dart';

class SettingsItem extends StatefulWidget {
  final IconData titleIcon;
  final String titleText;
  final List<Widget> children;
  final bool useBottomPadding;

  const SettingsItem({
    super.key,
    required this.titleIcon,
    required this.titleText,
    required this.children,
    this.useBottomPadding = true,
  });

  @override
  State<StatefulWidget> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.titleIcon),
            SizedBox(width: 8.0),
            Text(
              widget.titleText,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
            ),
          ],
        ),
        const Divider(),
        ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: widget.children,
        ),
        if (widget.useBottomPadding) const SizedBox(height: 24),
      ],
    );
  }
}
