// core/network/mock_api_client.dart
import 'dart:convert';

import 'package:flutter/services.dart';

class MockApiClient {
  Future<dynamic> get(String assetPath, {int latencyMs = 600}) async {
    await Future.delayed(Duration(milliseconds: latencyMs));
    final response = await rootBundle.loadString('assets/mock/$assetPath');
    return jsonDecode(response);
  }
}
