import 'package:ai_shield_app/api/auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_shield_app/settings/navigation.dart';
import 'package:ai_shield_app/settings/themes.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
        title: const Text('Security WebCams'),
        leading: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                context.push(NavigationHelper.homePath);
              },
            ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              bool success = await AuthApi.logout(context);
              if (mounted && success){
                context.push(NavigationHelper.homePath);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: 
          _isLoading 
          ? const CircularProgressIndicator()
          : SingleChildScrollView(
            child: Wrap(
              spacing: 15,
              runSpacing: 20,
              children: List.generate(videosCount, (index) {
                final webScreen = InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(videoStringUrls[index]))),
                );
                
                return SizedBox(
                  width: 640,
                  height: 480,
                  child: webScreen,
                );
              }),
            ),
          ),
      ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Alert the police?'),
              content: const Text('Are you sure you want to alert the police?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Police have been alerted.'),
                      ),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }, 
      label: const Text(
        'Allert the police!', 
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          ),
      ),
      icon: const Icon(
        Icons.call, 
        color: Colors.white
        ),
      backgroundColor: Colors.red,
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


