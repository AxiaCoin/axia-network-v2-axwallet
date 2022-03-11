import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/pages/webview.dart';
class SeeAllPage extends StatelessWidget {
  final String title;
  final List<DAppsTile> data;
  const SeeAllPage({Key? key, required this.title, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          //brightness: Brightness.dark,
          title: Text(title),
          // actions: [IconButton(onPressed: () {}, icon: Icon(Icons.info_outline))],
        );

    return Scaffold(appBar: appBar(), body: Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ListView.separated(
          separatorBuilder: (context, i) {
            return Divider();
          },
            itemCount: data.length,
            itemBuilder: (context, index) {
              var item = data[index];
          return ListTile(
            title: Text(item.title),
            subtitle: Text(item.subtitle),
            leading: item.image,
            onTap: (){
              Get.to(() => WebViewPage(url: item.url));
            },
          );
        }),
      ),
    ),
      // bottomNavigationBar: SizedBox(height: kBottomNavigationBarHeight,),
    );
  }
}
