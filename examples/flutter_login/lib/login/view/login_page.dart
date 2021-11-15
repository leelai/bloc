import 'dart:io';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:winhome/home/home.dart';
import 'package:winhome/login/login.dart';

List<String> systemGUIDs = ['899369E3-745A-5617-A837-3158E968D793'];

class LoginPage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => LoginPage());
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  var sn = '';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  static Future<String> getSystemGUID() async {
    // var deviceData = <String, dynamic>{};

    // if (Platform.isLinux) {
    //   deviceData = _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo);
    // } else if (Platform.isMacOS) {
    //   deviceData = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
    // }
    // logger.d(deviceData);

    String? deviceId;
    try {
      deviceId = await PlatformDeviceId.getDeviceId;
    } on Exception catch (err) {
      deviceId = err.toString();
    }

    return deviceId ?? 'Failed to get deviceId.';

    // var key = Platform.isMacOS ? 'systemGUID' : 'machineId';
    // return deviceData[key] as String;
  }

  Future<void> initPlatformState() async {
    var systemGUID = await getSystemGUID();
    setState(() {
      sn = systemGUID;
    });
  }

  static Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  static Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WinHome')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: BlocProvider(
          create: (context) {
            return LoginBloc(
              authenticationRepository:
                  RepositoryProvider.of<AuthenticationRepository>(context),
            );
          },
          child: Container(
            child: Column(
              children: [
                Expanded(child: LoginForm()),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: sn));
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('序號複製成功！')));
                  },
                  child: Text(sn),
                ),
                const SizedBox(height: 40)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
