import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:winhome/home/mobx/dashboard_store.dart';
import 'package:winhome/utils/utils.dart';

import 'home_page.dart';

// var sipAddress = '';
// var password = '';
var ro = '';
var alias = '';

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
                  initialValue: '00-00-00-00-00-00-00',
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
                  var today = DateTime.now();
                  var end = today.add(const Duration(days: 365));

                  var whItem = ListItemStore()
                    ..id = 0
                    ..ty = '7'
                    ..ro = ro
                    ..title = alias
                    ..ip = ''
                    ..enabled = true
                    ..account = Util.roToAcc(ro)
                    ..password = Util.genPw()
                    ..createTime = today.millisecondsSinceEpoch
                    ..endTime = end.millisecondsSinceEpoch;

                  dashboardStore.items.add(whItem);
                  dashboardStore.markDirty();
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
