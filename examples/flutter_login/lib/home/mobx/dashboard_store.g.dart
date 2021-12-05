// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$DashboardStore on _DashboardStore, Store {
  final _$ipAtom = Atom(name: '_DashboardStore.ip');

  @override
  String get ip {
    _$ipAtom.reportRead();
    return super.ip;
  }

  @override
  set ip(String value) {
    _$ipAtom.reportWrite(value, super.ip, () {
      super.ip = value;
    });
  }

  final _$sipPrefixAtom = Atom(name: '_DashboardStore.sipPrefix');

  @override
  String get sipPrefix {
    _$sipPrefixAtom.reportRead();
    return super.sipPrefix;
  }

  @override
  set sipPrefix(String value) {
    _$sipPrefixAtom.reportWrite(value, super.sipPrefix, () {
      super.sipPrefix = value;
    });
  }

  final _$sipAdminAtom = Atom(name: '_DashboardStore.sipAdmin');

  @override
  String get sipAdmin {
    _$sipAdminAtom.reportRead();
    return super.sipAdmin;
  }

  @override
  set sipAdmin(String value) {
    _$sipAdminAtom.reportWrite(value, super.sipAdmin, () {
      super.sipAdmin = value;
    });
  }

  final _$sipMainDoorAtom = Atom(name: '_DashboardStore.sipMainDoor');

  @override
  String get sipMainDoor {
    _$sipMainDoorAtom.reportRead();
    return super.sipMainDoor;
  }

  @override
  set sipMainDoor(String value) {
    _$sipMainDoorAtom.reportWrite(value, super.sipMainDoor, () {
      super.sipMainDoor = value;
    });
  }

  final _$sipSmallDoorAtom = Atom(name: '_DashboardStore.sipSmallDoor');

  @override
  String get sipSmallDoor {
    _$sipSmallDoorAtom.reportRead();
    return super.sipSmallDoor;
  }

  @override
  set sipSmallDoor(String value) {
    _$sipSmallDoorAtom.reportWrite(value, super.sipSmallDoor, () {
      super.sipSmallDoor = value;
    });
  }

  final _$sipEmAtom = Atom(name: '_DashboardStore.sipEm');

  @override
  String get sipEm {
    _$sipEmAtom.reportRead();
    return super.sipEm;
  }

  @override
  set sipEm(String value) {
    _$sipEmAtom.reportWrite(value, super.sipEm, () {
      super.sipEm = value;
    });
  }

  final _$dirtyAtom = Atom(name: '_DashboardStore.dirty');

  @override
  bool get dirty {
    _$dirtyAtom.reportRead();
    return super.dirty;
  }

  @override
  set dirty(bool value) {
    _$dirtyAtom.reportWrite(value, super.dirty, () {
      super.dirty = value;
    });
  }

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
  void setIp(String value) {
    final _$actionInfo = _$_DashboardStoreActionController.startAction(
        name: '_DashboardStore.setIp');
    try {
      return super.setIp(value);
    } finally {
      _$_DashboardStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void changePrefix(String value) {
    final _$actionInfo = _$_DashboardStoreActionController.startAction(
        name: '_DashboardStore.changePrefix');
    try {
      return super.changePrefix(value);
    } finally {
      _$_DashboardStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void markDirty() {
    final _$actionInfo = _$_DashboardStoreActionController.startAction(
        name: '_DashboardStore.markDirty');
    try {
      return super.markDirty();
    } finally {
      _$_DashboardStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetDirty() {
    final _$actionInfo = _$_DashboardStoreActionController.startAction(
        name: '_DashboardStore.resetDirty');
    try {
      return super.resetDirty();
    } finally {
      _$_DashboardStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
ip: ${ip},
sipPrefix: ${sipPrefix},
sipAdmin: ${sipAdmin},
sipMainDoor: ${sipMainDoor},
sipSmallDoor: ${sipSmallDoor},
sipEm: ${sipEm},
dirty: ${dirty},
items: ${items}
    ''';
  }
}

mixin _$ListItemStore on _ListItemStore, Store {
  Computed<String>? _$createTimeStrComputed;

  @override
  String get createTimeStr =>
      (_$createTimeStrComputed ??= Computed<String>(() => super.createTimeStr,
              name: '_ListItemStore.createTimeStr'))
          .value;
  Computed<String>? _$endTimeStrComputed;

  @override
  String get endTimeStr =>
      (_$endTimeStrComputed ??= Computed<String>(() => super.endTimeStr,
              name: '_ListItemStore.endTimeStr'))
          .value;
  Computed<bool>? _$isExpiredComputed;

  @override
  bool get isExpired =>
      (_$isExpiredComputed ??= Computed<bool>(() => super.isExpired,
              name: '_ListItemStore.isExpired'))
          .value;
  Computed<bool>? _$isValidComputed;

  @override
  bool get isValid => (_$isValidComputed ??=
          Computed<bool>(() => super.isValid, name: '_ListItemStore.isValid'))
      .value;
  Computed<bool>? _$readOnlyComputed;

  @override
  bool get readOnly => (_$readOnlyComputed ??=
          Computed<bool>(() => super.readOnly, name: '_ListItemStore.readOnly'))
      .value;

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

  final _$createTimeAtom = Atom(name: '_ListItemStore.createTime');

  @override
  int get createTime {
    _$createTimeAtom.reportRead();
    return super.createTime;
  }

  @override
  set createTime(int value) {
    _$createTimeAtom.reportWrite(value, super.createTime, () {
      super.createTime = value;
    });
  }

  final _$endTimeAtom = Atom(name: '_ListItemStore.endTime');

  @override
  int get endTime {
    _$endTimeAtom.reportRead();
    return super.endTime;
  }

  @override
  set endTime(int value) {
    _$endTimeAtom.reportWrite(value, super.endTime, () {
      super.endTime = value;
    });
  }

  final _$enabledAtom = Atom(name: '_ListItemStore.enabled');

  @override
  bool get enabled {
    _$enabledAtom.reportRead();
    return super.enabled;
  }

  @override
  set enabled(bool value) {
    _$enabledAtom.reportWrite(value, super.enabled, () {
      super.enabled = value;
    });
  }

  final _$_ListItemStoreActionController =
      ActionController(name: '_ListItemStore');

  @override
  void setEndTime(DateTime endTime) {
    final _$actionInfo = _$_ListItemStoreActionController.startAction(
        name: '_ListItemStore.setEndTime');
    try {
      return super.setEndTime(endTime);
    } finally {
      _$_ListItemStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void enable(bool checkValue) {
    final _$actionInfo = _$_ListItemStoreActionController.startAction(
        name: '_ListItemStore.enable');
    try {
      return super.enable(checkValue);
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
createTime: ${createTime},
endTime: ${endTime},
enabled: ${enabled},
createTimeStr: ${createTimeStr},
endTimeStr: ${endTimeStr},
isExpired: ${isExpired},
isValid: ${isValid},
readOnly: ${readOnly}
    ''';
  }
}
