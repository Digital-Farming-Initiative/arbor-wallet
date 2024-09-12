import 'package:arbor/core/constants/arbor_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsTile extends StatelessWidget {

  final String title,assetPath;
  final Widget? trailing;
  final VoidCallback onPressed;

  const SettingsTile({Key? key,required this.title,required this.assetPath,this.trailing,required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
          padding: EdgeInsets.all(
            10,
          ),
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: ArborColors.logoGreen,
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  height: 30,
                  child: SvgPicture.asset(
                    assetPath,
                    color: ArborColors.white,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  "$title",
                  style: TextStyle(
                    color: ArborColors.white,
                    fontSize: 14.sp,
                  ),
                ),
                Spacer(),
                trailing ?? SizedBox()
              ])),
    );
  }
}