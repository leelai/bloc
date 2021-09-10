import 'dart:convert';

class WinhomeQRCode {
  WinhomeQRCode(this._name, this._password, this._proxy);
  final String _name;
  final String _password;
  final String _proxy;
  final String _transport = 'tls';
  Map<String, String> callOut = {};
  Map<String, String> address = {};

  @override
  String toString() {
    var qrCode = {
      'name': _name,
      'password': _password,
      'proxy': _proxy,
      'transport': _transport,
      'callOut': callOut,
      'address': address,
    };
    return jsonEncode(qrCode);
  }
}
