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
      appBar: AppBar(
        title: Text("Create Wallet"),
        centerTitle: true,
        leading: CommonWidgets.backButton(context),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                padding:
                    EdgeInsets.only(left: 16.0, right: 16, top: 16, bottom: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OnboardWidgets.titleAlt("Your Recovery phrase"),
                    OnboardWidgets.subtitle(
                        "Write down or copy these words in the right order and save them somewhere safe"),
                    code(),
                    actions(),
                    // Spacer(),
                    OnboardWidgets.neverShare(),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                child: Container(
                  width: Get.width,
                  padding:
                      EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => VerifyRecoveryPage(
                          words: words,
                        )),
                    child: Text("CONTINUE"),
                    style: MyButtonStyles.onboardStyle,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
