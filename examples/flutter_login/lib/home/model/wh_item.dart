//
//<dev ty="7" ro="01-00-70-01-03-01" alias="70號1樓之3" ip="192.168.100.141" sm="255.255.255.0" gw="192.168.100.1"/>
//
class WHItemI {
  WHItemI({
    required this.id,
    required this.ty,
    required this.ro,
    required this.alias,
    required this.ip,
    required this.account,
    required this.password,
    this.enable = true,
    required this.createTime,
    required this.endTime,
  });

  final int id;

  final String ty;
  final String ro;
  final String alias;
  final String ip;

  final String account;
  final String password;

  bool enable;

  final int createTime;
  final int endTime;

  // static convert() {}
  String encode() {
    return '$account@210.68.245.165 clrtxt:$password ;';
  }

  // Convert a WHItem into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'ty': ty,
        'ro': ro,
        'alias': alias,
        'ip': ip,
        'account': account,
        'password': password,
        'enable': enable,
        'create_time': createTime,
        'end_time': endTime,
      };

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'WHItem{id: $id, ty: $ty, ro: $ro, alias: $alias, ip: $ip, account: $account, password : $password, enable: $enable, create_time: $createTime, end_time: $endTime}';
  }
}
