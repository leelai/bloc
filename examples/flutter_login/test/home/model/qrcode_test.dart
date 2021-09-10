import 'package:flutter_test/flutter_test.dart';
import 'package:winhome/home/model/qrcode.dart';

void main() {
  test('check json string form qrcode class', () {
    final qr = WinhomeQRCode('test', '4000', '210.68.245.164:54346');
    qr.callOut['管理員'] = '2000';

    qr.address['大門'] = '123456';
    qr.address['小門'] = '123456';
    qr.address['管理員'] = '2000';

    expect(
        qr.toString(),
        // ignore: lines_longer_than_80_chars
        '{"name":"test","password":"4000","proxy":"210.68.245.164:54346","transport":"tls","callOut":{"管理員":"2000"},"address":{"大門":"123456","小門":"123456","管理員":"2000"}}');
  });
}
