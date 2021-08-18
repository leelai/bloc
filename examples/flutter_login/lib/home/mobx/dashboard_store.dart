import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';

part 'dashboard_store.g.dart';

class DashboardStore = _DashboardStore with _$DashboardStore;

abstract class _DashboardStore with Store {
  @observable
  var items = ObservableList<ListItemStore>();

  @action
  void addItem(ListItemStore item) {
    items.add(item);
  }

  @action
  void checked(int index, bool value) {
    items[index].check(value);
  }
}

class ListItemStore = _ListItemStore with _$ListItemStore;

abstract class _ListItemStore with Store {
  @observable
  String title = '';

  @observable
  String subTitle = '';

  @observable
  bool checked = false;

  @action
  void check(bool checkValue) {
    //print("item checkado - $checkValue");
    checked = checkValue;
  }
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
