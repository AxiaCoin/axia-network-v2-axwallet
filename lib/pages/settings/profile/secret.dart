import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/onboard_widgets.dart';

class SecretPhrasePage extends StatefulWidget {
  const SecretPhrasePage({Key? key}) : super(key: key);

  @override
  State<SecretPhrasePage> createState() => _SecretPhrasePageState();
}

class _SecretPhrasePageState extends State<SecretPhrasePage> {
  List<String> words = [];

  Widget code() {
    List<Widget> wordItems = [];
    for (var i = 0; i < words.length; i++) {
      wordItems.add(OnboardWidgets.wordItem(words[i], i + 1));
    }
    return Container(
      // padding: EdgeInsets.only(top: 24),
      child: Wrap(
        children: wordItems,
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
      ),
    );
  }

  initWords() {
    final WalletData walletData = Get.find();
    String currentPubKey = walletData.hdWallet!.value.pubKey!;
    String mnemonic = services.hdWallets[currentPubKey]!.mnemonic;
    words = mnemonic.split(' ');
  }

  @override
  void initState() {
    super.initState();
    initWords();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: Text("Secret Phrase"),
          centerTitle: true,
          leading: CommonWidgets.backButton(context),
        );
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: code(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OnboardWidgets.neverShare(),
            ),
          ],
        ),
      ),
    );
  }
}
