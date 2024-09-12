import 'package:arbor/core/constants/arbor_colors.dart';
import 'package:arbor/core/enums/status.dart';
import 'package:arbor/core/providers/restore_wallet_provider.dart';
import 'package:arbor/views/screens/base/base_screen.dart';
import 'package:arbor/core/utils/password_mixin.dart';
import 'package:arbor/views/widgets/arbor_button.dart';
import 'package:arbor/views/widgets/layout/hide_keyboard_container.dart';
import 'package:arbor/views/widgets/text_fields/password_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InputPasswordFinalScreen extends StatelessWidget
    with PasswordValidationMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer<RestoreWalletProvider>(
      builder: (_, model, __) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          if (model.recoverWalletStatus == Status.SUCCESS) {
            model.clearErrorMessages();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => BaseScreen()),
              (route) => false,
            );
            model.clearStatus();
          }

          if (model.recoverWalletStatus == Status.SUCCESS) {
            debugPrint('An error occurred');
          }
        });
        return Scaffold(
          backgroundColor: ArborColors.green,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: ArborColors.green,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                model.resetLastButton();
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
            title: Text('Restore Wallet',style: TextStyle(
              color: ArborColors.white,
            ),),
          ),
          body: HideKeyboardContainer(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        PasswordBox(
                          index: 9,
                          onChanged: (v) => model.setNinthPassword(v),
                          errorMessage: model.errorMessage9,
                        ),
                        PasswordBox(
                          index: 10,
                          onChanged: (v) => model.setTenthPassword(v),
                          errorMessage: model.errorMessage10,
                        ),
                        PasswordBox(
                          index: 11,
                          errorMessage: model.errorMessage11,
                          onChanged: (v) => model.setEleventhPassword(v),
                        ),
                        PasswordBox(
                          index: 12,
                          errorMessage: model.errorMessage12,
                          onChanged: (v) => model.setTwelfthPassword(v),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: ArborButton(
                            backgroundColor: ArborColors.deepGreen,
                            disabled: !model.lastBatchButtonIsDisabled,
                            loading:
                                model.recoverWalletStatus == Status.LOADING,
                            title: 'Restore',
                            onPressed: () {
                              if (model.validateLastBatch() == true) {
                                model.concatenatePasswords();
                                model.recoverWallet();
                              }
                            },
                          ),
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
}
