import 'package:arbor/core/constants/arbor_colors.dart';
import 'package:flutter/material.dart';

class ArborSwitch extends StatelessWidget {

  final bool state;
  final ValueChanged<bool>? onChanged;
  const ArborSwitch({Key? key,this.state=false,this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      child: Switch(
        onChanged: onChanged,
        value: state,
        activeColor: ArborColors.deepGreen,
        activeTrackColor: ArborColors.white,
        inactiveThumbColor: ArborColors.white,
        inactiveTrackColor: ArborColors.white70,
      ),
    );
  }
}