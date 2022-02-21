import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wallet/pages/settings/browser.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({Key? key}) : super(key: key);

  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  List currency = ["USD", "GBP", "INR", "AUD", "CAD", "CHF", "EUR", "NZD"];
  int currencyIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preferences"),
      ),
      body: Container(
      child: Column(
        children: [
          ListTile(
            title: Text("Currency"),
            subtitle: Text(currency[currencyIndex]),
            trailing: Icon(Icons.navigate_next),
            onTap: (){
              showDialog(context: context, builder: (context) {
                return AlertDialog(
                  content: Container(
                    width: double.maxFinite,
                    // height: 100,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      // itemExtent: 100,
                      itemCount: currency.length,
                      itemBuilder: (context, index) {
                        return ListTile(title: Text(currency[index]), onTap: (){
                          setState(() {
                            currencyIndex = index;
                          });
                          Navigator.pop(context);
                        },);
                      },
                    ),
                  ),
                );
              });
            },
          ),
          ListTile(
            title: Text("DApp Browser"),
            trailing: Icon(Icons.navigate_next),
            onTap: (){
              pushNewScreen(context, screen: BrowserSettingsPage());
            },
          )
        ],
      ),
    ),);
  }
}
