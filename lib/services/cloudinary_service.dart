import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class CloudinaryService {
  final String cloudName = 'fakestore';
  final String apiKey = '329645947786541';
  final String apiSecret = '0PvCO0r7iRjlnKoqSMa8ygRwCyk';
  final String uploadPreset = 'new-preset';

  // Upload the file and return URL
  Future<String> uploadFile(File file) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');

    // Determine the mime type of the file
    final mimeType = lookupMimeType(file.path);
    if (mimeType == null) {
      throw Exception('Unable to determine file type');
    }

    // Set the resource type to audio if the file is an audio file
    String resourceType =
        'auto'; // Default to 'auto' (Cloudinary will figure it out)

    if (mimeType.startsWith('audio')) {
      resourceType = 'audio';
    }

    // Prepare the multipart request
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['resource_type'] =
          resourceType // Set resource type for audio files
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

    // Add authentication and timestamp
    request.fields['api_key'] = apiKey;
    request.fields['timestamp'] =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    // Send the request
    final response = await request.send();

    print('Cloudinary Response code: ${response.statusCode}');

    // Parse response
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);
      return data['secure_url']; // Return the uploaded file URL
    } else {
      final responseData = await response.stream.bytesToString();
      final errorData = jsonDecode(responseData);
      throw Exception('Error: ${errorData['error']['message']}');
    }
  }
}
