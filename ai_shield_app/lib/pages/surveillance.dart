import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_shield_app/settings/navigation.dart';
import 'package:ai_shield_app/settings/themes.dart';

import 'package:ai_shield_app/widgets/video_box.dart';
import 'package:ai_shield_app/api/video.dart';
import 'package:provider/provider.dart';

class SurveillancePage extends StatefulWidget {
  const SurveillancePage({super.key});
  
  @override
  State<SurveillancePage> createState() => _SurveillancePageState();
}

class _SurveillancePageState extends State<SurveillancePage> {
  late int videosCount;
  late List<String> videoStringUrls;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVideosPaths();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Surveillance'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            context.push(NavigationHelper.homePath);
          },
        ),
        actions: [
          Text(themeProvider.themeData.brightness == Brightness.light ? 'Light' : 'Dark'),
          Switch(
            value: themeProvider.themeData.brightness == Brightness.dark,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              context.push(NavigationHelper.homePath);
              await FirebaseAuth.instance.signOut();
            },
          ),
          
        ],
        toolbarHeight: 50,
      ),
      body: Center(
        child: 
          _isLoading 
          ? const CircularProgressIndicator()
          : Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(videosCount, (index) {
              VideoBox videoBox = VideoBox(
                videoPath: videoStringUrls[index],
              );
              return SizedBox(
                width: MediaQuery.of(context).size.width / sqrt(videosCount) - 10 * sqrt(videosCount),
                height: MediaQuery.of(context).size.height / (videosCount / sqrt(videosCount)) - 10 * (videosCount / sqrt(videosCount)) - 50,
                child: videoBox,
              );
            }),
          ),
      ),
    );
  }

  Future<void> _fetchVideosPaths() async {
    try {
      final paths = await VideoApi.getVideosPaths();
      if(mounted){
        setState(() {
          videoStringUrls = paths;
          videosCount = paths.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}


