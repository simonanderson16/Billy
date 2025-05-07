import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ReceiptScanningService {
  static const String _baseUrl =
      'https://api.taggun.io/api/receipt/v1/verbose/file';

  static Future<Map<String, dynamic>> scanReceipt(File imageFile) async {
    final apiKey = dotenv.env['TAGGUN_API_KEY'];
    if (apiKey == null) {
      throw Exception('Taggun API key not found in environment variables');
    }

    final request =
        http.MultipartRequest('POST', Uri.parse(_baseUrl))
          ..headers.addAll({'Accept': 'application/json', 'apikey': apiKey})
          ..files.add(await http.MultipartFile.fromPath('file', imageFile.path))
          ..fields['refresh'] = 'false'
          ..fields['incognito'] = 'false'
          ..fields['ipAddress'] = '32.4.2.223'
          ..fields['language'] = 'en'
          ..fields['extractLineItems'] = 'true'
          ..fields['extractMerchantName'] = 'true'
          ..fields['extractDate'] = 'true'
          ..fields['extractTotal'] = 'true'
          ..fields['extractTax'] = 'true';

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseBody);
    } else {
      throw Exception(
        'Failed to scan receipt: ${response.statusCode} - $responseBody',
      );
    }
  }
}
