import 'dart:convert';

class WinhomeQRCode {
  WinhomeQRCode(this._name, this._password, this._proxy, this._prefix,
      this._adminSip, this._mainDoorSip, this._smallDoorSip, this._em);
  final String _prefix;
  final String _name;
  final String _password;
  final String _proxy;
  final String _transport = 'tls';
  final String _adminSip;
  final String _mainDoorSip;
  final String _smallDoorSip;
  final String _em;

  Map<String, String> callOut = {};
  Map<String, String> address = {};

  @override
  String toString() {
    callOut['管理室'] = '$_prefix$_adminSip';
    address['管理室'] = '$_prefix$_adminSip';
    address['大門口機'] = '$_prefix$_mainDoorSip';
    address['小門口機'] = '$_prefix$_smallDoorSip';
    address['緊急對講機'] = '$_prefix$_em';

    var qrCode = {
      'name': '$_prefix$_name',
      'password': _password,
      'proxy': _proxy,
      'transport': _transport,
      'callOut': callOut,
      'address': address,
    };
    return jsonEncode(qrCode);
  }
}
