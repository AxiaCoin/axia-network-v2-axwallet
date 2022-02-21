import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/pages/new_user/create_wallet/recovery_phrase.dart';
import 'package:wallet/widgets/onboard_widgets.dart';

class DisclaimerPage extends StatefulWidget {
  const DisclaimerPage({Key? key}) : super(key: key);

  @override
  _DisclaimerPageState createState() => _DisclaimerPageState();
}

class _DisclaimerPageState extends State<DisclaimerPage> {
  var confirmation = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OnboardWidgets.title("Back up your wallet now!"),
              OnboardWidgets.subtitle("In the next step you will see 12 words that allows you to recover a wallet"),
              Spacer(),
              Icon(
                Icons.refresh,
                size: 128,
              ),
              Spacer(),
              Obx(() => Theme(
                    data: Theme.of(context).copyWith(unselectedWidgetColor: appColor),
                    child: CheckboxListTile(
                        value: confirmation.value,
                        title: Text(
                          "I understand that if I lose my recovery words, I will not be able to access my wallet",
                          style: TextStyle(fontSize: 12, color: appColor),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          confirmation.value = value!;
                        }),
                  )),
              Obx(() => Container(
                    width: Get.width,
                    padding: EdgeInsets.only(top: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        if (confirmation.value) {
                          Get.to(() => RecoverPhrasePage());
                          }
                      },
                      child: Text("CONTINUE"),
                      style: MyButtonStyles.statefulStyle(confirmation.value)
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
