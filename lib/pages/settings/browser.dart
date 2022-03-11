import 'package:flutter/material.dart';

class BrowserSettingsPage extends StatefulWidget {
  const BrowserSettingsPage({Key? key}) : super(key: key);

  @override
  _BrowserSettingsPageState createState() => _BrowserSettingsPageState();
}

class _BrowserSettingsPageState extends State<BrowserSettingsPage> {
  bool useBrowser = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DApp Browser"),
      ),
      body: Container(
        child: Column(
          children: [
            SwitchListTile.adaptive(
              title: Text("Enable"),
              value: useBrowser,
              onChanged: (val) {
                setState(
                  () {
                    useBrowser = val;
                  },
                );
              },
            ),
            ListTile(
              title: Text("Clear browser cache"),
            )
          ],
        ),
      ),
    );
  }
}
