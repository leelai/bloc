import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:winhome/home/model/util.dart';

part 'dashboard_store.g.dart';

class DashboardStore = _DashboardStore with _$DashboardStore;

abstract class _DashboardStore with Store {
  @observable
  String sipPrefix = '';

  @observable
  var dirty = false;

  @observable
  var items = ObservableList<ListItemStore>();

  @observable
  var items2 = ObservableList<ListItemStore>(); //小門口 大門口

  @action
  void addItem(ListItemStore item) => items.add(item);

  @action
  void checked(int index, bool value) => items[index].enable(value);

  @action
  void changePrefix(String value) {
    sipPrefix = value;
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

  @computed
  String get encode =>
      // ignore: lines_longer_than_80_chars
      '$account@210.68.245.165 clrtxt:$password ;'; //100023@210.68.245.165 clrtxt:123a ;

  @computed
  String get createTimeStr {
    var date = DateTime.fromMillisecondsSinceEpoch(createTime);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @computed
  String get endTimeStr {
    var date = DateTime.fromMillisecondsSinceEpoch(endTime);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @computed
  bool get isExpired {
    return DateTime.now().millisecondsSinceEpoch > endTime;
  }

  @computed
  bool get isValid {
    return !isExpired && enabled;
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
