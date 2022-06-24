import 'package:flutter/material.dart';
import 'package:wallet/widgets/common.dart';

class DelegatePage extends StatefulWidget {
  const DelegatePage({Key? key}) : super(key: key);

  @override
  State<DelegatePage> createState() => _DelegatePageState();
}

class _DelegatePageState extends State<DelegatePage> {
  TextEditingController controller = new TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: Text("Delegate"),
          centerTitle: true,
          leading: CommonWidgets.backButton(context),
        );

    Widget searchbar() => Column(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select a node to delegate:",
                  style: TextStyle(fontSize: 14),
                )),
            Container(
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
                    hintText: "Search Node ID",
                    hintStyle: TextStyle(
                      color: Colors.black12,
                    )),
              ),
            ),
          ],
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
        body: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [searchbar(), dataTable()],
          ),
        ),
      ),
    );
  }
}
