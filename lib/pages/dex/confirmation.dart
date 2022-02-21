import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/widgets/common.dart';

class ConfirmationPage extends StatefulWidget {
  final CoinData from;
  final String fromValue;
  final CoinData to;
  final String toValue;
  const ConfirmationPage({Key? key, required this.from, required this.to, required this.fromValue, required this.toValue}) : super(key: key);

  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  late CoinData from;
  late double fromValue;
  late CoinData to;
  late double toValue;

  @override
  void initState() {
    super.initState();
    from = widget.from;
    fromValue = double.parse(widget.fromValue);
    to = widget.to;
    toValue = double.parse(widget.toValue);
  }

  @override
  Widget build(BuildContext context) {

    Widget listTile(String leading, String trailing) => ListTile(
      leading: Text(leading, style: context.textTheme.bodyText2!.copyWith(fontSize: 16),),
      trailing: Text(trailing, style: context.textTheme.caption!.copyWith(fontSize: 14),),
      dense: true,
    );

    return Scaffold(
        appBar: AppBar(
          title: Text("Swap"),
          centerTitle: true,
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: FlutterLogo(),
                title: Text("$fromValue ${from.unit}"),
                subtitle: Text("BEP 2"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05, vertical: 0),
                child: Icon(Icons.arrow_downward),
              ),
              ListTile(
                leading: FlutterLogo(),
                title: Text("$toValue ${to.unit}"),
                subtitle: Text("BEP 2"),
              ),
              SizedBox(height: 16,),
              Card(
                child: listTile("From", "Wallet 1 (${FormatText.address("bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh")})")
              ),
              SizedBox(height: 8,),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    listTile("Protocol", "Binance DEX"),
                    Divider(indent: 16, endIndent: 16,),
                    listTile("Max Slippage", "1%"),
                    Divider(indent: 16, endIndent: 16,),
                    listTile("Network Fee", "0.00001${from.unit} ~ \$0.00"),
                  ],
                ),
              ),
              Spacer(),
              Container(
                  width: Get.width,
                  child: ElevatedButton(onPressed: (){
                    Get.back(result: true);
                    CommonWidgets.snackBar("Swap Successful", copyMode: false);
                  }, child: Text("Confirm Swap"), style: MyButtonStyles.onboardStyle,))
            ],
          ),
        ));
  }
}
