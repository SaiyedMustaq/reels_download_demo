import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InstaLogin extends StatefulWidget {
  @override
  InstaLoginState createState() => InstaLoginState();
}

class InstaLoginState extends State<InstaLogin> {
  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          print("REQUEST--> ${request}");
          if (request.url
              .startsWith('https://www.instagram.com/accounts/login/')) {
            return NavigationDecision.prevent;
          }
          Navigator.pop(context);
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse('https://www.instagram.com/accounts/login/'));
    // Enable virtual display.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: WebViewWidget(controller: webViewController),
    );
  }
}
