import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity/connectivity.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flooring Deals',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  bool isConnected = true;

  @override
  void initState() {
    super.initState();

    // Subscribe to connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        isConnected = (result != ConnectivityResult.none);

        // Reload the WebView when the internet connection is restored
        if (isConnected) {
          _controller.future.then((controller) {
            controller.reload();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.future
            .then((controller) => controller.canGoBack())) {
          _controller.future.then((controller) => controller.goBack());
          return false; // Do not allow the app to be popped
        } else {
          return true; // Allow the app to be popped
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Flooring deals'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                // Reload the webview
                _controller.future.then((controller) {
                  controller.reload();
                });
              },
            ),
          ],
        ),
        body: isConnected
            ? WebView(
          initialUrl: 'https://flooringdeals.io/',
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          javascriptMode: JavascriptMode.unrestricted,
          gestureNavigationEnabled: true,
        )
            : Center(
          child: Text(
            'No internet connection. Please check your connection and try again.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
