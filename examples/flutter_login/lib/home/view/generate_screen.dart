import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imageExt;
// import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:winhome/home/model/qrcode.dart';
import 'package:winhome/utils/utils.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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

    await Directory('${tempDir.path}/${dashboardStore.sipPrefix}').create();

    setState(() {
      _inputErrorText = '${tempDir!.path}/${dashboardStore.sipPrefix}';
    });

    for (var item in dashboardStore.items) {
      if (item.ty != '7' && item.ty != '8') {
        continue;
      }
      var winhome = WinhomeQRCode(
        item.account,
        item.password,
        dashboardStore.ip,
        dashboardStore.sipPrefix,
        dashboardStore.sipAdmin,
        dashboardStore.sipMainDoor,
        dashboardStore.sipSmallDoor,
        dashboardStore.sipEm,
      );
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
        var splits = item.ro.split('-');
        var fileName = splits[1] + splits[2] + splits[3] + splits[4];
        var filePath = '${tempDir.path}/$fileName.png';
        final file = await File(filePath).create();
        await file.writeAsBytes(pngBytes);

        final png = imageExt.decodeImage(File(filePath).readAsBytesSync())!;
        var filePathJpg =
            '${tempDir.path}/${dashboardStore.sipPrefix}/$fileName.jpg';
        File(filePathJpg).writeAsBytesSync(imageExt.encodeJpg(png));
        await file.delete();
      } catch (e) {
        print(e.toString());
      }
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('完成!')));
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
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
