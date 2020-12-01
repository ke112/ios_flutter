import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(_MyApp()
//    MyApp(
//    window 需要导入import 'dart:ui';
//  window.defaultRouteName 拿到的就是 iOS中写的 [vc setInitialRoute:@"one"];带过来的值 one
//    pageIndex: window.defaultRouteName
//    )
);

// ----------------------------------------
class _MyApp extends StatefulWidget {
  @override
  __MyAppState createState() => __MyAppState();
}

class __MyAppState extends State<_MyApp> {
  String pageIndex = 'one';
  var _argu = {};

//  这里是解码器，互相调用
  final MethodChannel _oneChannel = MethodChannel('one_page');
  final MethodChannel _twoChannel = MethodChannel('two_page');
//  这个是通讯，也需要一个解码器
  final BasicMessageChannel _messageChannel =
  BasicMessageChannel('messageChannel', StandardMessageCodec());

  //声明一个输入框控制器
  TextEditingController _controller;
  //用于获取输入框的文字
  String inpuText;

  @override
  void initState() {
//    可以持续接收信息
    _messageChannel.setMessageHandler((message) {
      print('flutter收到了来自iOS的传值: $message');
      return null;
    });

    // 调用方法一次接收信息
    _oneChannel.setMethodCallHandler((call) {
      setState(() {
        pageIndex = call.method;
        _argu = call.arguments;
        print('argu111:' + _argu["t"]);
        _controller = new TextEditingController(text: _argu["t"]);
      });
      return null;
    });

    _twoChannel.setMethodCallHandler((call) {
      setState(() {
        pageIndex = call.method;
      });
      return null;
    });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'android title',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: rootPage(pageIndex),
      debugShowCheckedModeBanner: false ,
    );
  }

  rootPage(String pageIndex) {
    switch (pageIndex) {
      case 'one':
        return Scaffold(
            appBar: AppBar(title: Text(pageIndex)),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    _messageChannel.send(inpuText);
                    // 直接退出页面了，一般不会这么做。
                    // 触摸收起键盘
                    FocusScope.of(context).requestFocus(FocusNode());
                    MethodChannel('one_page').invokeMapMethod('exit');
                  },
                  child: Text(pageIndex),
                ),
                TextField(
                  controller: _controller,
                  // 输入框写数据，向iOS发送数据
                  onChanged: (String str) {
                    this.inpuText = str;
                    // _messageChannel.send(str);
                  },
                )
              ],
            ));

      case 'two':
        return Scaffold(
          appBar: AppBar(title: Text(pageIndex)),
          body: Center(
              child: RaisedButton(
                onPressed: () {
                  MethodChannel('two_page').invokeMapMethod('exit');
                },
                child: Text(pageIndex),
              )),
        );
    }
  }
}