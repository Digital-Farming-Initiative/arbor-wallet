import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:arbor/core/constants/arbor_colors.dart';
import 'package:arbor/core/enums/status.dart';
import 'package:arbor/core/providers/auth_provider.dart';
import 'package:arbor/views/widgets/keypad/arbor_keypad.dart';
import 'package:arbor/views/widgets/pin/pin_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SetPinScreen extends StatelessWidget {
  const SetPinScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (_,model,__){
      WidgetsBinding.instance!.addPostFrameCallback((_) {

        if(model.setPinStatus==Status.SUCCESS){
          Navigator.pop(context,true);
          model.clearStatus();
        }

      });
      return Container(
        color: ArborColors.green,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: ArborColors.green,
            appBar: AppBar(
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  if(model.currentStep==1){
                    Navigator.pop(context,false);
                  }else{
                    model.goBack();
                  }

                },
                icon: Icon(
                  Icons.arrow_back,
                  color: ArborColors.white,
                ),
              ),
              title: Text(
                'Set Pin',
                style: TextStyle(
                  color: ArborColors.white,
                ),
              ),
              backgroundColor: ArborColors.green,
            ),
            body: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedCrossFade(
                          duration: Duration(milliseconds: 200),
                          firstChild: buildFirstView(context, model),
                          secondChild: buildSecondView(context, model),
                          crossFadeState: model.currentStep == 1
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                        ),
                        SizedBox(height:20.h),
                        ShakeAnimatedWidget(
                          child: PinIndicator(
                            currentPinLength: model.currentPin.length,
                            totalPinLength: model.pinLength,
                          ),
                          enabled: model.invalidPin,
                          duration: Duration(milliseconds: 200),
                          shakeAngle: Rotation.deg(z: 10.0),
                          curve: Curves.linear,
                        )
                      ],
                    ),
                  ),

                  ArborKeyPad(
                    size: ArborKeyPadSize.compact,
                    onKeyPressed: (key) => model.handleKeyPressed(key),
                    clearIcon: Icon(
                      Icons.arrow_back,
                      color: ArborColors.white,
                      size: 14.0,
                    ),
                    onBackKeyPressed: () => model.clear(),
                  ),

                  SizedBox(height: 20.h,),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Row buildFirstView(BuildContext context, AuthProvider model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Create your ${model.pinLength} digit PIN",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16.0,
              color: ArborColors.white,
              fontWeight: FontWeight.bold
          ),
        ),

      ],
    );
  }

  Column buildSecondView(BuildContext context, AuthProvider model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            "Confirm your ${model.pinLength} digit PIN",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16.0,
                color: ArborColors.white,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    );
  }

}