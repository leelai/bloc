import 'dart:math';

import 'package:mobx/mobx.dart';

part 'dashboard_store.g.dart';

class DashboardStore = _DashboardStore with _$DashboardStore;

abstract class _DashboardStore with Store {
  @observable
  String sipPrefix = '';

  @observable
  var items = ObservableList<ListItemStore>();

  @action
  void addItem(ListItemStore item) => items.add(item);

  @action
  void checked(int index, bool value) => items[index].check(value);

  @action
  void changePrefix(String value) {
    sipPrefix = value;
  }
}

class ListItemStore = _ListItemStore with _$ListItemStore;

abstract class _ListItemStore with Store {
  @observable
  String title = '';

  @observable
  String subTitle = '';

  @observable
  String account = '';

  @observable
  String password = genPw();

  @observable
  bool checked = false;

  @action
  void check(bool checkValue) => checked = checkValue;

  @action
  void reset() => password = genPw();

  @computed
  String get encode =>
      // ignore: lines_longer_than_80_chars
      '$account@210.68.245.165 clrtxt:$password ;'; //100023@210.68.245.165 clrtxt:123a ;

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  static String _getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));

  static String genPw() => _getRandomString(10);
}

// abstract class ListItem {
//   /// The title line to show in a list item.
//   Widget buildTitle(BuildContext context);

//   /// The subtitle line, if any, to show in a list item.
//   Widget buildSubtitle(BuildContext context);
// }

// /// A ListItem that contains data to display a message.
// class MessageItem implements ListItem {
//   final String sender;
//   final String body;

//   MessageItem(this.sender, this.body);

//   @override
//   Widget buildTitle(BuildContext context) => Text(sender);

//   @override
//   Widget buildSubtitle(BuildContext context) => Text(body);
// }
