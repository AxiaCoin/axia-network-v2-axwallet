import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:wallet/Crypto_Models/validator.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/home_widgets.dart';
import 'package:wallet/widgets/onboard_widgets.dart';
import 'package:wallet/widgets/spinner.dart';
import 'package:wallet/widgets/validator_tile.dart';

class DelegatePage extends StatefulWidget {
  const DelegatePage({Key? key}) : super(key: key);

  @override
  State<DelegatePage> createState() => _DelegatePageState();
}

class _DelegatePageState extends State<DelegatePage> {
  TextEditingController controller = new TextEditingController();
  List<ValidatorItem> validators = [];
  bool isLoading = false;
  List<List<String>> data = [
    [
      "NodeID-P7oB2McjBGgW2NXXWVYjV8JEDFoW9xDE5",
      "2,000,000",
      "999,975",
      "1",
      "in 3 months",
      "6.25%",
    ],
    [
      "NodeID-GWPcbFJZFfZreETSoWjPimr846mXEKCtu",
      "2,000,000",
      "1,000,000",
      "4",
      "in 3 months",
      "12.5%"
    ],
    [
      "NodeID-NFBbbJ4qCmNaCzeW7sxErhvWqvEQMnYcN",
      "2,000,000",
      "1,000,000",
      "9",
      "in 3 month",
      "25%"
    ],
    [
      "NodeID-MFrZFVCXPv5iCn6M9K6XduxGTYp891xXZ",
      "2,000,000",
      "1,000,000",
      "0",
      "in 3 month",
      "50%"
    ],
    [
      "NodeID-7Xhw2mDxuDS44j42TCB6U5579esbSt3Lg",
      "2,000,000",
      "1,000,000",
      "2",
      "in 3 month",
      "100%"
    ],
  ];

  getValidators() async {
    setState(() => isLoading = true);
    var response = (await services.axSDK.api!.nomination
        .getValidators())["validators"] as List;
    print("response is $response");
    validators = response.map((e) => ValidatorItem.fromMap(e)).toList();
    validators
        .sort((a, b) => b.delegators.length.compareTo(a.delegators.length));
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    getValidators();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: Text("Delegate"),
          centerTitle: true,
          // leading: CommonWidgets.backButton(context),
        );

    Widget searchbar() => Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Color(0x4040401A),
                spreadRadius: 0,
                blurRadius: 16,
              ),
            ],
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black12,
                ),
                hintText: "Search Node",
                hintStyle: TextStyle(
                  color: Colors.black12,
                )),
          ),
        );

    Widget button() => TextButton(onPressed: () {}, child: Text("Select"));

    Widget dataTable() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            children: [
              DataTable(
                columns: <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Node ID',
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Validator Stake',
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Available',
                    ),
                  ),
                  DataColumn(label: Icon(Icons.people)),
                  DataColumn(
                    label: Text(
                      'End Time',
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Fee',
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      '',
                    ),
                  ),
                ],
                rows: <DataRow>[
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text(data[0][0])),
                      DataCell(Text(data[0][1])),
                      DataCell(Text(data[0][2])),
                      DataCell(Text(data[0][3])),
                      DataCell(Text(data[0][4])),
                      DataCell(Text(data[0][5])),
                      DataCell(button()),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text(data[1][0])),
                      DataCell(Text(data[1][1])),
                      DataCell(Text(data[1][2])),
                      DataCell(Text(data[1][3])),
                      DataCell(Text(data[1][4])),
                      DataCell(Text(data[1][5])),
                      DataCell(button()),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text(data[2][0])),
                      DataCell(Text(data[2][1])),
                      DataCell(Text(data[2][2])),
                      DataCell(Text(data[2][3])),
                      DataCell(Text(data[2][4])),
                      DataCell(Text(data[2][5])),
                      DataCell(button()),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text(data[3][0])),
                      DataCell(Text(data[3][1])),
                      DataCell(Text(data[3][2])),
                      DataCell(Text(data[3][3])),
                      DataCell(Text(data[3][4])),
                      DataCell(Text(data[3][5])),
                      DataCell(button()),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text(data[4][0])),
                      DataCell(Text(data[4][1])),
                      DataCell(Text(data[4][2])),
                      DataCell(Text(data[4][3])),
                      DataCell(Text(data[4][4])),
                      DataCell(Text(data[4][5])),
                      DataCell(button()),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: appBar(),
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.add),
        //   onPressed: () async {
        //     var wallet = await services.axSDK.api!.basic.getWallet();
        //     print(wallet);
        //     var balance = await services.axSDK.api!.basic.getBalance();
        //     print(balance);
        //   },
        // ),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: validators.isEmpty
                ? Center(child: Spinner())
                : SearchableList<ValidatorItem>(
                    initialList: validators,
                    builder: (validator) {
                      return ValidatorTile(validator: validator);
                    },
                    emptyWidget:
                        OnboardWidgets.neverShare(text: "No nodes found"),
                    filter: (value) => validators
                        .where((element) => element.nodeID
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList(),
                    inputDecoration: InputDecoration(
                        border: InputBorder.none,
                        // prefixIcon: Icon(
                        //   Icons.search,
                        //   color: Colors.black12,
                        // ),
                        hintText: "Search Node",
                        hintStyle: TextStyle(
                          color: Colors.black12,
                        )),
                  )
            // child: Column(
            //   children: [
            //     searchbar(),
            //     validators.isEmpty
            //         ? Spinner()
            //         : Expanded(
            //             child: RefreshIndicator(
            //               onRefresh: () async {
            //                 await getValidators();
            //               },
            //               child: ListView.builder(
            //                   shrinkWrap: true,
            //                   itemCount: validators.length,
            //                   itemBuilder: ((context, index) {
            //                     var item = validators[index];
            //                     return ValidatorTile(validator: item);
            //                   })),
            //             ),
            //           ),
            //   ],
            // ),
            ),
      ),
    );
  }
}
