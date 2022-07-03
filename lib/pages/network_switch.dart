import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/cache.dart';
import 'package:wallet/code/constants.dart';
import 'package:axwallet_sdk/models/network_config.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/spinner.dart';

class NetworkSwitchPage extends StatefulWidget {
  const NetworkSwitchPage({Key? key}) : super(key: key);

  @override
  State<NetworkSwitchPage> createState() => _NetworkSwitchPageState();
}

class _NetworkSwitchPageState extends State<NetworkSwitchPage> {
  List<NetworkConfig> networkConfigs = [];
  List<NetworkConfig> customNetworkConfigs = [];

  fetchNetworkConfigs() async {
    var data = await services.fetchNetworkConfigs();
    if (data == null) return;
    networkConfigs = data;
    setState(() {});
  }

  onChange(NetworkConfig config) async {
    CommonWidgets.waitDialog(text: "Changing network. Please wait");
    bool isSuccessful = await services.axSDK.api!.basic.changeNetwork(config);
    if (isSuccessful) {
      print("connected is $isSuccessful");
      StorageService.instance.updateConnectedNetwork(config);
      services.getAXCWalletDetails();
    }
    Get.back();
    CommonWidgets.snackBar(isSuccessful
        ? "Succesfully changed to ${config.name}"
        : "Failed to change network. Please try again");
    setState(() {});
  }

  // Widget textField(String title, String value) {
  //   return TextField(
  //     keyboardType: TextInputType.text,
  //     decoration: InputDecoration(
  //       hintText: title,
  //       border: OutlineInputBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(15))),
  //     ),
  //     onChanged: (val) => value = val,
  //   );
  // }

  // showCustomDialog() async {
  //   Map<String, dynamic>? newNetwork = await Get.dialog(
  //     Builder(builder: (context) {
  //       String name = "";
  //       String url = "";
  //       String exp = "";
  //       String expSite = "";
  //       return AlertDialog(
  //         title: Text("Add Custom Network"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             textField("Network Name", name),
  //             SizedBox(
  //               height: 4,
  //             ),
  //             textField("URL", url),
  //             SizedBox(
  //               height: 4,
  //             ),
  //             textField("Explorer API", exp),
  //             SizedBox(
  //               height: 4,
  //             ),
  //             textField("Explorer Site", expSite),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
  //           TextButton(
  //               onPressed: () => Get.back(result: {
  //                     "name": name,
  //                     "url": url,
  //                     "expl": exp,
  //                     "explS": expSite,
  //                   }),
  //               child: Text("Add")),
  //         ],
  //       );
  //     }),
  //   );
  //   print(newNetwork);
  // }

  @override
  void initState() {
    super.initState();
    networkConfigs = CustomCacheManager.instance.networkConfigs();
    customNetworkConfigs = CustomCacheManager.instance.customNetworkConfigs();
    fetchNetworkConfigs();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: Text("Select Network"),
          centerTitle: true,
          actions: [
            // IconButton(onPressed: showCustomDialog, icon: Icon(Icons.add))
          ],
          leading: CommonWidgets.backButton(context),
        );

    Widget listTile(NetworkConfig item, {bool isCustom = false}) {
      NetworkConfig? selected = StorageService.instance.connectedNetwork;
      bool isSelected = selected == item;
      return ListTile(
        title: Text(item.name),
        subtitle: Text(item.url),
        trailing: Icon(
          isSelected ? Icons.check_circle : Icons.keyboard_arrow_right,
          color: isSelected ? tickerGreen : null,
        ),
        leading: isCustom
            ? IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  print("edit");
                })
            : null,
        onTap: () {
          // if (isSelected) return;
          onChange(item);
        },
      );
    }

    return Scaffold(
      appBar: appBar(),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: () async {
      //     fetchNetworkConfigs();
      //   },
      // ),
      body: networkConfigs.isEmpty
          ? Center(
              child: Spinner(
                text: "Fetching network list",
              ),
            )
          : ListView(
              children: networkConfigs.map((e) => listTile(e)).toList() +
                  customNetworkConfigs
                      .map((e) => listTile(e, isCustom: true))
                      .toList(),
            ),
    );
  }
}
