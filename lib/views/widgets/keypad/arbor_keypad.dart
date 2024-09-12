import 'package:arbor/core/constants/arbor_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

enum ArborKeyPadSize { small, compact, large }
enum ArborKeyPadBottomLeftKeyType { empty, point, text }

class ArborKeyPad extends StatelessWidget {
  final ArborKeyPadSize size;
  final Function? onKeyPressed, onBackKeyPressed;
  final Function()? onBottomLeftKeyPressed;
  final Icon? clearIcon;
  final ArborKeyPadBottomLeftKeyType bottomLeftKey;
  final String bottomLeftKeyLabel;

  ArborKeyPad({
    this.size = ArborKeyPadSize.compact,
    this.onKeyPressed,
    this.onBackKeyPressed,
    this.clearIcon,
    this.bottomLeftKey = ArborKeyPadBottomLeftKeyType.empty,
    this.bottomLeftKeyLabel = "",
    this.onBottomLeftKeyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ArborKeyPadItem(
                n: "1",
                size: size,
                onKeyPressed: () => onKeyPressed!("1"),
              ),
              ArborKeyPadItem(
                n: "2",
                size: size,
                onKeyPressed: () => onKeyPressed!("2"),
              ),
              ArborKeyPadItem(
                n: "3",
                size: size,
                onKeyPressed: () => onKeyPressed!("3"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ArborKeyPadItem(
                n: "4",
                size: size,
                onKeyPressed: () => onKeyPressed!("4"),
              ),
              ArborKeyPadItem(
                n: "5",
                size: size,
                onKeyPressed: () => onKeyPressed!("5"),
              ),
              ArborKeyPadItem(
                n: "6",
                size: size,
                onKeyPressed: () => onKeyPressed!("6"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ArborKeyPadItem(
                n: "7",
                size: size,
                onKeyPressed: () => onKeyPressed!("7"),
              ),
              ArborKeyPadItem(
                n: "8",
                size: size,
                onKeyPressed: () => onKeyPressed!("8"),
              ),
              ArborKeyPadItem(
                n: "9",
                size: size,
                onKeyPressed: () => onKeyPressed!("9"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              bottomLeftKey == ArborKeyPadBottomLeftKeyType.empty
                  ? ArborKeyPadEmptyItem(size: size)
                  : bottomLeftKey == ArborKeyPadBottomLeftKeyType.point
                  ? ArborKeyPadItem(
                n: ".",
                size: size,
                onKeyPressed: () => onKeyPressed!("."),
              )
                  : ArborKeyPadTextBottomLeftItem(
                size: size,
                label: bottomLeftKeyLabel,
                onPressed: onBottomLeftKeyPressed!,
              ),
              ArborKeyPadItem(
                n: "0",
                size: size,
                onKeyPressed: () => onKeyPressed!("0"),
              ),
              onBackKeyPressed == null
                  ? ArborKeyPadEmptyItem(size: size)
                  : clearIcon == null
                  ? ArborKeyPadEmptyItem(size: size)
                  : ArborKeyPadItem(
                size: size,
                clearIcon: clearIcon!,
                onClearIconPressed: () => onBackKeyPressed!(),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ArborKeyPadItem extends HookWidget {
  final String? n;
  final ArborKeyPadSize? size;
  final Function? onKeyPressed;

  final Icon? clearIcon;
  final Function? onClearIconPressed;

  ArborKeyPadItem(
      {this.n,
        this.size,
        this.onKeyPressed,
        this.clearIcon,
        this.onClearIconPressed});

  @override
  Widget build(BuildContext context) {
    double _heightDivider = 12.0;

    var _controller =
    useAnimationController(duration: Duration(milliseconds: 100));
    var _animation = Tween(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
        ..addStatusListener(
              (status) {
            if (status == AnimationStatus.completed) {
              _controller.reverse();
            }
          },
        ),
    );

    if (size == ArborKeyPadSize.compact) {
      _heightDivider = 10.0;
    }
    if (size == ArborKeyPadSize.large) {
      _heightDivider = 8.0;
    }

    int _itemHeight = MediaQuery.of(context).size.height ~/ _heightDivider;
    int _itemWidth = MediaQuery.of(context).size.width ~/ 3;

    return Container(
      width: _itemWidth.toDouble(),
      height: _itemHeight.toDouble(),
      alignment: Alignment.center,
      child: MaterialButton(
        onPressed: () {
          _controller.forward();
          clearIcon != null ? onClearIconPressed!() : onKeyPressed!();
        },
        child: ScaleTransition(
          scale: _animation,
          child: clearIcon != null
              ? clearIcon
              : Text(
            n!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color:ArborColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class ArborKeyPadTextBottomLeftItem extends StatelessWidget {
  final ArborKeyPadSize? size;
  final Function()? onPressed;
  final String? label;

  ArborKeyPadTextBottomLeftItem({this.size, this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    double _heightDivider = 12.0;

    if (size == ArborKeyPadSize.compact) {
      _heightDivider = 10.0;
    }
    if (size == ArborKeyPadSize.large) {
      _heightDivider = 8.0;
    }

    int _itemHeight = MediaQuery.of(context).size.height ~/ _heightDivider;
    int _itemWidth = MediaQuery.of(context).size.width ~/ 3;

    return Container(
      width: _itemWidth.toDouble(),
      height: _itemHeight.toDouble(),
      alignment: Alignment.center,
      child: MaterialButton(
        child: Center(
          child: Text(
            label!,
            style: Theme.of(context).textTheme.headline1!.copyWith(
              fontSize: 12,
            ),
          ),
        ),
        onPressed: onPressed!,
      ),
    );
  }
}

class ArborKeyPadEmptyItem extends StatelessWidget {
  final ArborKeyPadSize? size;

  ArborKeyPadEmptyItem({this.size});

  @override
  Widget build(BuildContext context) {
    double _heightDivider = 12.0;

    if (size == ArborKeyPadSize.compact) {
      _heightDivider = 10.0;
    }
    if (size == ArborKeyPadSize.large) {
      _heightDivider = 8.0;
    }

    int _itemHeight = MediaQuery.of(context).size.height ~/ _heightDivider;
    int _itemWidth = MediaQuery.of(context).size.width ~/ 3;

    return SizedBox(
      width: _itemWidth.toDouble(),
      height: _itemHeight.toDouble(),
    );
  }
}