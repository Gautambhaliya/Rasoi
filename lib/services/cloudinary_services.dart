import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = "dfzquxf4w";
  static const String apiKey = "326373291412777";
  static const String uploadPreset = "file_upload";

  static Future<String?> uploadImage(File imageFile) async {
    final cloudinaryUrl =
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      return jsonResponse['secure_url']; // Cloudinary image URL
    } else {
      print("Image upload failed: ${response.reasonPhrase}");
      return null;
    }
  }
}
