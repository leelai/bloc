import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:ini/ini.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:winhome/authentication/authentication.dart';
import 'package:winhome/home/mobx/dashboard_store.dart';
import 'package:winhome/home/model/qrcode.dart';
import 'package:winhome/home/model/util.dart';
import 'package:winhome/main.dart';
import 'package:xml/xml.dart';

final dashboardStore = DashboardStore();

final addressbookini = 'addressbook.ini';

const fontSize = 18.0;
const enableColor = Color(0xFF73ACCE);
const disableColor = Color(0xFF9E9E9E);
const enableButtonTextColor = Color(0xFF73ACCE);
const disableButtonTextColor = Color(0xFF9E9E9E);

var logger = Logger(
  printer: PrettyPrinter(),
);

class HomePage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => HomePage());
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<Database> database;
  // var myDB = AppDatabase();

  @override
  void initState() {
    // Avoid errors caused by flutter upgrade.
    WidgetsFlutterBinding.ensureInitialized();
    loadData();
    super.initState();
  }

  void loadData() async {
    var dir = (await getApplicationDocumentsDirectory()).path;
    var configFile = '$dir/$addressbookini';

    var directoryExists = await Directory(configFile).exists();
    var fileExists = await File(configFile).exists();

    if (directoryExists || fileExists) {
      var config = await File(configFile)
          .readAsLines()
          .then((lines) => Config.fromStrings(lines));

      var sections = config.sections();
      var i = 0;
      for (var section in sections) {
        //logger.d(section);
        var whItem = ListItemStore()
          ..id = i++
          ..ty = config.get(section, 'ty')!
          ..ro = config.get(section, 'ro')!
          ..title = config.get(section, 'alias')!
          ..ip = config.get(section, 'ip')!
          ..enabled = config.get(section, 'enable')! == 'true'
          ..account = config.get(section, 'account')!
          ..password = config.get(section, 'password')!
          ..createTime = int.parse(config.get(section, 'createTime')!)
          ..endTime = int.parse(config.get(section, 'expiredTime')!);

        dashboardStore.items.add(whItem);
      }
    }

    var sipPrefix = await getSipPrefix();
    dashboardStore.changePrefix(sipPrefix);
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
      title: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          return Text(state.user.name);
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
          icon: const Icon(Icons.edit),
          tooltip: '編輯案場編號',
          onPressed: () async {
            _editPrefix(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.computer),
          tooltip: '編輯案場ip',
          onPressed: () async {
            _editIp(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.check),
          tooltip: '產生user.db',
          onPressed: () async {
            _genUserDB(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.password),
          tooltip: '修改密碼',
          onPressed: () async {
            _changePassword(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.voice_chat),
          tooltip: 'cmd',
          onPressed: () async {
            _editRestartCmd(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.voice_over_off),
          tooltip: '重新啟動週期',
          onPressed: () async {
            _editSchedule(context);
          },
        ),
        Observer(
          builder: (context) {
            return Visibility(
              child: IconButton(
                icon: const Icon(Icons.money),
                tooltip: '修改設定',
                onPressed: () async {
                  //_changePassword(context);
                  await saveAllWHItems();
                  dashboardStore.resetDirty();
                },
              ),
              visible: dashboardStore.dirty,
            );
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
          title: Text(
            item.title,
            style: const TextStyle(fontSize: fontSize),
          ),
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
      color: item.isValid ? enableColor : disableColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('帳號：${item.account}'),
                Text('密碼：${item.password}'),
              ],
            ),
            Column(
              children: [
                Text('建立時間：${item.createTimeStr}'),
                InkWell(
                  onTap: () {
                    DatePicker.showDatePicker(
                      context,
                      // showTitleActions: true,
                      minTime: DateTime.now(),
                      // maxTime: DateTime(2019, 6, 7),
                      // theme: const DatePickerTheme(
                      //   headerColor: Colors.orange,
                      //   backgroundColor: Colors.blue,
                      //   itemStyle: TextStyle(
                      //     color: Colors.white,
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 30,
                      //   ),
                      //   doneStyle: TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 16,
                      //   ),
                      // ),
                      onConfirm: (date) {
                        dashboardStore.markDirty();
                        item.setEndTime(date);
                      },
                      currentTime: DateTime.now(),
                      locale: LocaleType.en,
                    );
                  },
                  child: Text(
                    '結束時間：${item.endTimeStr}',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: item.isExpired
                          ? const Color(0xFFC74A4A)
                          : const Color(0xFF464646),
                    ),
                  ),
                ),
              ],
            ),
            Card(
              child: TextButton(
                onPressed: () {
                  item.enable(!item.enabled);
                  dashboardStore.markDirty();
                },
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: item.enabled
                        ? const Text(
                            '暫停',
                            style: TextStyle(color: enableButtonTextColor),
                          )
                        : const Text(
                            '啟用',
                            style: TextStyle(color: enableButtonTextColor),
                          )),
              ),
            ),
            // const Spacer(),
            Card(
              child: TextButton(
                onPressed: () {
                  if (item.enabled) {
                    item.reset();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '重置密碼',
                    style: TextStyle(
                        color: item.isValid
                            ? enableButtonTextColor
                            : disableButtonTextColor),
                  ),
                ),
              ),
            ),
            // const Spacer(),
            Card(
              child: TextButton(
                onPressed: () {
                  if (item.isValid) {
                    _showMyDialog(context, item.account, item.password,
                        '210.68.245.165:54345', dashboardStore.sipPrefix);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '顯示QR碼',
                    style: TextStyle(
                        color: item.isValid
                            ? enableButtonTextColor
                            : disableButtonTextColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context, String name, String password,
      String proxy, String prefix) async {
    var qrcode = WinhomeQRCode(name, password, proxy, prefix);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '請打開app掃描',
            style: TextStyle(fontSize: fontSize),
          ),
          content: Container(
            width: 280,
            height: 280,
            child: Center(
              child: QrImage(
                data: qrcode.toString(),
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                '關閉',
                style: TextStyle(fontSize: fontSize),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editPrefix(BuildContext context) async {
    var origin = await getSipPrefix();
    var sipPrefix = await prompt(
      context,
      title: const Text('請輸入案場編號'),
      initialValue: origin,
    );
    if (sipPrefix != null) {
      dashboardStore.changePrefix(sipPrefix);

      var prefs = await SharedPreferences.getInstance();
      await prefs.setString('sipPrefix', sipPrefix);
    }
  }

  void _editIp(BuildContext context) async {
    var origin = await getIp();
    var ip = await prompt(
      context,
      title: const Text('請輸入案場ip'),
      initialValue: origin,
    );
    if (ip != null) {
      dashboardStore.setIp(ip);

      var prefs = await SharedPreferences.getInstance();
      await prefs.setString('ip', ip);
    }
  }

  void _editRestartCmd(BuildContext context) async {
    var origin = await getRestartCmd();
    var cmd = await prompt(
      context,
      title: const Text('請輸入指令'),
      initialValue: origin,
    );
    if (cmd != null) {
      var prefs = await SharedPreferences.getInstance();
      await prefs.setString('restartCmd', cmd);
    }
  }

  void _editSchedule(BuildContext context) async {
    var origin = await getSchedule();
    var schedule = await prompt(
      context,
      title: const Text('請輸入重新啟動週期'),
      initialValue: origin,
    );
    if (schedule != null) {
      var prefs = await SharedPreferences.getInstance();
      await prefs.setString('schedule', schedule);
    }
  }

  void _changePassword(BuildContext context) async {
    var newPassword = await prompt(
      context,
      title: const Text('修改密碼'),
    );
    if (newPassword != null) {
      context
          .read<AuthenticationBloc>()
          .add(AuthenticationPasswordChangeRequested(newPassword));
    }
  }

  void _genUserDB(BuildContext context) async {
    var file = File('user.db');
    var sink = file.openWrite()..write('version:1\n');

    for (var element in dashboardStore.items) {
      //print(element);
      if (element.isValid) {
        sink.write('${dashboardStore.sipPrefix}${element.encode}\n');
      }
    }

    // Close the IOSink to free system resources.
    await sink.close();

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
        var file = File(result.files.single.path.toString());
        document = XmlDocument.parse(file.readAsStringSync());
      }
      // final addrlist = document.getElement("AddrList");
      final devs = document.findAllElements('dev');
      var newlist = devs.toList()
        ..sort(
            (a, b) => a.getAttribute('ro')!.compareTo(b.getAttribute('ro')!));
      // print(devs.toString());
      var ty7 = newlist.where((dev) => (dev.getAttribute('ty') == '7'));
      var i = 0;
      var today = DateTime.now();
      var end = today.add(const Duration(days: 365));

      var dir = (await getApplicationDocumentsDirectory()).path;
      var configFile = '$dir/$addressbookini';

      var directoryExists = await Directory(configFile).exists();
      var fileExists = await File(configFile).exists();

      var config = Config();
      if (directoryExists || fileExists) {
        var file = File(configFile);
        await file.delete();
      }
      //   new File("config.ini").readAsLines()
      // .then((lines) => new Config.fromStrings(lines))
      // .then((Config config) => ...);

      // var myDB = AppDatabase();
      for (var element in ty7) {
        var whItem = ListItemStore()
          ..id = i++
          ..ty = '7'
          ..ro = element.getAttribute('ro') as String
          ..title = element.getAttribute('alias') as String
          ..ip = element.getAttribute('ip') as String
          ..enabled = true
          ..account = _roToAcc(element.getAttribute('ro') as String)
          ..password = Util.genPw()
          ..createTime = today.millisecondsSinceEpoch
          ..endTime = end.millisecondsSinceEpoch;

        dashboardStore.items.add(whItem);
        // ignore: unawaited_futures
        // insertWHItem(whItem);

        // await myDB.insertAddressItem(_foo(whItem));
        config
          ..addSection(whItem.ro)
          ..set(whItem.ro, 'ty', whItem.ty)
          ..set(whItem.ro, 'alias', whItem.title)
          ..set(whItem.ro, 'ro', whItem.ro)
          ..set(whItem.ro, 'ip', whItem.ip)
          ..set(whItem.ro, 'enable', whItem.enabled.toString())
          ..set(whItem.ro, 'account', whItem.account)
          ..set(whItem.ro, 'password', whItem.password)
          ..set(whItem.ro, 'createTime', whItem.createTime.toString())
          ..set(whItem.ro, 'expiredTime', whItem.endTime.toString());
      }
      var file = File(configFile);
      await file.writeAsString(config.toString());

      logger.d(configFile);
      // logger.d(config.toString());
      // print(document.toXmlString(pretty: true, indent: '\t'));
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('讀取Addressbook')));
  }

  // AddressItem _foo(ListItemStore storeItem) {
  //   return AddressItem(
  //     id: storeItem.id,
  //     ty: storeItem.ty,
  //     ro: storeItem.ro,
  //     alias: storeItem.title,
  //     ip: storeItem.ip,
  //     account: storeItem.account,
  //     password: storeItem.password,
  //     enable: storeItem.checked,
  //     createDate: DateTime.fromMillisecondsSinceEpoch(storeItem.createTime),
  //     expiredDate: DateTime.fromMillisecondsSinceEpoch(storeItem.endTime),
  //   );
  // }

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

  Future<void> saveAllWHItems() async {
    var config = Config();
    for (var item in dashboardStore.items) {
      config
        ..addSection(item.ro)
        ..set(item.ro, 'ty', item.ty)
        ..set(item.ro, 'alias', item.title)
        ..set(item.ro, 'ip', item.ip)
        ..set(item.ro, 'ro', item.ro)
        ..set(item.ro, 'enable', item.enabled.toString())
        ..set(item.ro, 'account', item.account)
        ..set(item.ro, 'password', item.password)
        ..set(item.ro, 'createTime', item.createTime.toString())
        ..set(item.ro, 'expiredTime', item.endTime.toString());
    }

    var dir = (await getApplicationDocumentsDirectory()).path;
    var configFile = '$dir/$addressbookini';

    var directoryExists = await Directory(configFile).exists();
    var fileExists = await File(configFile).exists();

    if (directoryExists || fileExists) {
      var file = File(configFile);
      await file.delete();
    }

    var file = File(configFile);
    await file.writeAsString(config.toString());
  }
}
