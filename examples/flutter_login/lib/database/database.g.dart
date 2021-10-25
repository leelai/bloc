// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class AddressItem extends DataClass implements Insertable<AddressItem> {
  final int id;
  final String ty;
  final String ro;
  final String alias;
  final String ip;
  final String account;
  final String password;
  final bool enable;
  final DateTime? createDate;
  final DateTime? expiredDate;
  AddressItem(
      {required this.id,
      required this.ty,
      required this.ro,
      required this.alias,
      required this.ip,
      required this.account,
      required this.password,
      required this.enable,
      this.createDate,
      this.expiredDate});
  factory AddressItem.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return AddressItem(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      ty: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}ty'])!,
      ro: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}ro'])!,
      alias: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}alias'])!,
      ip: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}ip'])!,
      account: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}account'])!,
      password: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}password'])!,
      enable: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}enable'])!,
      createDate: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}create_date']),
      expiredDate: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}expired_date']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ty'] = Variable<String>(ty);
    map['ro'] = Variable<String>(ro);
    map['alias'] = Variable<String>(alias);
    map['ip'] = Variable<String>(ip);
    map['account'] = Variable<String>(account);
    map['password'] = Variable<String>(password);
    map['enable'] = Variable<bool>(enable);
    if (!nullToAbsent || createDate != null) {
      map['create_date'] = Variable<DateTime?>(createDate);
    }
    if (!nullToAbsent || expiredDate != null) {
      map['expired_date'] = Variable<DateTime?>(expiredDate);
    }
    return map;
  }

  AddressItemsCompanion toCompanion(bool nullToAbsent) {
    return AddressItemsCompanion(
      id: Value(id),
      ty: Value(ty),
      ro: Value(ro),
      alias: Value(alias),
      ip: Value(ip),
      account: Value(account),
      password: Value(password),
      enable: Value(enable),
      createDate: createDate == null && nullToAbsent
          ? const Value.absent()
          : Value(createDate),
      expiredDate: expiredDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiredDate),
    );
  }

  factory AddressItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return AddressItem(
      id: serializer.fromJson<int>(json['id']),
      ty: serializer.fromJson<String>(json['ty']),
      ro: serializer.fromJson<String>(json['ro']),
      alias: serializer.fromJson<String>(json['alias']),
      ip: serializer.fromJson<String>(json['ip']),
      account: serializer.fromJson<String>(json['account']),
      password: serializer.fromJson<String>(json['password']),
      enable: serializer.fromJson<bool>(json['enable']),
      createDate: serializer.fromJson<DateTime?>(json['createDate']),
      expiredDate: serializer.fromJson<DateTime?>(json['expiredDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ty': serializer.toJson<String>(ty),
      'ro': serializer.toJson<String>(ro),
      'alias': serializer.toJson<String>(alias),
      'ip': serializer.toJson<String>(ip),
      'account': serializer.toJson<String>(account),
      'password': serializer.toJson<String>(password),
      'enable': serializer.toJson<bool>(enable),
      'createDate': serializer.toJson<DateTime?>(createDate),
      'expiredDate': serializer.toJson<DateTime?>(expiredDate),
    };
  }

  AddressItem copyWith(
          {int? id,
          String? ty,
          String? ro,
          String? alias,
          String? ip,
          String? account,
          String? password,
          bool? enable,
          DateTime? createDate,
          DateTime? expiredDate}) =>
      AddressItem(
        id: id ?? this.id,
        ty: ty ?? this.ty,
        ro: ro ?? this.ro,
        alias: alias ?? this.alias,
        ip: ip ?? this.ip,
        account: account ?? this.account,
        password: password ?? this.password,
        enable: enable ?? this.enable,
        createDate: createDate ?? this.createDate,
        expiredDate: expiredDate ?? this.expiredDate,
      );
  @override
  String toString() {
    return (StringBuffer('AddressItem(')
          ..write('id: $id, ')
          ..write('ty: $ty, ')
          ..write('ro: $ro, ')
          ..write('alias: $alias, ')
          ..write('ip: $ip, ')
          ..write('account: $account, ')
          ..write('password: $password, ')
          ..write('enable: $enable, ')
          ..write('createDate: $createDate, ')
          ..write('expiredDate: $expiredDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ty, ro, alias, ip, account, password,
      enable, createDate, expiredDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AddressItem &&
          other.id == this.id &&
          other.ty == this.ty &&
          other.ro == this.ro &&
          other.alias == this.alias &&
          other.ip == this.ip &&
          other.account == this.account &&
          other.password == this.password &&
          other.enable == this.enable &&
          other.createDate == this.createDate &&
          other.expiredDate == this.expiredDate);
}

class AddressItemsCompanion extends UpdateCompanion<AddressItem> {
  final Value<int> id;
  final Value<String> ty;
  final Value<String> ro;
  final Value<String> alias;
  final Value<String> ip;
  final Value<String> account;
  final Value<String> password;
  final Value<bool> enable;
  final Value<DateTime?> createDate;
  final Value<DateTime?> expiredDate;
  const AddressItemsCompanion({
    this.id = const Value.absent(),
    this.ty = const Value.absent(),
    this.ro = const Value.absent(),
    this.alias = const Value.absent(),
    this.ip = const Value.absent(),
    this.account = const Value.absent(),
    this.password = const Value.absent(),
    this.enable = const Value.absent(),
    this.createDate = const Value.absent(),
    this.expiredDate = const Value.absent(),
  });
  AddressItemsCompanion.insert({
    this.id = const Value.absent(),
    required String ty,
    required String ro,
    required String alias,
    required String ip,
    required String account,
    required String password,
    required bool enable,
    this.createDate = const Value.absent(),
    this.expiredDate = const Value.absent(),
  })  : ty = Value(ty),
        ro = Value(ro),
        alias = Value(alias),
        ip = Value(ip),
        account = Value(account),
        password = Value(password),
        enable = Value(enable);
  static Insertable<AddressItem> custom({
    Expression<int>? id,
    Expression<String>? ty,
    Expression<String>? ro,
    Expression<String>? alias,
    Expression<String>? ip,
    Expression<String>? account,
    Expression<String>? password,
    Expression<bool>? enable,
    Expression<DateTime?>? createDate,
    Expression<DateTime?>? expiredDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ty != null) 'ty': ty,
      if (ro != null) 'ro': ro,
      if (alias != null) 'alias': alias,
      if (ip != null) 'ip': ip,
      if (account != null) 'account': account,
      if (password != null) 'password': password,
      if (enable != null) 'enable': enable,
      if (createDate != null) 'create_date': createDate,
      if (expiredDate != null) 'expired_date': expiredDate,
    });
  }

  AddressItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? ty,
      Value<String>? ro,
      Value<String>? alias,
      Value<String>? ip,
      Value<String>? account,
      Value<String>? password,
      Value<bool>? enable,
      Value<DateTime?>? createDate,
      Value<DateTime?>? expiredDate}) {
    return AddressItemsCompanion(
      id: id ?? this.id,
      ty: ty ?? this.ty,
      ro: ro ?? this.ro,
      alias: alias ?? this.alias,
      ip: ip ?? this.ip,
      account: account ?? this.account,
      password: password ?? this.password,
      enable: enable ?? this.enable,
      createDate: createDate ?? this.createDate,
      expiredDate: expiredDate ?? this.expiredDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ty.present) {
      map['ty'] = Variable<String>(ty.value);
    }
    if (ro.present) {
      map['ro'] = Variable<String>(ro.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (ip.present) {
      map['ip'] = Variable<String>(ip.value);
    }
    if (account.present) {
      map['account'] = Variable<String>(account.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (enable.present) {
      map['enable'] = Variable<bool>(enable.value);
    }
    if (createDate.present) {
      map['create_date'] = Variable<DateTime?>(createDate.value);
    }
    if (expiredDate.present) {
      map['expired_date'] = Variable<DateTime?>(expiredDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AddressItemsCompanion(')
          ..write('id: $id, ')
          ..write('ty: $ty, ')
          ..write('ro: $ro, ')
          ..write('alias: $alias, ')
          ..write('ip: $ip, ')
          ..write('account: $account, ')
          ..write('password: $password, ')
          ..write('enable: $enable, ')
          ..write('createDate: $createDate, ')
          ..write('expiredDate: $expiredDate')
          ..write(')'))
        .toString();
  }
}

class $AddressItemsTable extends AddressItems
    with TableInfo<$AddressItemsTable, AddressItem> {
  final GeneratedDatabase _db;
  final String? _alias;
  $AddressItemsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _tyMeta = const VerificationMeta('ty');
  late final GeneratedColumn<String?> ty = GeneratedColumn<String?>(
      'ty', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _roMeta = const VerificationMeta('ro');
  late final GeneratedColumn<String?> ro = GeneratedColumn<String?>(
      'ro', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _aliasMeta = const VerificationMeta('alias');
  late final GeneratedColumn<String?> alias = GeneratedColumn<String?>(
      'alias', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _ipMeta = const VerificationMeta('ip');
  late final GeneratedColumn<String?> ip = GeneratedColumn<String?>(
      'ip', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _accountMeta = const VerificationMeta('account');
  late final GeneratedColumn<String?> account = GeneratedColumn<String?>(
      'account', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _passwordMeta = const VerificationMeta('password');
  late final GeneratedColumn<String?> password = GeneratedColumn<String?>(
      'password', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _enableMeta = const VerificationMeta('enable');
  late final GeneratedColumn<bool?> enable = GeneratedColumn<bool?>(
      'enable', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: true,
      defaultConstraints: 'CHECK (enable IN (0, 1))');
  final VerificationMeta _createDateMeta = const VerificationMeta('createDate');
  late final GeneratedColumn<DateTime?> createDate = GeneratedColumn<DateTime?>(
      'create_date', aliasedName, true,
      typeName: 'INTEGER', requiredDuringInsert: false);
  final VerificationMeta _expiredDateMeta =
      const VerificationMeta('expiredDate');
  late final GeneratedColumn<DateTime?> expiredDate =
      GeneratedColumn<DateTime?>('expired_date', aliasedName, true,
          typeName: 'INTEGER', requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        ty,
        ro,
        alias,
        ip,
        account,
        password,
        enable,
        createDate,
        expiredDate
      ];
  @override
  String get aliasedName => _alias ?? 'address_items';
  @override
  String get actualTableName => 'address_items';
  @override
  VerificationContext validateIntegrity(Insertable<AddressItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ty')) {
      context.handle(_tyMeta, ty.isAcceptableOrUnknown(data['ty']!, _tyMeta));
    } else if (isInserting) {
      context.missing(_tyMeta);
    }
    if (data.containsKey('ro')) {
      context.handle(_roMeta, ro.isAcceptableOrUnknown(data['ro']!, _roMeta));
    } else if (isInserting) {
      context.missing(_roMeta);
    }
    if (data.containsKey('alias')) {
      context.handle(
          _aliasMeta, alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta));
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    if (data.containsKey('ip')) {
      context.handle(_ipMeta, ip.isAcceptableOrUnknown(data['ip']!, _ipMeta));
    } else if (isInserting) {
      context.missing(_ipMeta);
    }
    if (data.containsKey('account')) {
      context.handle(_accountMeta,
          account.isAcceptableOrUnknown(data['account']!, _accountMeta));
    } else if (isInserting) {
      context.missing(_accountMeta);
    }
    if (data.containsKey('password')) {
      context.handle(_passwordMeta,
          password.isAcceptableOrUnknown(data['password']!, _passwordMeta));
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('enable')) {
      context.handle(_enableMeta,
          enable.isAcceptableOrUnknown(data['enable']!, _enableMeta));
    } else if (isInserting) {
      context.missing(_enableMeta);
    }
    if (data.containsKey('create_date')) {
      context.handle(
          _createDateMeta,
          createDate.isAcceptableOrUnknown(
              data['create_date']!, _createDateMeta));
    }
    if (data.containsKey('expired_date')) {
      context.handle(
          _expiredDateMeta,
          expiredDate.isAcceptableOrUnknown(
              data['expired_date']!, _expiredDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AddressItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    return AddressItem.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $AddressItemsTable createAlias(String alias) {
    return $AddressItemsTable(_db, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $AddressItemsTable addressItems = $AddressItemsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [addressItems];
}
