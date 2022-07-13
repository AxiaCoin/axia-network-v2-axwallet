import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/spinner.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool isLoading = true;
  late WebViewController controller;

  Future<bool> willPop() async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return false;
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: willPop,
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            widget.url.split("/")[2].replaceAll("www.", ""),
            maxLines: 1,
          ),
          leading: CommonWidgets.backButton(context),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            WebView(
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (ctrl) {
                controller = ctrl;
              },
              onPageFinished: (ctrl) {
                setState(() {
                  isLoading = false;
                });
              },
              onProgress: (ctrl) {
                setState(() {
                  isLoading = true;
                });
              },
            ),
            isLoading ? Spinner() : Container(),
          ],
        ),
      ),
    );
  }
}

// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:wallet/widgets/common.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class WebViewPage extends StatefulWidget {
//   final String url;
//   const WebViewPage({Key? key, required this.url}) : super(key: key);

//   @override
//   _WebViewPageState createState() => _WebViewPageState();
// }

// class _WebViewPageState extends State<WebViewPage> {
//   @override
//   Widget build(BuildContext context) {
//     URLRequest urlRequest = URLRequest(url: Uri.parse(widget.url));
//     return Scaffold(
//       appBar: AppBar(
//         title: AutoSizeText(
//           widget.url.split("/")[2].replaceAll("www.", ""),
//           maxLines: 1,
//         ),
//         leading: CommonWidgets.backButton(context),
//       ),
//       body: InAppWebView(
//         initialUrlRequest: urlRequest,
//       ),
//     );
//   }
// }
