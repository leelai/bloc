import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:ini/ini.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart' hide prompt;
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:winhome/authentication/authentication.dart';
import 'package:winhome/home/mobx/dashboard_store.dart';
import 'package:winhome/home/model/qrcode.dart';
import 'package:winhome/home/view/add_sip_address.dart';
import 'package:winhome/main.dart';
import 'package:winhome/utils/utils.dart';
import 'package:xml/xml.dart';

import 'generate_screen.dart';

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

var config = Config();

class _HomePageState extends State<HomePage> {
  late final Future<Database> database;
  // var myDB = AppDatabase();
  // var config = Config();

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

    var directoryExists = await Directory(dir).exists();
    var fileExists = await File(configFile).exists();

    if (!directoryExists || !fileExists) {
      return;
    }

    //load config
    config = await File(configFile)
        .readAsLines()
        .then((lines) => Config.fromStrings(lines));

    //list all sections
    var sections = config.sections();
    var i = 0;
    dashboardStore.items.clear();
    for (var section in sections) {
      //skip system section
      if (section == 'system') {
        continue;
      }

      //winhome item
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

      if (whItem.ty == '1') {
        //小門
        dashboardStore.sipSmallDoor = whItem.account;
      } else if (whItem.ty == '4') {
        //大門
        dashboardStore.sipMainDoor = whItem.account;
      } else if (whItem.ty == '9') {
        //緊急
        dashboardStore.sipEm = whItem.account;
      } else if (whItem.ty == '6') {
        //管理
        dashboardStore.sipAdmin = whItem.account;
      } else {
        //手機
        dashboardStore.items.add(whItem);
      }

      if (i >= dashboardStore.size) {
        break;
      }
    }

    //ip
    var ip = config.get('system', 'ip');
    if (ip != null) {
      dashboardStore.setIp(ip);
    }

    //sipPrefix
    var sipPrefix = config.get('system', 'sipPrefix');
    if (sipPrefix != null) {
      dashboardStore.changePrefix(sipPrefix);
    }

    var size = config.get('system', 'size');
    if (size != null) {
      dashboardStore.setSize(int.parse(size));
    } else {
      dashboardStore.setSize(800);
    }

    // var sipAdmin = config.get('system', 'sipAdmin');
    // if (sipAdmin != null) {
    //   dashboardStore.setSipAdmin(sipAdmin);
    // }

    // var sipMainDoor = config.get('system', 'sipMainDoor');
    // if (sipMainDoor != null) {
    //   dashboardStore.setSipMainDoor(sipMainDoor);
    // }

