import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:flutter_vlc_player/src/vlc_player_controller.dart';
import 'package:media_kit/media_kit.dart';                      // Provides [Player], [Media], [Playlist] etc.
import 'package:media_kit_video/media_kit_video.dart';          // Provides [VideoController] & [Video] etc.


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // It's necessary to pass correct path to be able to use this library.
  final appDocDirectory = await getApplicationDocumentsDirectory();
  await configureNetworkTools(appDocDirectory.path, enableDebugging: true);

  // Necessary initialization for package:media_kit.
  MediaKit.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  // Create a [Player] to control playback.
  late final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  void checkIpDevices() async {
    var address = await (NetworkInfo().getWifiIP()) ?? '';
    String subnet = address.substring(0, address.lastIndexOf('.'));

    for (int i = 0; i < 254; i++) {
      String target = '$subnet.$i';
      PortScannerService.instance.scanPortsForSingleDevice(target, startPort: 554, endPort: 554, progressCallback: (progress) {
        // log('Progress for port discovery : $progress');
      }).listen((ActiveHost event) {
        if (event.openPorts.isNotEmpty) {
          log('Found open ports : $target:${event.openPorts}');
          i = 255;
        }
      }, onDone: () {
        // log('Scan completed');
      });
    }
  }
  
  String username = "ngmcong";
  String password = "";

  @override
  void initState() {
    super.initState();
    checkIpDevices();
    // Play a [Media] or [Playlist].
    player.open(Media('rtsp://$username:$password@192.168.1.119:554/stream1'));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Video(controller: controller),
      ),
    );
  }
}