// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$DashboardStore on _DashboardStore, Store {
  final _$itemsAtom = Atom(name: '_DashboardStore.items');

  @override
  ObservableList<ListItemStore> get items {
    _$itemsAtom.reportRead();
    return super.items;
  }

  @override
  set items(ObservableList<ListItemStore> value) {
    _$itemsAtom.reportWrite(value, super.items, () {
      super.items = value;
    });
  }

  final _$_DashboardStoreActionController =
      ActionController(name: '_DashboardStore');

  @override
  void addItem(ListItemStore item) {
    final _$actionInfo = _$_DashboardStoreActionController.startAction(
        name: '_DashboardStore.addItem');
    try {
      return super.addItem(item);
    } finally {
      _$_DashboardStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void checked(int index, bool value) {
    final _$actionInfo = _$_DashboardStoreActionController.startAction(
        name: '_DashboardStore.checked');
    try {
      return super.checked(index, value);
    } finally {
      _$_DashboardStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
items: ${items}
    ''';
  }
}

mixin _$ListItemStore on _ListItemStore, Store {
  final _$titleAtom = Atom(name: '_ListItemStore.title');

  @override
  String get title {
    _$titleAtom.reportRead();
    return super.title;
  }

  @override
  set title(String value) {
    _$titleAtom.reportWrite(value, super.title, () {
      super.title = value;
    });
  }

  final _$subTitleAtom = Atom(name: '_ListItemStore.subTitle');

  @override
  String get subTitle {
    _$subTitleAtom.reportRead();
    return super.subTitle;
  }

  @override
  set subTitle(String value) {
    _$subTitleAtom.reportWrite(value, super.subTitle, () {
      super.subTitle = value;
    });
  }

  final _$accountAtom = Atom(name: '_ListItemStore.account');

  @override
  String get account {
    _$accountAtom.reportRead();
    return super.account;
  }

  @override
  set account(String value) {
    _$accountAtom.reportWrite(value, super.account, () {
      super.account = value;
    });
  }

  final _$passwordAtom = Atom(name: '_ListItemStore.password');

  @override
  String get password {
    _$passwordAtom.reportRead();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.reportWrite(value, super.password, () {
      super.password = value;
    });
  }

  final _$checkedAtom = Atom(name: '_ListItemStore.checked');

  @override
  bool get checked {
    _$checkedAtom.reportRead();
    return super.checked;
  }

  @override
  set checked(bool value) {
    _$checkedAtom.reportWrite(value, super.checked, () {
      super.checked = value;
    });
  }

  final _$_ListItemStoreActionController =
      ActionController(name: '_ListItemStore');

  @override
  void check(bool checkValue) {
    final _$actionInfo = _$_ListItemStoreActionController.startAction(
        name: '_ListItemStore.check');
    try {
      return super.check(checkValue);
    } finally {
      _$_ListItemStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_ListItemStoreActionController.startAction(
        name: '_ListItemStore.reset');
    try {
      return super.reset();
    } finally {
      _$_ListItemStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
title: ${title},
subTitle: ${subTitle},
account: ${account},
password: ${password},
checked: ${checked}
    ''';
  }
}
