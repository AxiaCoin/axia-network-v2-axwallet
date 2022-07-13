import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/widgets/common.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
        centerTitle: true,
        leading: CommonWidgets.backButton(context),
      ),
      body: Column(children: [
        Container(
          padding: EdgeInsets.all(48),
          width: Get.width / 2,
          child: Image.asset('assets/images/app_logo.png'),
        ),
        Center(
          child: Text(
            "Mobile Wallet for AXIA",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 16,
          ),
          child: GestureDetector(
              onTap: () {
                CommonWidgets.launch('https://axia.global/');
              },
              child: Text(
                'https://axia.global/',
                style: TextStyle(color: Colors.blue),
              )),
        ),
      ]),
    );
  }
}
