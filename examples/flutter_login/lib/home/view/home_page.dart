import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path/path.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:winhome/authentication/authentication.dart';
import 'package:winhome/home/mobx/dashboard_store.dart';
import 'package:winhome/home/model/qrcode.dart';
import 'package:winhome/home/model/util.dart';
import 'package:xml/xml.dart';

final dashboardStore = DashboardStore();

class HomePage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => HomePage());
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<Database> database;

  @override
  void initState() {
    // Avoid errors caused by flutter upgrade.
    WidgetsFlutterBinding.ensureInitialized();
    loadData();
    super.initState();
  }

  void loadData() async {
    // Open the database and store the reference.
    database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'wh13_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          // ignore: lines_longer_than_80_chars
          'CREATE TABLE items(id INTEGER PRIMARY KEY, ty TEXT, ro TEXT, alias TEXT, ip TEXT, account TEXT, password TEXT, enable TEXT, create_time INTEGER, end_time INTEGER)',
        );
      },

      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );

    var items = await whItems();
    for (var item in items) {
      dashboardStore.items.add(item);
    }
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
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        minTime: DateTime.now(),
                        // maxTime: DateTime(2019, 6, 7),
                        theme: const DatePickerTheme(
                          headerColor: Colors.orange,
                          backgroundColor: Colors.blue,
                          itemStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                          doneStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ), onConfirm: (date) {
                      dashboardStore.markDirty();
                      item.setEndTime(date);
                    }, currentTime: DateTime.now(), locale: LocaleType.tw);
                  },
                  child: Text(
                    '結束時間：${item.endTimeStr}',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            Card(
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  item.check(!item.checked);
                  dashboardStore.markDirty();
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
                  _showMyDialog(context, item.account, item.password,
                      '210.68.245.165:54345', dashboardStore.sipPrefix);
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

  Future<void> _showMyDialog(BuildContext context, String name, String password,
      String proxy, String prefix) async {
    var qrcode = WinhomeQRCode(name, password, proxy, prefix);

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
                data: qrcode.toString(),
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

  void _editPrefix(BuildContext context) async {
    var prefix = await prompt(context);
    if (prefix != null) {
      dashboardStore.changePrefix(prefix);
    }
  }

  void _changePassword(BuildContext context) async {
    var newPassword = await prompt(context);
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
      sink.write('${dashboardStore.sipPrefix}${element.encode}\n');
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
      var ty4 = newlist.where((dev) => (dev.getAttribute('ty') == '7'));
      var i = 0;
      var today = DateTime.now();
      var end = today.add(const Duration(days: 365));
      for (var element in ty4) {
        var whItem = ListItemStore()
          ..id = i++
          ..ty = '7'
          ..ro = element.getAttribute('ro') as String
          ..title = element.getAttribute('alias') as String
          ..ip = element.getAttribute('ip') as String
          ..checked = true
          ..account = _roToAcc(element.getAttribute('ro') as String)
          ..password = Util.genPw()
          ..createTime = today.millisecondsSinceEpoch
          ..endTime = end.millisecondsSinceEpoch;

        // print(whItem);
        dashboardStore.items.add(whItem);
        // ignore: unawaited_futures
        insertWHItem(whItem);
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

  // A method that retrieves all the dogs from the dogs table.
  // Future<List<WHItem>> whItems() async {
  Future<List<ListItemStore>> whItems() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('items');

    return List.generate(maps.length, (i) {
      return ListItemStore()
        ..id = maps[i]['id'] as int
        ..ip = maps[i]['ip'] as String
        ..ro = maps[i]['ro'] as String
        ..ty = maps[i]['ty'] as String
        ..checked = maps[i]['enable'] as String == 'true'
        ..title = maps[i]['alias'] as String
        ..subTitle = maps[i]['alias'] as String
        ..account = maps[i]['account'] as String
        ..password = maps[i]['password'] as String
        ..createTime = maps[i]['create_time'] as int
        ..endTime = maps[i]['end_time'] as int;
    });
  }

  // Define a function that inserts WHItems into the database
  Future<void> insertWHItem(ListItemStore item) async {
    // Get a reference to the database.
    final db = await database;

    // Insert the WHItem into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateWHItem(ListItemStore item) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given WHItem.
    await db.update(
      'items',
      item.toMap(),
      // Ensure that the WHItem has a matching id.
      where: 'id = ?',
      // Pass the WHItem's id as a whereArg to prevent SQL injection.
      whereArgs: [item.id],
    );
  }

  Future<void> deleteWHItem(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
      'items',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<void> saveAllWHItems() async {
    for (var item in dashboardStore.items) {
      await updateWHItem(item);
    }
  }
}
