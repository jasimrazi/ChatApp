import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  final String cloudName =
      'fakestore'; 
  final String apiKey =
      '329645947786541'; 
  final String apiSecret =
      '0PvCO0r7iRjlnKoqSMa8ygRwCyk'; 
  final String uploadPreset =
      'new-preset'; 


  //Upload the image and get URL in return
  Future<String> uploadImage(File imageFile) async {
    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    // Convert image file to a multipart request
    final mimeType = lookupMimeType(imageFile.path);
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
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
      return data['secure_url']; // Return the uploaded image URL
    } else {
      final responseData = await response.stream.bytesToString();
      final errorData = jsonDecode(responseData);
      throw Exception('Error: ${errorData['error']['message']}');
    }
  }

  
}
