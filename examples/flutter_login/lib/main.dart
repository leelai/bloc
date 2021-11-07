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

import 'home/home.dart';
import 'home/mobx/dashboard_store.dart';

void main() {
  runApp(App(
    authenticationRepository: AuthenticationRepository(),
    userRepository: UserRepository(),
  ));

  getSchedule().then((value) {
    print('getSchedule=$value');
    Cron()
      ..schedule(
        Schedule.parse(value),
        () async {
          print('restartSipServer');
          // restartSipServer(Platform.isLinux);
          restartSipServer(true);
        },
      );
  });
}

Future<String> getSipPrefix() async {
  var prefs = await SharedPreferences.getInstance();
  return prefs.getString('sipPrefix') ?? '';
}

Future<String> getIp() async {
  var prefs = await SharedPreferences.getInstance();
  return prefs.getString('ip') ?? '';
}

Future<String> getRestartCmd() async {
  var prefs = await SharedPreferences.getInstance();
  return prefs.getString('restartCmd') ?? 'echo Hello World';
}

Future<String> getSchedule() async {
  //*/3 * * * *  every three minutes
  //8-11 * * * *  every 8 and 11 minutes
  //Every day at midnight	0 0 * * *
  var prefs = await SharedPreferences.getInstance();
  return prefs.getString('schedule') ?? '0-59 0 * * *'; //午夜0~59分
}

void restartSipServer(bool genUserDB) async {
  var dir = (await getApplicationDocumentsDirectory()).path;
  var configFile = '$dir/$addressbookini';

  var directoryExists = await Directory(configFile).exists();
  var fileExists = await File(configFile).exists();
  var sipPrefix = await getSipPrefix();
  var restartCmd = await getRestartCmd();

  logger.d('[restartSipServer] configFile: $configFile');

  if (directoryExists || fileExists) {
    var config = await File(configFile)
        .readAsLines()
        .then((lines) => Config.fromStrings(lines));

    var sections = config.sections();
    if (genUserDB) {
      var i = 0;

      var path = Platform.isLinux ? '/etc/flexisip' : dir;
      var file = File('$path/user.db');
      var sink = file.openWrite()..write('version:1\n');

      for (var section in sections) {
        // logger.d(section);
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
          sink.write('$sipPrefix${item.encode}\n');
        } else {
          logger.d('${item.account} is not valid');
        }
      }

      await sink.close();

      print(file.absolute);

      var shell = Shell();

      await shell.run(restartCmd);
    } else {
      // for (var section in sections) {
      //   logger.d(section);
      // }
      // var shell = Shell();
      // await shell.run('echo Hello 2');
    }
  } else {
    logger.w('directory is not exist');
  }
}
