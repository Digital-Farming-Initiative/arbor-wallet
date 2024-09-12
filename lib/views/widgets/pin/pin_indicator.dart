import 'package:arbor/core/constants/arbor_colors.dart';
import 'package:flutter/material.dart';

class PinIndicator extends StatelessWidget {
  final int? currentPinLength;
  final int? totalPinLength;

  PinIndicator({this.currentPinLength, this.totalPinLength});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _generateIndicators(context),
        ),
      ),
    );
  }

  List<Widget> _generateIndicators(BuildContext context) {
    final List<Widget> indicators = [];
    for (var i = 0; i < totalPinLength!; i++) {
      indicators.add(_indicatorCircle(currentPinLength! >= i + 1, context));
    }
    return indicators;
  }

  Widget _indicatorCircle(
      bool active,
      BuildContext context,
      ) {
    final color = active
        ? ArborColors.deepGreen
        : ArborColors.white;
    return AnimatedContainer(
      margin: EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(
          Radius.circular(18),
        ),
      ),
      height: 18,
      width: 18,
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 100),
    );
  }
}