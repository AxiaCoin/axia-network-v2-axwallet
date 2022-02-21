import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({Key? key}) : super(key: key);

  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool isSecure = true;
  bool txnSigning = false;
  List autoLock = ["Immediate", "If away for 1 minute", "If away for 5 minutes", "If away for 1 hour", "If away for 5 hours"];
  int autoLockIndex = 0;
  List lockMethod = ["Passcode", "Passcode / Biometric"];
  int lockMethodIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Security"),
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                  title: Text("Passcode"),
                  value: isSecure,
                  onChanged: (val) {
                    setState(() {
                      isSecure = !isSecure;
                    });
                  }),
              ListTile(
                title: Text("Auto-Lock"),
                subtitle: Text(autoLock[autoLockIndex]),
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
                          itemCount: autoLock.length,
                          itemBuilder: (context, index) {
                            return ListTile(title: Text(autoLock[index]), onTap: (){
                              setState(() {
                                autoLockIndex = index;
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
                title: Text("Lock Method"),
                subtitle: Text(lockMethod[lockMethodIndex]),
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
                          itemCount: lockMethod.length,
                          itemBuilder: (context, index) {
                            return ListTile(title: Text(lockMethod[index]), onTap: (){
                              setState(() {
                                lockMethodIndex = index;
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
                child: Text("Ask authentication for", style: TextStyle(color: appColor, fontWeight: FontWeight.bold, fontSize: 12),),
              ),
              SwitchListTile(
                  title: Text("Transaction Signing"),
                  value: txnSigning, onChanged: (val) {
                setState(() {
                  txnSigning = !txnSigning;
                });
              })
            ],
          ),
        ));
  }
}
