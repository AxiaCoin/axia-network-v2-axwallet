import 'package:flutter/material.dart';

class AllOpenOrdersPage extends StatefulWidget {
  const AllOpenOrdersPage({Key? key}) : super(key: key);

  @override
  _AllOpenOrdersPageState createState() => _AllOpenOrdersPageState();
}

class _AllOpenOrdersPageState extends State<AllOpenOrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
      ),
      body: Container(
        child: Center(
          child: Text("History will appear here"),
        ),
      ),
    );
  }
}
