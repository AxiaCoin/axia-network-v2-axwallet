import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/code/constants.dart';

class Spinner extends StatefulWidget {
  final Widget? child;
  final bool alt;
  final String? text;
  const Spinner({
    Key? key,
    this.child,
    this.alt = false,
    this.text,
  }) : super(key: key);

  @override
  _SpinnerState createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _controller.repeat(period: Duration(milliseconds: 1500));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
          child: widget.child ??
              SvgPicture.asset(
                'assets/icons/loading' + (widget.alt ? '_alt' : '') + '.svg',
                color: Theme.of(context).primaryColor,
              ),
        ),
        widget.text != null
            ? Text(
                widget.text!,
                style: TextStyle(
                    color: appColor[300], fontStyle: FontStyle.italic),
              )
            : SizedBox.shrink()
      ],
    );
  }
}
