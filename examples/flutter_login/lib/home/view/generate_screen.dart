import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:winhome/home/model/qrcode.dart';

import '../home.dart';

class GenerateScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GenerateScreenState();
}

class GenerateScreenState extends State<GenerateScreen> {
  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;

  GlobalKey globalKey = GlobalKey();
  String _dataString = 'Hello from this QR';
  String _inputErrorText = '';
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text('QR Code Generator'),
          // actions: <Widget>[
          //   IconButton(
          //     icon: const Icon(Icons.share),
          //     onPressed: _captureAndSharePng,
          //   )
          // ],
          ),
      body: _contentWidget(),
    );
  }

  Future sleep1() {
    return Future<int>.delayed(const Duration(milliseconds: 50), () => 1);
  }

  Future<void> _captureAndSharePng() async {
    var tempDir = await getDownloadsDirectory();
    tempDir ??= await getTemporaryDirectory();
    if (Platform.isMacOS) {
      tempDir = await getTemporaryDirectory();
    }

    setState(() {
      _inputErrorText = '${tempDir!.path}';
    });

    for (var item in dashboardStore.items) {
      var winhome = WinhomeQRCode(item.account, item.password,
          dashboardStore.ip, dashboardStore.sipPrefix);
      setState(() {
        _dataString = winhome.toString();
        // _inputErrorText = '';
      });

      logger.d(_dataString);
      await sleep1();

      try {
        var boundary = globalKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary?;
        var image = await boundary!.toImage();
        var byteData = await image.toByteData(format: ImageByteFormat.png);
        var pngBytes = byteData!.buffer.asUint8List();

        final file = await File('${tempDir.path}/${item.account}.png').create();
        await file.writeAsBytes(pngBytes);

        // logger.d('qrcode png path = ${file.path}');

        // final channel = const MethodChannel('channel:me.alfian.share/share');
        // await channel.invokeMethod('shareFile', 'image.png');
      } catch (e) {
        print(e.toString());
      }
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('完成！')));
  }

  Widget _contentWidget() {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: _topSectionTopPadding,
              left: 20.0,
              right: 10.0,
              bottom: _topSectionBottomPadding,
            ),
            child: Container(
              height: _topSectionHeight,
              child: Column(
                children: [
                  InkWell(
                    onTap: _captureAndSharePng,
                    child: const Text('產生QRCode'),
                  ),
                  InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _inputErrorText));
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('路徑複製成功！')));
                      },
                      child: Text('路徑:$_inputErrorText'))
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: globalKey,
                child: QrImage(
                  data: _dataString,
                  size: 0.5 * bodyHeight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
