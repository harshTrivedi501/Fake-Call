import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isCalledByMe = false;
  bool firstRun = true;
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    listenFirebaseData();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // try {
    //   platformVersion = await Callkeep.platformVersion;
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });

    await CallKeep.askForPermissionsIfNeeded(context);
  }

  listenFirebaseData() {
    FirebaseFirestore.instance.collection('users').snapshots().listen((event) {
      if (firstRun) {
        firstRun = false;
      } else if (!isCalledByMe) {
        this.displayIncomingCall();
      }
    });
  }

  Future<void> displayIncomingCall() async {
    await CallKeep.askForPermissionsIfNeeded(context);
    final callUUID = '0783a8e5-8353-4802-9448-c6211109af51';
    final number = '+91 9723553404';

    await CallKeep.displayIncomingCall(
        callUUID, number, number, HandleType.number, false);
  }

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance.collection('users').doc('harsh');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fake Call'),
      ),
      body: Center(
          child: ElevatedButton(
        onPressed: () {
          isCalledByMe = true;
          ref.update({'callTime': Timestamp.now()}).catchError(
              (err) => log(err));
        },
        child: Text('Press to call'),
      )),
    );
  }
}
