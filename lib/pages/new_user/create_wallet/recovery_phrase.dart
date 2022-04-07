import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/new_user/create_wallet/verify_recovery.dart';
import 'package:wallet/pages/qr_creation.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/onboard_widgets.dart';

class RecoverPhrasePage extends StatefulWidget {
  const RecoverPhrasePage({Key? key}) : super(key: key);

  @override
  _RecoverPhrasePageState createState() => _RecoverPhrasePageState();
}

class _RecoverPhrasePageState extends State<RecoverPhrasePage> {
  // List<String> words = [];
  List<String> words = [];

  Widget code() {
    List<Widget> wordItems = [];
    for (var i = 0; i < words.length; i++) {
      wordItems.add(OnboardWidgets.wordItem(words[i], i + 1));
    }
    return Container(
      padding: EdgeInsets.only(top: 24),
      child: Wrap(
        children: wordItems,
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
      ),
    );
  }

  Widget actions() {
    String wordList = FormatText.wordList(words);
    return Container(
      padding: EdgeInsets.only(top: 32),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: wordList));
                print(wordList);
                CommonWidgets.snackBar(wordList, copyMode: true);
              },
              child: Text("COPY")),
          SizedBox(
            width: 16,
          ),
          TextButton(
              onPressed: () {
                Get.to(() => QRCreationPage(qrData: wordList));
              },
              child: Text("SHOW QR")),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    words = services.generateMnemonic().split(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OnboardWidgets.titleAlt("Your Recovery phrase"),
              OnboardWidgets.subtitle(
                  "Write down or copy these words in the right order and save them somewhere safe"),
              code(),
              actions(),
              Spacer(),
              OnboardWidgets.neverShare(),
              Container(
                width: Get.width,
                padding: EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: () => Get.to(() => VerifyRecoveryPage(
                        words: words,
                      )),
                  child: Text("CONTINUE"),
                  style: MyButtonStyles.onboardStyle,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
