import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';

class NumberKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final double viewFraction;
  final Color backgroundColor;
  final double backgroundOpacity;
  final bool showClose;

  NumberKeyboard(
      {Key? key,
      required this.controller,
      this.viewFraction = 0.3,
      this.backgroundColor = Colors.black,
      this.backgroundOpacity = 0.03,
      this.showClose = false})
      : super(key: key);

  @override
  _NumberKeyboardState createState() => _NumberKeyboardState();
}

class _NumberKeyboardState extends State<NumberKeyboard> {
  bool isLongDeleting = false;

  void insertText(String myText) {
    final text = widget.controller.text;
    if (text.contains(".") && myText == ".") return;
    var textSelection = widget.controller.selection;
    if (textSelection.baseOffset < 0)
      textSelection = TextSelection(
        baseOffset: text.length,
        extentOffset: text.length,
      );
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      myText,
    );
    final myTextLength = myText.length;
    widget.controller.text = newText;
    widget.controller.selection = textSelection.copyWith(
      baseOffset: textSelection.start + myTextLength,
      extentOffset: textSelection.start + myTextLength,
    );
  }

  void backspace() {
    final text = widget.controller.text;
    var textSelection = widget.controller.selection;
    if (textSelection.baseOffset < 0)
      textSelection =
          TextSelection(baseOffset: text.length, extentOffset: text.length);
    final selectionLength = textSelection.end - textSelection.start;
    // There is a selection.
    if (selectionLength > 0) {
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        '',
      );
      widget.controller.text = newText;
      widget.controller.selection = textSelection.copyWith(
        baseOffset: textSelection.start,
        extentOffset: textSelection.start,
      );
      return;
    }
    // The cursor is at the beginning.
    if (textSelection.start == 0) {
      return;
    }
    // Delete the previous character
    final previousCodeUnit = text.codeUnitAt(textSelection.start - 1);
    final offset = _isUtf16Surrogate(previousCodeUnit) ? 2 : 1;
    final newStart = textSelection.start - offset;
    final newEnd = textSelection.start;
    final newText = text.replaceRange(
      newStart,
      newEnd,
      '',
    );
    widget.controller.text = newText;
    widget.controller.selection = textSelection.copyWith(
      baseOffset: newStart,
      extentOffset: newStart,
    );
  }

  bool _isUtf16Surrogate(int value) {
    return value & 0xF800 == 0xD800;
  }

  Future longDelete() async {
    while (this.isLongDeleting) {
      print("deleting $isLongDeleting");
      backspace();
      await 0.1.delay();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget numPadCell(String pad) {
      return Expanded(
        child: GestureDetector(
          onLongPressStart: (_) {
            if (pad == "X") {
              isLongDeleting = true;
              longDelete();
            }
          },
          onLongPressEnd: (_) {
            isLongDeleting = false;
          },
          child: TextButton(
            // style: TextButton.styleFrom(backgroundColor: Colors.transparent),
            // color: Theme.of(context).accentColor.withOpacity(1),
            // shape: CircleBorder(
            //   side: BorderSide(color: Colors.white, width: 5, style: BorderStyle.solid),
            // ),
//        padding: EdgeInsets.all(20),
            child: pad != "X"
                ? Text(
                    pad,
                    style: TextStyle(fontSize: 32),
                  )
                : Icon(Icons.backspace),
            onPressed: () {
              if (pad == "X") {
                backspace();
              } else {
                insertText(pad);
                // controller.text += pad;
              }
            },
          ),
        ),
      );
    }

    return Column(
      // alignment: Alignment.topCenter,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        widget.showClose
            ? Icon(
                Icons.cancel,
                size: 28,
                color: appColor,
              )
            : Container(),
        Container(
          // color: Colors.white,
          height: Get.height * widget.viewFraction,
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.all(Radius.circular(10))),
          // height: MediaQuery.of(context).size.height * 0.50,
          // width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    numPadCell('1'),
                    numPadCell('2'),
                    numPadCell('3'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    numPadCell('4'),
                    numPadCell('5'),
                    numPadCell('6'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    numPadCell('7'),
                    numPadCell('8'),
                    numPadCell('9'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    numPadCell('.'),
                    numPadCell('0'),
                    numPadCell('X'),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
