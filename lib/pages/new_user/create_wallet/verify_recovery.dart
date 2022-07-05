import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wallet/code/constants.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/new_user/pin_biometric.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/onboard_widgets.dart';

class VerifyRecoveryPage extends StatefulWidget {
  final List<String> words;
  const VerifyRecoveryPage({
    Key? key,
    required this.words,
  }) : super(key: key);

  @override
  _VerifyRecoveryPageState createState() => _VerifyRecoveryPageState();
}

class _VerifyRecoveryPageState extends State<VerifyRecoveryPage> {
  List<String> shuffledList = [];
  List<String> selectedList = [];
  List<String> challengeList = [];
  Map<int, List<String>> asdf = {};
  Map<int, String> selected = {};
  int totalChallenges = 3;
  bool isValid = false;
  TextEditingController nameController = TextEditingController();

  getChallenge() {
    // shuffledList = List.from(widget.words);
    // shuffledList.shuffle();
    // challengeList =
    //     shuffledList.where((e) => 0.5 < rand.nextDouble()).take(3).toList();
    while (challengeList.length < totalChallenges) {
      String randomWord = _getRandomWord(widget.words);
      if (challengeList.contains(randomWord)) continue;
      challengeList.add(randomWord);
    }
    int i = 0;
    while (asdf.length < totalChallenges) {
      List<String> filler =
          services.generateMnemonic().split(" ").take(2).toList();
      if (filler.any((e) => challengeList.contains(e))) continue;
      filler.add(challengeList[i]);
      filler.shuffle();
      asdf.addAll({
        i: filler,
      });
      i++;
    }
    print(asdf);
  }

  bool checkValidity() {
    bool isValid = true;
    selected.forEach((key, value) {
      if (widget.words[key] != value) isValid = false;
    });
    return isValid;
  }

  String _getRandomWord(List<String> list) {
    var items = List.from(list)..shuffle();
    return items.first;
  }

  @override
  void initState() {
    super.initState();
    // shuffledList = List.from(widget.words);
    // shuffledList.shuffle();
    getChallenge();
  }

  @override
  Widget build(BuildContext context) {
    bool invalidOrder = false;
    for (var i = 0; i < selectedList.length; i++) {
      if (selectedList[i] != widget.words[i]) invalidOrder = true;
    }
    isValid = selectedList.length == widget.words.length && !invalidOrder;

    Widget challengeItem(List<String> words, int index) {
      index = widget.words.indexOf(challengeList[index]) + 1;
      return Column(
        children: [
          Text(
            "Select word $index",
            style:
                Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 18),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: words
                .map((e) => GestureDetector(
                      onTap: () => setState(() => selected[index - 1] = e),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 4.0, right: 4.0, bottom: 16, top: 2),
                        child: OnboardWidgets.wordItem(e, index,
                            showIndex: false,
                            isSelected: selected[index - 1] == e),
                      ),
                    ))
                .toList(),
          )
        ],
      );
    }

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

    List<Widget> nameField() {
      return [
        SizedBox(
          height: 8,
        ),
        Align(alignment: Alignment.centerLeft, child: Text("Wallet Name")),
        SizedBox(
          height: 8,
        ),
        TextFormField(
          controller: nameController,
          validator: (val) =>
              val == "" ? "Please enter a name for the wallet" : null,
          maxLength: 20,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: "Name",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
          ),
          onChanged: (val) => setState(() {}),
        ),
      ];
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
          height: Get.height,
          width: Get.width,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OnboardWidgets.titleAlt("Verify Recovery phrase"),
                    OnboardWidgets.subtitle(
                        "Select the appropriately numbered words"),
                    // code(),
                    // actions(),
                    SizedBox(
                      height: 16,
                    ),
                    // Container(
                    //   constraints: BoxConstraints(minHeight: Get.height * 0.1),
                    //   color: Colors.grey.withOpacity(0.2),
                    //   width: Get.width,
                    //   padding: EdgeInsets.all(8),
                    //   child: Column(
                    //     children: [
                    //       challengeWidget(isSelected: true),
                    //       invalidOrder
                    //           ? Text(
                    //               "Invalid Order!",
                    //               style: TextStyle(color: Colors.red),
                    //             )
                    //           : Container()
                    //     ],
                    //   ),
                    // ),
                    for (var i = 0; i < totalChallenges; i++)
                      challengeItem(asdf[i]!, i),
                    // SizedBox(
                    //   height: 16,
                    // ),
                    // challengeWidget(isSelected: false),
                    ...nameField(),
                    // Spacer(),
                    // OnboardWidgets.neverShare(),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: Get.width,
                  padding: EdgeInsets.only(top: 8),
                  child: TextButton(
                    onPressed: () {
                      if (checkValidity()) {
                        // Get.offAll(() => PinBiometricPage());
                        // print("valid");
                        onsubmit();
                      } else {
                        CommonWidgets.snackBar("You selected the wrong words");
                      }
                    },
                    // onPressed: isValid ? onsubmit : null,
                    child: Text(
                      "DONE",
                      // style: TextStyle(color: Colors.white),
                    ),
                    style: MyButtonStyles.onboardStyle,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void onsubmit() {
    if (nameController.text.isNotEmpty) {
      String mnemonic = FormatText.wordList(widget.words);
      print(mnemonic);
      // StorageService.instance.storeMnemonic(mnemonic);
      // services.initWallet(mnemonic);
      Get.offAll(() => PinBiometricPage(
            mnemonic: mnemonic,
            name: nameController.text.trim(),
          ));
    } else
      CommonWidgets.snackBar("Please enter a wallet name");
  }
}
