import 'dart:io';
import 'dart:io' show Platform;

import 'package:authentication_repository/authentication_repository.dart';
import 'package:cron/cron.dart';
import 'package:flutter/widgets.dart';
import 'package:ini/ini.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winhome/app.dart';
import 'package:winhome/utils/utils.dart';

import 'home/home.dart';
import 'home/mobx/dashboard_store.dart';

void main() {
  runApp(App(
    authenticationRepository: AuthenticationRepository(),
    userRepository: UserRepository(),
  ));

  Util.isVaildDevice().then((ok) {
    if (ok) {
      getSchedule().then((value) {
        print('getSchedule=$value');
        Cron()
          ..schedule(
            Schedule.parse(value),
            () async {
              print('restartSipServer');
              // restartSipServer(Platform.isLinux);
              restartSipServer();
            },
          );
      });
    }
  });
}

Future<String> getRestartCmd() async {
  var prefs = await SharedPreferences.getInstance();
  return prefs.getString('restartCmd') ??
      'systemctl restart flexisip-proxy flexisip-presence';
}

Future<String> getSchedule() async {
  //*/3 * * * *  every three minutes
  //8-11 * * * *  every 8 and 11 minutes
  //Every day at midnight	0 0 * * *
  var prefs = await SharedPreferences.getInstance();
  return prefs.getString('schedule') ?? '0 0 * * *';
}

void restartSipServer() async {
  var dir = (await getApplicationDocumentsDirectory()).path;
  var configFile = '$dir/$addressbookini';

  var fileExists = await File(configFile).exists();
  var restartCmd = await getRestartCmd();

  logger
      .d('[restartSipServer] configFile: $configFile , fileExists=$fileExists');

  if (!fileExists) {
    return;
  }

  var config = await File(configFile)
      .readAsLines()
      .then((lines) => Config.fromStrings(lines));

  var sipPrefix = config.get('system', 'sipPrefix') ?? '';
  var sipIp = config.get('system', 'ip')!.split(':')[0];

  var sections = config.sections();
  var i = 0;

  var path = Platform.isLinux ? '/etc/flexisip' : dir;
  var userDB = '$path/user.db';
  var userDBDirExists = await Directory(path).exists();
  var userDBfileExists = await File(userDB).exists();
  logger.d(
      '$path is exist = $userDBDirExists, $userDB is exist = $userDBfileExists');

  if (userDBDirExists == false) {
    var directory = await Directory(path).create(recursive: true);
    print('directory created $directory');
  }

  var file = File('$path/user.db');
  var sink = file.openWrite()..write('version:1\n\n');

  for (var section in sections) {
    if (section == 'system') {
      // var sipAdmin = config.get('system', 'sipAdmin');
      // if (sipAdmin!.isNotEmpty) {
      //   sink.write('$sipAdmin@$sipIp clrtxt:123456 ;\n');
      // }

      // var sipMainDoor = config.get('system', 'sipMainDoor');
      // if (sipMainDoor!.isNotEmpty) {
      //   sink.write('$sipMainDoor@$sipIp clrtxt:123456 ;\n');
      // }
      // var sipSmallDoor = config.get('system', 'sipSmallDoor');
      // if (sipSmallDoor!.isNotEmpty) {
      //   sink.write('$sipSmallDoor@$sipIp clrtxt:123456 ;\n');
      // }
      continue;
    }

    var item = ListItemStore()
      ..id = i++
      ..ty = config.get(section, 'ty')!
      ..ro = config.get(section, 'ro')!
      ..title = config.get(section, 'alias')!
      ..ip = config.get(section, 'ip')!
      ..enabled = config.get(section, 'enable')! == 'true'
      ..account = config.get(section, 'account')!
      ..password = config.get(section, 'password')!
      ..createTime = int.parse(config.get(section, 'createTime')!)
      ..endTime = int.parse(config.get(section, 'expiredTime')!);

    if (item.isValid) {
      var encode = '$sipPrefix${item.account}@$sipIp clrtxt:${item.password} ;';
      sink.write('$encode\n');
    } else {
      //logger.d('${item.account} is not valid');
    }
  }

  await sink.close();

  var shell = Shell();
  await shell.run(restartCmd);
}
