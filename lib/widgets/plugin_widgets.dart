import 'package:flutter/material.dart';
import 'package:wallet/code/constants.dart';

class PluginWidgets {
  PluginWidgets._();

  static Widget earntiles(
          String title, String subtitle, IconData icon, Function() onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
            color: Colors.grey[50],
            boxShadow: [
              BoxShadow(
                color: Color(0x2424240F),
                offset: Offset(0, 4),
                spreadRadius: 0,
                blurRadius: 16,
              ),
            ],
          ),
          child: Center(
            child: ListTile(
              leading: Icon(
                icon,
                size: 35,
                color: appColor,
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ),
      );

  static Widget indexTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.w100, color: Colors.black54),
      ),
    );
  }
}
