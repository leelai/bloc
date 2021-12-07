import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:winhome/home/mobx/dashboard_store.dart';
import 'package:winhome/utils/utils.dart';

import 'home_page.dart';

// var sipAddress = '';
// var password = '';
var ro = '';
var alias = '';
var ty = '8';

class AddSipAddress extends StatelessWidget {
  const AddSipAddress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Sip Address'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'ro',
                    hintText: '00-00-00-00-00-00',
                  ),
                  initialValue: '00-00-00-00-00-00',
                  onChanged: (_ro) {
                    ro = _ro;
                  }),
              const SizedBox(height: 20),
              TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'alias',
                    hintText: 'Enter alias',
                  ),
                  onChanged: (_alias) {
                    alias = _alias;
                  }),
              const SizedBox(height: 20),
              TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'ty',
                    hintText: 'Enter ty',
                  ),
                  onChanged: (_ty) {
                    ty = _ty;
                  }),
              // TextField(
              //     decoration: const InputDecoration(
              //       border: OutlineInputBorder(),
              //       labelText: 'Sip Address',
              //       hintText: 'Enter Sip Address',
              //     ),
              //     onChanged: (_sipAddress) {
              //       logger.d(_sipAddress);
              //       sipAddress = _sipAddress;
              //     }),
              const SizedBox(height: 20),
              // TextField(
              //     decoration: const InputDecoration(
              //       border: OutlineInputBorder(),
              //       labelText: 'Password',
              //       hintText: 'Enter Password',
              //     ),
              //     onChanged: (_password) {
              //       logger.d(_password);
              //       password = _password;
              //     }),
              // const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  if (config.hasSection(ro)) {
                    return;
                  }
                  for (var item in dashboardStore.items) {
                    if (item.ro == ro) {
                      return;
                    }
                  }

                  var today = DateTime.now();
                  var end = today.add(const Duration(days: 365));
                  var account = Util.roToAcc(ro, ty);
                  var password = '';
                  if (ty != '8') {
                    password = '123456';
                  } else {
                    password = Util.genPw();
                  }
                  var whItem = ListItemStore()
                    ..id = 0
                    ..ty = ty
                    ..ro = ro
                    ..title = alias
                    ..ip = ''
                    ..enabled = true
                    ..account = account
                    ..password = password
                    ..createTime = today.millisecondsSinceEpoch
                    ..endTime = end.millisecondsSinceEpoch;

                  if (ty == '1') {
                    //小門
                    dashboardStore.sipSmallDoor = account;
                  } else if (ty == '4') {
                    //大門
                    dashboardStore.sipMainDoor = account;
                  } else if (ty == '9') {
                    //緊急
                    dashboardStore.sipEm = account;
                  } else if (ty == '6') {
                    //管理
                    dashboardStore.sipAdmin = account;
                  } else if (ty == '8') {
                    //手機
                    dashboardStore.items.add(whItem);
                  }
                  dashboardStore.markDirty();

                  try {
                    config
                      ..addSection(whItem.ro)
                      ..set(whItem.ro, 'ty', whItem.ty)
                      ..set(whItem.ro, 'alias', whItem.title)
                      ..set(whItem.ro, 'ro', whItem.ro)
                      ..set(whItem.ro, 'ip', whItem.ip)
                      ..set(whItem.ro, 'enable', whItem.enabled.toString())
                      ..set(whItem.ro, 'account', whItem.account)
                      ..set(whItem.ro, 'password', whItem.password)
                      ..set(
                          whItem.ro, 'createTime', whItem.createTime.toString())
                      ..set(
                          whItem.ro, 'expiredTime', whItem.endTime.toString());
                  } catch (e) {
                    logger.e('${whItem.ro} $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('錯誤！ ${whItem.ro} $e')));
                    return;
                  }

                  Navigator.of(context).pop();
                },
                child: const Card(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Apply'),
                )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
