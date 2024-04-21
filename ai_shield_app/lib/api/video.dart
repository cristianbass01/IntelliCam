class VideoApi {
  static Future<List<String>> getVideosPaths() async {
    await Future.delayed(Duration(seconds: 1));
    List<String> paths = List<String>.generate(4, (index) => 'https://backend-aeh7hwqzuq-oe.a.run.app');
    return paths;
  }
}
