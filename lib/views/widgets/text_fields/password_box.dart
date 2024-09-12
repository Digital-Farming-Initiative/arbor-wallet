import 'package:arbor/core/constants/arbor_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordBox extends StatelessWidget {
  final int? index;
  final ValueChanged<String>? onChanged;
  final String errorMessage;
  PasswordBox({this.index, this.onChanged, this.errorMessage = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              color: ArborColors.logoGreen,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                ),
                Text(
                  '$index.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: ArborColors.white,
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    maxLines: 1,
                    scrollPadding: EdgeInsets.zero,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(' '),
                    ],
                    showCursor: true,
                    cursorColor: ArborColors.white,
                    onChanged: onChanged,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 16, color: ArborColors.white),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      contentPadding: EdgeInsets.all(16),
                      hintText: '...',
                      hintStyle: TextStyle(color: ArborColors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Visibility(
              visible: errorMessage != '',
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '$errorMessage',
                  style: TextStyle(
                    fontSize: 12,
                    color: ArborColors.errorRed,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

/*class NewPasswordBox extends StatelessWidget {
  final int? index;
  final ValueChanged<String?>? onChanged;
  final String errorMessage;
  NewPasswordBox({this.index, this.onChanged, this.errorMessage = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              color: ArborColors.logoGreen,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                ),
                Text(
                  '$index.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: ArborColors.white,
                  ),
                ),
                Expanded(
                  child: SimpleAutocompleteFormField<String>(
                    maxLines: 1,
                    scrollPadding: EdgeInsets.zero,
                    itemBuilder: (context, word) => Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '$word',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    onSearch: (keyword) async => ['hello', 'come', 'go']
                        .where((element) => element.contains(keyword))
                        .toList(),
                    //showCursor: true,
                    //cursorColor: ArborColors.white,
                    onChanged: onChanged,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 16, color: ArborColors.white),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      contentPadding: EdgeInsets.all(16),
                      hintText: '...',
                      hintStyle: TextStyle(color: ArborColors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Visibility(
              visible: errorMessage != '',
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '$errorMessage',
                  style: TextStyle(
                    fontSize: 12,
                    color: ArborColors.errorRed,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}*/
