import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/pages/settings/feedback.dart';
import 'package:wallet/pages/settings/preferences.dart';
import 'package:wallet/pages/settings/price_alerts.dart';
import 'package:wallet/pages/settings/push_notifications.dart';
import 'package:wallet/pages/settings/security.dart';
import 'package:wallet/pages/settings/wallets.dart';
import 'package:wallet/widgets/home_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SettingsState settingsState = Get.find();

  @override
  Widget build(BuildContext context) {
    print("settings page loaded");
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Container(
        child: ListView(
          children: [
            ListTile(
              title: Text("Wallets"),
              subtitle: Text("Wallet 1"),
              trailing: Icon(Icons.navigate_next),
              leading: HomeWidgets.settingsTileIcon(
                  icon: Icon(Icons.account_balance_wallet),
                  color: Colors.green),
              onTap: () {
                pushNewScreen(context, screen: ManageWalletsPage());
              },
            ),
            Divider(),
            Obx(
              () => SwitchListTile.adaptive(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      HomeWidgets.settingsTileIcon(
                          icon: Icon(Icons.dark_mode), color: Colors.black),
                      SizedBox(
                        width: 16,
                      ),
                      Text("Dark Mode"),
                    ],
                  ),
                  value: settingsState.darkMode.value,
                  onChanged: (val) {
                    settingsState.toggleDarkMode();
                  }),
            ),
            Divider(),
            ListTile(
              title: Text("Security"),
              trailing: Icon(Icons.navigate_next),
              leading: HomeWidgets.settingsTileIcon(
                  icon: Icon(Icons.lock), color: Colors.grey),
              onTap: () {
                pushNewScreen(context, screen: SecurityPage());
              },
            ),
            ListTile(
              title: Text("Push Notifications"),
              trailing: Icon(Icons.navigate_next),
              leading: HomeWidgets.settingsTileIcon(
                  icon: Icon(Icons.doorbell), color: Colors.red),
              onTap: () {
                pushNewScreen(context, screen: PushNotificationsPage());
              },
            ),
            ListTile(
              title: Text("Preferences"),
              trailing: Icon(Icons.navigate_next),
              leading: HomeWidgets.settingsTileIcon(
                  icon: Icon(Icons.settings_applications),
                  color: Colors.lightGreen),
              onTap: () {
                pushNewScreen(context, screen: PreferencesPage());
              },
            ),
            ListTile(
              title: Text("Price Alerts"),
              trailing: Icon(Icons.navigate_next),
              leading: HomeWidgets.settingsTileIcon(
                  icon: Icon(Icons.attach_money), color: Colors.pink),
              onTap: () {
                pushNewScreen(context, screen: PriceAlertsPage());
              },
            ),
            ListTile(
              title: Text("WalletConnect"),
              trailing: Icon(Icons.navigate_next),
              leading: HomeWidgets.settingsTileIcon(
                  icon: Icon(Icons.ac_unit), color: Colors.blue),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                "Join Community",
                style: context.textTheme.caption!.copyWith(color: appColor),
              ),
            ),
            ListTile(
              title: Text("Help Center"),
              trailing: Icon(Icons.navigate_next),
              leading: HomeWidgets.settingsTileIcon(
                  icon: Icon(Icons.help), color: Colors.orange),
            ),
            ListTile(
              title: Text("Feedback"),
              trailing: Icon(Icons.navigate_next),
              leading: HomeWidgets.settingsTileIcon(
                  icon: Icon(Icons.email), color: Colors.blueGrey),
              onTap: () {
                pushNewScreen(context, screen: FeedbackPage());
              },
            ),
            ListTile(
              // dense: true,
              title: Text("About"),
              trailing: Icon(Icons.navigate_next),
              leading: HomeWidgets.settingsTileIcon(
                  icon: Icon(Icons.favorite), color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
