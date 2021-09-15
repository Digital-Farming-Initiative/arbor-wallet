import 'package:arbor/views/screens/restore_wallet_screen.dart';
import 'package:arbor/views/widgets/responsiveness/responsive.dart';
import 'package:flutter/material.dart';
import '../../core/constants/arbor_colors.dart';
import '../../views/widgets/arbor_button.dart';
import '../../core/constants/asset_paths.dart';

import 'on_boarding_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArborColors.green,
      body: Responsive.isDesktop(context) || Responsive.isTablet(context)
          ? Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 500, maxHeight: 500),
                padding: EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                child: _SplashScreenBodyWidget(),
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(
                horizontal: 40.w,
                vertical: 20.h,
              ),
              child: _SplashScreenBodyWidget(),
            ),
    );
  }
}

class _SplashScreenBodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        Image.asset(
          AssetPaths.logo,
          width: 0.2.sh,
        ),
        SizedBox(
          height: 20.h,
        ),
        Text(
          'Secure & Easy to Use Chia Light Wallet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacer(),
        ArborButton(
          backgroundColor: ArborColors.deepGreen,
          title: 'Get Started',
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => OnBoardingScreen()));
          },
        ),
        SizedBox(
          height: 20.h,
        ),
        ArborButton(
          backgroundColor: ArborColors.deepGreen,
          title: 'I already have a wallet',
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => RestoreWalletScreen()));
          },
        ),
      ],
    );
  }
}
