// import 'dart:async';
import 'package:moor_flutter/moor_flutter.dart';

part 'database.g.dart';

class AddressItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get ty => text()();
  TextColumn get ro => text()();
  TextColumn get alias => text()();
  TextColumn get ip => text()();

  TextColumn get account => text()();
  TextColumn get password => text()();

  BoolColumn get enable => boolean()();

  DateTimeColumn get createDate => dateTime().nullable()();
  DateTimeColumn get expiredDate => dateTime().nullable()();
}

@UseMoor(tables: [AddressItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(
            path: 'db1.sqlite', logStatements: true));

  @override
  int get schemaVersion => 1;

  Future<List<AddressItem>> getAllAddressItems() => select(addressItems).get();
  Stream<List<AddressItem>> watchAllAddressItems() =>
      select(addressItems).watch();
  Future<int> insertAddressItem(AddressItem addressItem) =>
      into(addressItems).insert(addressItem);
  Future updateAddressItem(AddressItem addressItem) =>
      update(addressItems).replace(addressItem);
  Future deleteAddressItem(AddressItem addressItem) =>
      delete(addressItems).delete(addressItem);
}
