import 'package:flutter/material.dart';

class ManageWalletsPage extends StatefulWidget {
  const ManageWalletsPage({Key? key}) : super(key: key);

  @override
  _ManageWalletsPageState createState() => _ManageWalletsPageState();
}

class _ManageWalletsPageState extends State<ManageWalletsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Wallet"),
          actions: [
            IconButton(onPressed: (){}, icon: Icon(Icons.add))
          ],
        ),
        body: Container(
          child: Column(
            children: [
              ListTile(
                leading: FlutterLogo(),
                title: Text("Wallet 1"),
                subtitle: Text("Wallet"),
                trailing: IconButton(
                  icon: Icon(Icons.more_vert_outlined),
                  onPressed: (){},
                ),
              )
            ],
          ),
        ));
  }
}