    // var sipSmallDoor = config.get('system', 'sipSmallDoor');
    // if (sipSmallDoor != null) {
    //   dashboardStore.setSipSmallDoor(sipSmallDoor);
    // }
  }

  void backup() async {
    var dir = (await getApplicationDocumentsDirectory()).path;
    var configFile = '$dir/$addressbookini';
    logger.d('backup $configFile');
    var fileExists = await File(configFile).exists();

    if (!fileExists) {
      return;
    }
    var newDir = (await getDownloadsDirectory())!.path;
    if (Platform.isMacOS) {
      newDir = (await getTemporaryDirectory()).path;
    }
    var newFile = '$newDir/$addressbookini';
    logger.d('copy config to $newFile');
    var config = File(configFile);
    try {
      await config.copy(newFile);
    } on Exception catch (err) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('備份失敗!\n$err')));
      return;
    }

    await Clipboard.setData(ClipboardData(text: newFile));

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('備份成功!\n$newFile')));
  }

  void restore() async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'ini',
      ],
    );

    if (result == null) {
      return;
    }

    var dir = (await getApplicationDocumentsDirectory()).path;
    var configFile = '$dir/$addressbookini';

    var file = File(result.files.single.path.toString());

    try {
      await file.copy(configFile);
    } on Exception catch (err) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('還原失敗!\n$err')));
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('還原成功!')));

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    // title: BlocBuilder<AuthenticationBloc, AuthenticationState>(
    //   builder: (context, state) {
    //     return Text(state.user.name);
    //   },
    // ),
    return Scaffold(
        appBar: _appBarBuilder(context),
        body: Observer(
          builder: _listViewBuilder,
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<MaterialPageRoute>(
                  builder: (context) => const AddSipAddress()),
            );
          },
        ));
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
      title: const Text('Winhome'),
      actions: [
        BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return Visibility(
              visible: state.user.name == '經銷商',
              child: InkWell(
                onTap: () {
                  _changeVolume(context);
                },
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Observer(
                    builder: (BuildContext context) {
                      return Text(dashboardStore.size.toString());
                    },
                  ),
                )),
              ),
            );
          },
        ),
        BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return Visibility(
              visible: state.user.name == '經銷商',
              child: IconButton(
                icon: const Icon(Icons.read_more),
                tooltip: '讀取Addressbook',
                onPressed: () async {
                  _loadAddressBookPressed(context);
                },
              ),
            );
          },
        ),
        BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return Visibility(
              visible: state.user.name == '經銷商',
              child: IconButton(
                icon: const Icon(Icons.edit),
                tooltip: '編輯案場編號',
                onPressed: () async {
                  _editPrefix(context);
                },
              ),
            );
          },
        ),
        BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return Visibility(
              visible: state.user.name == '經銷商',
              child: IconButton(
                icon: const Icon(Icons.computer),
                tooltip: '編輯案場ip:port',
                onPressed: () async {
                  _editIp(context);
                },
              ),
            );
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
          icon: const Icon(Icons.play_circle),
          tooltip: '啟動',
          onPressed: () async {
            await Shell()
                .run('systemctl start flexisip-proxy flexisip-presence');
          },
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          tooltip: '停止',
          onPressed: () async {
            await Shell()
                .run('systemctl stop flexisip-proxy flexisip-presence');
          },
        ),
        BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return Visibility(
              visible: state.user.name == '經銷商',
              child: IconButton(
                icon: const Icon(Icons.comment),
                tooltip: '重啟指令',
                onPressed: () async {
                  _editRestartCmd(context);
                },
              ),
            );
          },
        ),
        BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return Visibility(
              visible: state.user.name == '經銷商',
              child: IconButton(
                icon: const Icon(Icons.date_range),
                tooltip: '重新啟動週期',
                onPressed: () async {
                  _editSchedule(context);
                },
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.restart_alt),
          tooltip: '重啟server',
          onPressed: () {
            if (dashboardStore.dirty) {
              saveAllWHItems();
              dashboardStore.resetDirty();
            } else {
              _restartServer();
            }
          },
        ),
        Observer(
          builder: (context) {
            return Visibility(
              child: IconButton(
                icon: const Icon(Icons.save),
                tooltip: '儲存設定',
                onPressed: () {
                  saveAllWHItems();
                  dashboardStore.resetDirty();
                },
              ),
              visible: dashboardStore.dirty,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.backup),
          tooltip: '匯出',
          onPressed: () async {
            backup();
          },
        ),
        IconButton(
          icon: const Icon(Icons.restore),
          tooltip: '匯入',
          onPressed: () async {
            restore();
          },
        ),
        BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return Visibility(
              visible: state.user.name == '經銷商',
              child: IconButton(
                icon: const Icon(Icons.date_range),
                tooltip: '產生qr code',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<MaterialPageRoute>(
                        builder: (context) => GenerateScreen()),
                  );
                },
              ),
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
                if (!item.readOnly) Text('密碼：${item.password}'),
              ],
            ),
            if (!item.readOnly)
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
            BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
                return Visibility(
                  visible: !(item.readOnly || state.user.name == '保全人員'),
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        item.enable(!item.enabled);
                        dashboardStore.markDirty();
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: item.enabled
                              ? const Text('暫停')
                              : const Text('啟用')),
                    ),
                  ),
                );
              },
            ),
            // const Spacer(),
            BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
                return Visibility(
                  visible: !(item.readOnly || state.user.name == '保全人員'),
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        if (item.enabled) {
                          _resetPassword(item);
                          // item.reset();
                          // dashboardStore.markDirty();
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('重置密碼'),
                      ),
                    ),
                  ),
                );
              },
            ),
            // const Spacer(),
            BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
                return Visibility(
                  visible: !(item.readOnly || state.user.name == '保全人員'),
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        if (item.isValid) {
                          var ip = '${dashboardStore.ip}';
                          _showMyDialog(context, item.account, item.password,
                              ip, dashboardStore.sipPrefix);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '顯示QR碼',
                          // style: TextStyle(
                          //     color: item.isValid
                          //         ? enableButtonTextColor
                          //         : disableButtonTextColor),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context, String name, String password,
      String proxy, String prefix) async {
    var qrcode = WinhomeQRCode(
        name,
        password,
        proxy,
        prefix,
        dashboardStore.sipAdmin,
        dashboardStore.sipMainDoor,
        dashboardStore.sipSmallDoor,
        dashboardStore.sipEm);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'QRCode',
            // style: TextStyle(fontSize: fontSize),
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
            InkWell(
              child: const Text(
                '關閉',
                style: TextStyle(fontSize: fontSize),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editPrefix(BuildContext context) async {
    var origin = dashboardStore.sipPrefix;
    var sipPrefix = await prompt(
      context,
      title: Image.asset('assets/images/case_number.png'),
      initialValue: origin,
    );
    if (sipPrefix != null && sipPrefix != origin) {
      dashboardStore
        ..changePrefix(sipPrefix)
        ..markDirty();
    }
  }

  void _editIp(BuildContext context) async {
    var origin = dashboardStore.ip;
    var ip = await prompt(
      context,
      title: Image.asset('assets/images/proxy_address.png'),
      initialValue: origin,
    );
    if (ip != null && ip != origin) {
      dashboardStore
        ..setIp(ip)
        ..markDirty();
    }
  }

  // void _editPC(BuildContext context) async {
  //   var origin = dashboardStore.sipAdmin;
  //   var userInput = await prompt(
  //     context,
  //     title: Image.asset('assets/images/admin_sip_address.png'),
  //     initialValue: origin,
  //   );
  //   if (userInput != null && userInput != origin) {
  //     dashboardStore
  //       ..setSipAdmin(userInput)
  //       ..markDirty();
  //   }
  // }

  // void _editPC2(BuildContext context) async {
  //   var origin = dashboardStore.sipMainDoor;
  //   var userInput = await prompt(
  //     context,
  //     title: Image.asset('assets/images/door_sip_address.png'),
  //     initialValue: origin,
  //   );
  //   if (userInput != null && userInput != origin) {
  //     dashboardStore
  //       ..setSipMainDoor(userInput)
  //       ..markDirty();
  //   }
  // }

  // void _editPC3(BuildContext context) async {
  //   var origin = dashboardStore.sipSmallDoor;
  //   var userInput = await prompt(
  //     context,
  //     title: Image.asset('assets/images/small_door.png'),
  //     // title: Text('小門口機sip address'),
  //     initialValue: origin,
  //   );
  //   if (userInput != null && userInput != origin) {
  //     dashboardStore
  //       ..setSipSmallDoor(userInput)
  //       ..markDirty();
  //   }
  // }

  void _editRestartCmd(BuildContext context) async {
    var origin = await getRestartCmd();
    var cmd = await prompt(
      context,
      title: Image.asset('assets/images/restart_cmd.png'),
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
      title: Image.asset('assets/images/restart_period.png'),
      initialValue: origin,
    );
    if (schedule != null) {
      var prefs = await SharedPreferences.getInstance();
      await prefs.setString('schedule', schedule);
    }
  }

  void _changeVolume(BuildContext context) async {
    var origin = dashboardStore.size;
    var newSize = await prompt(
      context,
      title: const Text('change size'),
      initialValue: origin.toString(),
    );
    if (newSize != null && newSize != origin.toString()) {
      dashboardStore
        ..setSize(int.parse(newSize))
        ..markDirty();
    }
  }

  void _changePassword(BuildContext context) async {
    var newPassword = await prompt(
      context,
      title: Image.asset('assets/images/change_password.png'),
    );
    if (newPassword != null) {
      context
          .read<AuthenticationBloc>()
          .add(AuthenticationPasswordChangeRequested(newPassword));
    }
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
      var list = newlist.where((dev) => (dev.getAttribute('ty') != '0'));
      var i = 0;
      var today = DateTime.now();
      var end = today.add(const Duration(days: 365));

      var dir = (await getApplicationDocumentsDirectory()).path;
      var configFile = '$dir/$addressbookini';

      // var directoryExists = await Directory(dir).exists();
      var fileExists = await File(configFile).exists();

      config = Config();
      if (fileExists) {
        var file = File(configFile);
        await file.delete();
      }

      for (var element in list) {
        var ty = element.getAttribute('ty') as String;
        if (ty == '7') {
          continue;
        }
        var ro = element.getAttribute('ro') as String;
        var title = element.getAttribute('alias') as String;
        var ip = element.getAttribute('ip') as String;
        var account = Util.roToAcc(ro, ty);
        var password = '';

        //除了 8 是手機, 之外都用 123456
        if (ty != '8') {
          password = '123456';
        } else {
          password = Util.genPw();
        }

        var whItem = ListItemStore()
          ..id = i++
          ..ty = ty
          ..ro = ro
          ..title = title
          ..ip = ip
          ..enabled = true
          ..account = account
          ..password = password
          ..createTime = today.millisecondsSinceEpoch
          ..endTime = end.millisecondsSinceEpoch;

        if (ty == '1') {
          //小門
          dashboardStore.sipSmallDoor = account;
        } else if (ty == '4') {
          //大門
          dashboardStore.sipMainDoor = account;
        } else if (ty == '9') {
          //緊急
          dashboardStore.sipEm = account;
        } else if (ty == '6') {
          //管理
          dashboardStore.sipAdmin = account;
        } else if (ty == '8') {
          //手機
          dashboardStore.items.add(whItem);
        }
        // ignore: unawaited_futures
        // insertWHItem(whItem);

        // await myDB.insertAddressItem(_foo(whItem));
        try {
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
        } catch (e) {
          logger.e('${whItem.ro} $e');
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('錯誤！ ${whItem.ro} $e')));
          return;
        }

        if (i >= dashboardStore.size) {
          break;
        }
      }

      if (!config.hasSection('system')) {
        config.addSection('system');
      }

      config
        ..set('system', 'ip', dashboardStore.ip)
        ..set('system', 'sipPrefix', dashboardStore.sipPrefix)
        ..set('system', 'size', dashboardStore.size.toString());
      // ..set('system', 'sipAdmin', sipAdmin)
      // ..set('system', 'sipMainDoor', sipMainDoor)
      // ..set('system', 'sipEm', sipEm)
      // ..set('system', 'sipSmallDoor', sipSmallDoor);

      var file = File(configFile);
      await file.writeAsString(config.toString());

      logger.d(configFile);

      dashboardStore.markDirty();
      // logger.d(config.toString());
      // print(document.toXmlString(pretty: true, indent: '\t'));
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('讀取Addressbook')));
  }

  Future<void> saveAllWHItems() async {
    // var config = Config();
    for (var item in dashboardStore.items) {
      if (!config.hasSection(item.ro)) {
        config.addSection(item.ro);
      }
      config
        // ..addSection(item.ro)
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

    if (!config.hasSection('system')) {
      config.addSection('system');
    }
    config
      ..set('system', 'ip', dashboardStore.ip)
      ..set('system', 'size', dashboardStore.size.toString())
      ..set('system', 'sipPrefix', dashboardStore.sipPrefix);
    // ..set('system', 'sipAdmin', dashboardStore.sipAdmin)
    // ..set('system', 'sipMainDoor', dashboardStore.sipMainDoor)
    // ..set('system', 'sipSmallDoor', dashboardStore.sipSmallDoor);

    var dir = (await getApplicationDocumentsDirectory()).path;
    var configFile = '$dir/$addressbookini';

    var fileExists = await File(configFile).exists();

    if (fileExists) {
      var file = File(configFile);
      await file.delete();
    }

    var file = File(configFile);
    await file.writeAsString(config.toString());

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('完成！請重新啟動sip服務')));

    await _restartServer();
  }

  Future<void> _resetPassword(ListItemStore item) async {
    var dialog = CupertinoAlertDialog(
      content: Image.asset('assets/images/reset_warning.png'),
      actions: <Widget>[
        CupertinoButton(
          child: Image.asset('assets/images/cancel.png'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        CupertinoButton(
          child: Image.asset('assets/images/yes.png'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
    switch (await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        })) {
      case true:
        item.reset();
        dashboardStore.markDirty();
        break;
      case false:
        // ...
        break;
      case null:
        // dialog dismissed
        break;
    }
  }

  Future<void> _restartServer() async {
    var dialog = CupertinoAlertDialog(
      content: Image.asset('assets/images/restart_server.png'),
      actions: <Widget>[
        CupertinoButton(
          child: Image.asset('assets/images/cancel.png'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        CupertinoButton(
          child: Image.asset('assets/images/yes.png'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
    switch (await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        })) {
      case true:
        restartSipServer();

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('重新啟動完成！')));
        break;
      case false:
        // ...
        break;
      case null:
        // dialog dismissed
        break;
    }
  }

  Future<void> _() async {
    switch (await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select assignment'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text('確定'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('取消'),
              ),
            ],
          );
        })) {
      case true:
        // Let's go.
        // ...
        break;
      case false:
        // ...
        break;
      case null:
        // dialog dismissed
        break;
    }
  }
}

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    //BlocBuilder ....
    return Container();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
