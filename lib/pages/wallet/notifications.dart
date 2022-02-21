import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/widgets/home_widgets.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool isLoading = true;
  bool isRefreshing = false;
  List data = [];

  Future refreshData() async {
    if (isLoading || isRefreshing) {
      await 1.delay();
      var rand = Random().nextInt(2);
      if (rand == 0) {
        for (var i = 0; i < 10; i++) {
          data.add(ListTile(
            title: Text("Notif $i"),
            subtitle: Text("Description for notif $i"),
            leading: FlutterLogo(),
          ));
        }
      } else {
        data.clear();
      }
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
    }
  }

  Widget notificationsList(List item) {
    return RefreshIndicator(
      onRefresh: () async {
        isRefreshing = true;
        await refreshData();
      },
      child: ListView.builder(
          itemCount: item.length,
          itemBuilder: (context, index) {
        return Container(
          child: item[index],
        );
      }),
    );
  }

  Widget emptyList() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: Get.width * 0.25,
            width: Get.width * 0.25,
            child: FittedBox(

                child: FlutterLogo()
            ),
          ),
          SizedBox(height: 16,),
          HomeWidgets.emptyListText("Notifications will appear here"),
          // SizedBox(height: 8,),
          TextButton(onPressed: () async {
            setState(() {
              isLoading = true;
            });
            refreshData();
          }, child: Text("Refresh"))
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //brightness: Brightness.dark,
          title: Text("Notifications"),
        ),
        body: Container(
          // padding: EdgeInsets.all(8),
          alignment: Alignment.center,
          child: isLoading ? CircularProgressIndicator() : data.isEmpty ? emptyList() : notificationsList(data),
        ));
  }
}
