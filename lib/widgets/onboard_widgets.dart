import 'package:flutter/material.dart';
import 'package:wallet/code/models.dart';

class OnboardWidgets {
  OnboardWidgets._();

  static Widget title(String text) => Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      textAlign: TextAlign.center,
    ),
  );

  static Widget subtitle(String text) => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black54),
      textAlign: TextAlign.center,
    ),
  );

  static Widget titleAlt(String text) => Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Text(
      text,
      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 24),
      textAlign: TextAlign.center,
    ),
  );

  static Widget wordItem(String word, int index, {bool showIndex = true}) => GestureDetector(
    child: Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black.withOpacity(0.1)),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        color: Colors.white
      ),
      padding: EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          showIndex ? Text("$index ", style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 16),) : Container(),
          Text(word, style: TextStyle(fontSize: 16),),
        ],
      ),
    ),
  );

  static Widget neverShare() => Container(
    padding: EdgeInsets.only(bottom: 16),
    child: ListTile(
      title: Text(
        "Never share recovery phrase with anyone, store it securely!",
        style: TextStyle(color: Colors.red[900], fontSize: 14),
      ),
      leading: Icon(
        Icons.warning_amber,
        color: Colors.red[900],
      ),
      tileColor: Colors.red.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
    ),
  );
}