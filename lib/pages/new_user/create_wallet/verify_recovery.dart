import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/pages/home.dart';
import 'package:wallet/pages/new_user/pin_biometric.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/home.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/onboard_widgets.dart';

class VerifyRecoveryPage extends StatefulWidget {
  final List<String> words;
  const VerifyRecoveryPage({Key? key, required this.words}) : super(key: key);

  @override
  _VerifyRecoveryPageState createState() => _VerifyRecoveryPageState();
}

class _VerifyRecoveryPageState extends State<VerifyRecoveryPage> {
  List<String> shuffledList = [];
  List<String> selectedList = [];
  bool isValid = false;

  @override
  void initState() {
    super.initState();
    shuffledList = List.from(widget.words);
    shuffledList.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    bool invalidOrder = false;
    for (var i = 0; i < selectedList.length; i++) {
      if (selectedList[i] != widget.words[i]) invalidOrder = true;
    }
    isValid = selectedList.length == widget.words.length && !invalidOrder;

    Widget challengeWidget({required bool isSelected}) {
      List<String> items = isSelected ? selectedList : shuffledList;
      List<Widget> wordItems = [];
      for (var i = 0; i < items.length; i++) {
        String item = items[i];
        wordItems.add(GestureDetector(
            onTap: () {
              setState(
                () {
                  // e.selected = !e.selected;
                  if (!isSelected) {
                    selectedList.add(item);
                    shuffledList.remove(item);
                  } else {
                    selectedList.remove(item);
                    shuffledList.add(item);
                  }
                },
              );
            },
            child: OnboardWidgets.wordItem(item, i + 1,
                showIndex: isSelected ? true : false)));
      }
      return Container(
        child: Wrap(
          children: wordItems,
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Wallet"),
        centerTitle: true,
        leading: CommonWidgets.backButton(context),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OnboardWidgets.titleAlt("Verify Recovery phrase"),
              OnboardWidgets.subtitle(
                  "Tap the words to put them next to each other in the correct order"),
              // code(),
              // actions(),
              SizedBox(
                height: 16,
              ),
              Container(
                constraints: BoxConstraints(minHeight: Get.height * 0.1),
                color: Colors.grey.withOpacity(0.2),
                width: Get.width,
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    challengeWidget(isSelected: true),
                    invalidOrder
                        ? Text(
                            "Invalid Order!",
                            style: TextStyle(color: Colors.red),
                          )
                        : Container()
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              challengeWidget(isSelected: false),
              Spacer(),
              // OnboardWidgets.neverShare(),
              Container(
                width: Get.width,
                padding: EdgeInsets.only(top: 8),
                child: TextButton(
                  // onPressed: () {
                  //   if (isValid) {
                  //     Get.offAll(() => PinBiometricPage());
                  //   }
                  // },
                  onPressed: onsubmit,
                  child: Text("DONE"),
                  style: MyButtonStyles.statefulStyle(isValid),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void onsubmit() {
    if (isValid) {
      String mnemonic = FormatText.wordList(widget.words);
      print(mnemonic);
      // StorageService.instance.storeMnemonic(mnemonic);
      // services.initWallet(mnemonic);
      Get.offAll(() => PinBiometricPage(
            mnemonic: mnemonic,
          ));
    } else
      CommonWidgets.snackBar("Error while importing");
  }
}
