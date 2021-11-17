import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:winhome/login/login.dart';
import 'package:winhome/utils/utils.dart';

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
  var ver = '';
  var showLogin = false;
  var showError = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    var isVaildDevice = await Util.isVaildDevice();
    setState(() {
      showLogin = isVaildDevice;
      showError = !isVaildDevice;
    });

    var systemGUID = await Util.getSystemGUID();
    setState(() {
      sn = systemGUID;
    });

    final info = await PackageInfo.fromPlatform();
    setState(() {
      ver = 'v${info.version}(${info.buildNumber})';
    });
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
            child: Center(
              child: Column(
                children: [
                  Visibility(
                    visible: showLogin,
                    child: Expanded(child: LoginForm()),
                  ),
                  Visibility(
                    visible: showError,
                    child: const Expanded(
                        child: Center(
                            child: Text(
                      '不支援此電腦',
                    ))),
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: sn));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('序號複製成功！')));
                    },
                    child: Text(sn),
                  ),
                  Text(ver),
                  const SizedBox(height: 40)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
