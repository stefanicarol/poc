import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.camera.request();
  await Permission.microphone.request();


 if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
          AndroidServiceWorkerController.instance();

      serviceWorkerController.serviceWorkerClient = AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      );
    }
  }






  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ClassVirtualPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class ClassVirtualPage extends StatefulWidget {
  final String title;

  const ClassVirtualPage({Key? key, this.title = 'Aula Virtual'})
      : super(key: key);

  @override
  _ClassVirtualPageState createState() => _ClassVirtualPageState();
}

class _ClassVirtualPageState extends State<ClassVirtualPage> {
  final _url = Uri.https('salavirtual.sifcon.com.br', '');
  double _progress = 0;
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(color: Color(0xFF253858))),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF253858)),
      ),
      body: InAppWebView(
          initialUrlRequest: URLRequest(url: _url),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              verticalScrollBarEnabled: false,
              mediaPlaybackRequiresUserGesture: false,
              javaScriptEnabled: true,
            ),
          ),
          onWebViewCreated: (InAppWebViewController controller) async {
            _webViewController = controller;
          },
          onLoadStop: (InAppWebViewController controller, Uri? url) async {
            await controller
                .evaluateJavascript(source: """                        
                     document.getElementsByClassName("header")[0].style.display = 'none';                          
                     document.getElementById("idbody").style="padding-top: 0px";   
                     """);
            await Future.delayed(Duration(seconds: 1));
            _webViewController!.evaluateJavascript(source: """  
                     let description = document.querySelector("._md");
                     let schedule = document.querySelector(".flex-gt-sm-40");
                     let reverse = schedule.parentNode;
                     reverse.insertBefore(description,schedule[0]);
                      """);
          },
          onProgressChanged: (InAppWebViewController controller, int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          androidOnPermissionRequest: (InAppWebViewController controller,
              String origin, List<String> resources) async {
            return PermissionRequestResponse(
              resources: resources,
              action: PermissionRequestResponseAction.GRANT,
            );
          }),
    );
  }
}
