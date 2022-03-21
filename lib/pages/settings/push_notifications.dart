import 'package:flutter/material.dart';

class PushNotificationsPage extends StatefulWidget {
  const PushNotificationsPage({Key? key}) : super(key: key);

  @override
  _PushNotificationsPageState createState() => _PushNotificationsPageState();
}

class _PushNotificationsPageState extends State<PushNotificationsPage> {
  @override
  Widget build(BuildContext context) {
    bool allowed = true;
    return Scaffold(
      appBar: AppBar(
        title: Text("Push Notifications"),
      ),
      body: Container(
        child: Column(
          children: [
            SwitchListTile.adaptive(
              title: Text("Allow Push Notifications"),
              value: allowed,
              onChanged: (val) {
                setState(
                  () {
                    allowed = val;
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
