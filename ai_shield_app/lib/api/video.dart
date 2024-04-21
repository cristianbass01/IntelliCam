
import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoApi {
  static Future<List<String>> getVideosPaths() async {
    //final response = await http.get(Uri.parse('https://backend-aeh7hwqzuq-oe.a.run.app/endpoints'));
    //
    //if (response.statusCode == 200) {
    //  final data = json.decode(response.body);
    //  List<String> paths = data['endpoints'];
    //  return paths;
    //} else {
    //  throw Exception('Failed to load video paths');
    //}
    List<String> paths = [
      "https://backend-aeh7hwqzuq-oe.a.run.app/video_feed",
      "https://static-aeh7hwqzuq-oe.a.run.app/video3",
      "https://static-aeh7hwqzuq-oe.a.run.app/video1",
      "https://static-aeh7hwqzuq-oe.a.run.app/video2"
    ];
    return paths;
  }
}


