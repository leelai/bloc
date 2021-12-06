import 'dart:io';

import 'package:ini/ini.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:winhome/utils/utils.dart';

import '../home.dart';

part 'dashboard_store.g.dart';

class DashboardStore = _DashboardStore with _$DashboardStore;

abstract class _DashboardStore with Store {
  @observable
  String ip = '';

  @observable
  String sipPrefix = '';

  @observable
  String sipAdmin = ''; //sip管理機

  @observable
  String sipMainDoor = ''; //sip大門口機

  @observable
  String sipSmallDoor = ''; //sip小門口機

  @observable
  String sipEm = '';

  @observable
  var dirty = false;

  @observable
  var items = ObservableList<ListItemStore>();

  @observable
  int size = 800;

  @action
  void setSize(int size) {
    this.size = size;
  }

  @action
  void addItem(ListItemStore item) => items.add(item);

  @action
  void checked(int index, bool value) => items[index].enable(value);

  @action
  void setIp(String value) {
    ip = value;

    save();
  }

  @action
  void changePrefix(String value) {
    sipPrefix = value;

    save();
  }

//
//save ip and 案場編號 to ini
//
  void save() async {
    var dir = (await getApplicationDocumentsDirectory()).path;
    var configFile = '$dir/$addressbookini';
    var directoryExists = await Directory(dir).exists();
    var fileExists = await File(configFile).exists();
    if (directoryExists || fileExists) {
      var config = await File(configFile)
          .readAsLines()
          .then((lines) => Config.fromStrings(lines));

      //check section name
      var sectionName = 'system';
      if (!config.hasSection(sectionName)) {
        config.addSection(sectionName);
      }

      //write ip and sip_prefix
      config
        ..set(sectionName, 'ip', ip)
        ..set(sectionName, 'sipPrefix', sipPrefix)
        ..set(sectionName, 'size', size.toString());
      // ..set(sectionName, 'sipAdmin', sipAdmin)
      // ..set(sectionName, 'sipMainDoor', sipMainDoor)
      // ..set(sectionName, 'sipSmallDoor', sipSmallDoor);

      //write config back to file
      var file = File(configFile);
      await file.writeAsString(config.toString());
    }
  }

  @action
  void markDirty() {
    dirty = true;
  }

  @action
  void resetDirty() {
    dirty = false;
  }
}

class ListItemStore = _ListItemStore with _$ListItemStore;

abstract class _ListItemStore with Store {
  int id = 0;
  String ro = '';
  String ip = '';
  String ty = '';

  @observable
  String title = '';

  @observable
  String subTitle = '';

  @observable
  String account = '';

  @observable
  String password = '';

  @observable
  int createTime = 0;

  @observable
  int endTime = 0;

  @action
  void setEndTime(DateTime endTime) {
    this.endTime = endTime.millisecondsSinceEpoch;
  }

  @observable
  bool enabled = false;

  @action
  void enable(bool checkValue) => enabled = checkValue;

  @action
  void reset() => password = Util.genPw();

  // @computed
  // String get encode =>
  //     // ignore: lines_longer_than_80_chars
  //     '$account@210.68.245.165 clrtxt:$password ;'; //100023@210.68.245.165 clrtxt:123a ;

  @computed
  String get createTimeStr {
    var date = DateTime.fromMillisecondsSinceEpoch(createTime);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @computed
  String get endTimeStr {
    var date = DateTime.fromMillisecondsSinceEpoch(endTime);
    var dateStr = DateFormat('yyyy-MM-dd').format(date);
    if (isExpired) {
      dateStr += '(已過期)';
    }
    return dateStr;
  }

  @computed
  bool get isExpired {
    return DateTime.now().millisecondsSinceEpoch > endTime;
  }

  @computed
  bool get isValid {
    return !isExpired && enabled;
  }

  @computed
  bool get readOnly {
    return ty != '7' && ty != '8';
  }

  // Map<String, dynamic> toMap() => <String, dynamic>{
  //       'id': id,
  //       'ty': ty,
  //       'ro': ro,
  //       'alias': title,
  //       'ip': ip,
  //       'account': account,
  //       'password': password,
  //       'enable': enabled ? 'true' : 'false',
  //       'create_time': createTime,
  //       'end_time': endTime,
  //     };

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'WHItem{id: $id, ty: $ty, ro: $ro, alias: $title, ip: $ip, account: $account, password : $password, enable: $enabled, create_time: $createTime, end_time: $endTime}';
  }
}
