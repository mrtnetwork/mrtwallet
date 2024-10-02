import 'package:example/app_kit_view.dart';
import 'package:flutter/material.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/platform_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlatformInterface.instance.desktop.init();
  await PlatformInterface.instance.desktop
      .setMaximumSize(const WidgetSize(width: 1024, height: 768));
  await PlatformInterface.instance.desktop
      .setMinimumSize(const WidgetSize(width: 300, height: 500));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WebViewListener {
  bool init = false;
  final controller = PlatformInterface.webViewController;
  MRTAndroidViewController? ca;
  void initWebView() async {
    await controller.init("jafar",
        url: "https://google.com", jsInterface: "MRT");
    ca = await MRTAndroidViewController.create(viewType: "jafar");
    init = true;
    setState(() {});
  }

  @override
  void onPageProgress(WebViewEvent event) {
    print("onPageProgress ${event.progress}");
  }

  @override
  void onPageFinished(WebViewEvent event) {
    print("onPageFinished ${event.url}");
  }

  @override
  void onPageStart(WebViewEvent event) {
    print("onPageStart ${event.url}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                PlatformInterface.instance.share(Share.text("jafar aghas"));
              },
              icon: const Icon(Icons.abc)),
          TextButton(
              onPressed: () {
                initWebView();
              },
              child: Text("init")),
          TextButton(
              onPressed: () {
                init = false;
                setState(() {});
              },
              child: Text("change")),
          TextButton(
              onPressed: () {
                ca?.dispose();
                controller.dispose("jafar");
                print("ca $ca");
              },
              child: Text("dispose")),
        ],
      ),
      body: Container(
        color: Colors.red,
        child: Container(),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  String? get viewType => "jafar";
}
