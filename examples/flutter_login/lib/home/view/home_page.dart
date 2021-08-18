import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/home/mobx/dashboard_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:xml/xml.dart';

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
          icon: const Icon(Icons.document_scanner),
          tooltip: '讀取Addressbook',
          onPressed: () async {
            _onSearchButtonPressed(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.qr_code),
          tooltip: '產生QRCode',
          onPressed: () async {
            _onSearchButtonPressed(context);
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
              return _listViewSub(item);
            },
          ),
          // title: item.buildTitle(context),
          // subtitle: item.buildSubtitle(context),
        );
      },
    );
  }

  Widget _listViewSub(ListItemStore item) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(item.subTitle),
            Card(
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  print('onpressd $item');
                  item.check(!item.checked);
                },
                // child: item.checked == true ? Text('啟用') : Text('暫停'),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: item.checked == true
                      ? const Text('啟用')
                      : const Text('暫停'),
                ),
              ),
            ),
            Card(
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {},
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('設定'),
                ),
              ),
            ),
            Card(
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {},
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

  void _onSearchButtonPressed(BuildContext context) async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'xml',
      ],
    );

    if (result != null) {
      dashboardStore.items.clear();
      var file = File(result.files.single.path!);
      // print(result.files.single.path!);
      final document = XmlDocument.parse(file.readAsStringSync());
      // final addrlist = document.getElement("AddrList");
      final devs = document.findAllElements('dev');
      var newlist = devs.toList()
        ..sort(
            (a, b) => a.getAttribute('ro')!.compareTo(b.getAttribute('ro')!));
      // print(devs.toString());
      var ty4 = newlist.where((dev) => (dev.getAttribute('ty') != '1' &&
          dev.getAttribute('ty') != '4' &&
          dev.getAttribute('ty') != '6'));
      for (var element in ty4) {
        print(element); //alias
        print(element.getAttribute('ro'));
        print(element.getAttribute('alias'));
        // element.getAttribute('alias')
        var alias = element.getAttribute('alias') as String;
        var ro = element.getAttribute('ro') as String;
        final listItemStore = ListItemStore()
          ..title = alias
          ..subTitle = ro;
        dashboardStore.items.add(listItemStore);
      }
      // print(document.toXmlString(pretty: true, indent: '\t'));
    } else {
      // User canceled the picker
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('讀取Addressbook')));
  }
}
