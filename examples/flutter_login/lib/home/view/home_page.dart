import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/home/mobx/dashboard_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:xml/xml.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final dashboardStore = DashboardStore();

class HomePage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarBuilder(context),
      body: Observer(
        builder: _listViewBuilder,
      ),
    );
  }

  AppBar _appBarBuilder(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const RotatedBox(
          quarterTurns: 2,
          child: Icon(
            Icons.logout,
            color: Colors.white,
            size: 36.0,
          ),
        ),
        tooltip: '登出',
        onPressed: () async {
          context
              .read<AuthenticationBloc>()
              .add(AuthenticationLogoutRequested());
        },
      ),
      title: Builder(
        builder: (context) {
          final userName = context.select(
            (AuthenticationBloc bloc) => bloc.state.user.name,
          );
          return Text('$userName');
        },
      ),
      actions: [
        IconButton(
          // icon: Image.asset('assets/images/folder.png'),
          icon: const Icon(Icons.read_more),
          tooltip: '讀取Addressbook',
          onPressed: () async {
            _loadAddressBookPressed(context);
          },
        ),
        IconButton(
          // icon: Image.asset('assets/images/folder.png'),
          icon: const Icon(Icons.check),
          tooltip: '產生user.db',
          onPressed: () async {
            _genUserDB(context);
          },
        ),
      ],
    );
  }

  ListView _listViewBuilder(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: dashboardStore.items.length,
      itemBuilder: (context, index) {
        final item = dashboardStore.items[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Observer(
            builder: (BuildContext context) {
              return _listViewSub(item, context);
            },
          ),
          // title: item.buildTitle(context),
          // subtitle: item.buildSubtitle(context),
        );
      },
    );
  }

  Widget _listViewSub(ListItemStore item, BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.account),
            // Container(width: 20, height: 20),
            Text(item.password),
            // const Spacer(),
            Card(
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  item.check(!item.checked);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: item.checked == true
                      ? const Text('啟用')
                      : const Text('暫停'),
                ),
              ),
            ),
            // const Spacer(),
            Card(
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  item.reset();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('重置密碼'),
                ),
              ),
            ),
            // const Spacer(),
            Card(
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _showMyDialog(context, item.encode);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('顯示QR碼'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context, String msg) async {
    var jsonText = jsonEncode(qrCode);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('請打開app掃描'),
          content: Container(
            width: 280,
            height: 280,
            child: Center(
              child: QrImage(
                data: jsonText,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('關閉'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//100023@210.68.245.165 clrtxt:123a ;
  void _genUserDB(BuildContext context) async {
    var file = File('file.txt');
    var sink = file.openWrite();
    // sink.write('FILE ACCESSED ${DateTime.now()}\n');

    for (var element in dashboardStore.items) {
      //print(element);
      sink.write('${element.encode}\n');
    }

    // Close the IOSink to free system resources.
    sink.close();

    print(file.absolute);
  }

  void _loadAddressBookPressed(BuildContext context) async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'xml',
      ],
    );

    if (result != null) {
      dashboardStore.items.clear();
      XmlDocument document;
      if (kIsWeb) {
        // running on the web!
        var bar = utf8.decode(result.files.single.bytes!);
        print(bar);
        document = XmlDocument.parse(bar);
      } else {
        // NOT running on the web! You can check for additional platforms here.
        var file = File(result.files.single.path!);
        document = XmlDocument.parse(file.readAsStringSync());
      }
      // final addrlist = document.getElement("AddrList");
      final devs = document.findAllElements('dev');
      var newlist = devs.toList()
        ..sort(
            (a, b) => a.getAttribute('ro')!.compareTo(b.getAttribute('ro')!));
      // print(devs.toString());
      var ty4 = newlist.where((dev) => (dev.getAttribute('ty') == '7'));
      for (var element in ty4) {
        print(element); //alias
        var alias = element.getAttribute('alias') as String;
        var ro = element.getAttribute('ro') as String;
        final listItemStore = ListItemStore()
          ..account = _roToAcc(ro)
          ..title = alias
          ..subTitle = _roToAcc(ro);
        dashboardStore.items.add(listItemStore);
      }
      // print(document.toXmlString(pretty: true, indent: '\t'));
    } else {
      // User canceled the picker
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('讀取Addressbook')));
  }

  String _roToAcc(String ro) {
    var arr = ro.split('-'); //var one = int.parse('1');
    var addr1 = '';
    if (arr[1] == '00') {
      addr1 = '0${arr[2]}';
    } else {
      addr1 = int.parse(arr[1]).toString() + arr[2];
    }
    var addr2 = arr[3];
    var addr3 = arr[4];
    return 'c$addr1$addr2$addr3';
  }

  var qrCode = {
    'name': '40',
    'password': '4000',
    'proxy': '210.68.245.165:54345',
    'transport': 'tls',
    'callOut': {'管理員': '2000'},
    'address': {'大門': '1111', '小門': '2000', '管理員': '3333'},
  };
}
