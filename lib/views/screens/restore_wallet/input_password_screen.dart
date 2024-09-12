import 'package:arbor/core/enums/status.dart';
import 'package:arbor/core/providers/restore_wallet_provider.dart';
import 'package:arbor/views/screens/restore_wallet/input_password_final_screen.dart';
import 'package:arbor/views/widgets/layout/hide_keyboard_container.dart';
import 'package:arbor/views/widgets/text_fields/password_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '/views/widgets/arbor_button.dart';

import '../../../core/constants/arbor_colors.dart';
import 'package:flutter/material.dart';

class InputPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RestoreWalletProvider>(
      builder: (_, model, __) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          if (model.recoverWalletStatus == Status.SUCCESS) {
            model.setBip39Words();
          }
        });
        return Scaffold(
          backgroundColor: ArborColors.green,
          appBar: AppBar(
            backgroundColor: ArborColors.green,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                if (model.currentState == CrossFadeState.showFirst) {
                  model.clearErrorMessages();
                  Navigator.pop(context);
                } else {
                  model.back();
                }
              },
              icon: Icon(Icons.arrow_back),
            ),
            title: Text('Restore Wallet',style: TextStyle(
              color: ArborColors.white,
            ),),
          ),
          body: HideKeyboardContainer(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    child: Text(
                      'Type your 12-word password to restore your existing wallet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: ArborColors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      children: [
                        AnimatedCrossFade(
                          firstChild: firstChild(context, model),
                          secondChild: secondChild(context, model),
                          crossFadeState: model.currentState,
                          duration: const Duration(milliseconds: 300),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget firstChild(BuildContext context, RestoreWalletProvider model) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
          ),
          PasswordBox(
            index: 1,
            errorMessage: model.errorMessage1,
            onChanged: (v){
              model.setFirstPassword(v.trim());
            },
          ),
          PasswordBox(
            index: 2,
            errorMessage: model.errorMessage2,
            onChanged: (v) => model.setSecondPassword(v),
          ),
          PasswordBox(
            index: 3,
            errorMessage: model.errorMessage3,
            onChanged: (v) => model.setThirdPassword(v),
          ),
          PasswordBox(
            index: 4,
            errorMessage: model.errorMessage4,
            onChanged: (v) => model.setFourthPassword(v),
          ),
          SizedBox(
            height: 40,
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                child: ArborButton(
                  backgroundColor: ArborColors.deepGreen,
                  disabled: !model.firstBatchButtonIsDisabled,
                  title: 'Next',
                  onPressed: () {
                    if (model.validateFirstBatch() == true) {
                      model.nextScreen();
                    }
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget secondChild(BuildContext context, RestoreWalletProvider model) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
          ),
          PasswordBox(
            index: 5,
            errorMessage: model.errorMessage5,
            onChanged: (v) => model.setFifthPassword(v),
          ),
          PasswordBox(
            index: 6,
            errorMessage: model.errorMessage6,
            onChanged: (v) => model.setSixthPassword(v),
          ),
          PasswordBox(
            index: 7,
            errorMessage: model.errorMessage7,
            onChanged: (v) => model.setSeventhPassword(v),
          ),
          PasswordBox(
            index: 8,
            errorMessage: model.errorMessage8,
            onChanged: (v) => model.setEighthPassword(v),
          ),
          SizedBox(
            height: 40,
          ),
          Row(
            children: [
              Expanded(
                child: ArborButton(
                  backgroundColor: ArborColors.deepGreen,
                  title: 'Previous',
                  onPressed: () {
                    model.back();
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                child: ArborButton(
                  backgroundColor: ArborColors.deepGreen,
                  disabled: !model.secondBatchButtonIsDisabled,
                  title: 'Next',
                  onPressed: () {
                    if (model.validateSecondBatch() == true) {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => InputPasswordFinalScreen(),
                        ),
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
