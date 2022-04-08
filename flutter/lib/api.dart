import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class API {
  static final Uri baseUrl = Platform.isAndroid || Platform.isIOS ? Uri.parse('http://10.0.2.2:3000') : Uri.parse('http://localhost:3000');

  final String token;
  final String userId;

  const API({ required this.token, required this.userId });

  Future<List<String>?> getWords({ int amount = 10 }) async {
    var response = await get('/words?amount=$amount');
    if (response.statusCode == 200) {
      return List.from(jsonDecode(response.body));
    }
    return null;
  }
  
  Future<List<String>?> getSavedWords() async {
    var response = await get('/users/$userId/favorites');
    if (response.statusCode == 200) {
      return List.from(jsonDecode(response.body));
    }
    return null;
  }
  
  Future<bool> addSavedWord(String word) async {
    var response = await post('/users/$userId/favorites/$word');
    return response.statusCode == 200;
  }
  
  Future<bool> removeSavedWord(String word) async {
    var response = await delete('/users/$userId/favorites/$word');
    return response.statusCode == 200;
  }

  

  Map<String, String> headers({ Map<String, String>? extra }) => { 'Authorization': 'Bearer $token', ... extra ?? {} };

  Future<http.Response> get(String url, { bool withHeaders = true }) => http.get(API.url(url), headers: withHeaders ? headers() : null);
  Future<http.Response> post(String url, { Object? body, Encoding? encoding, bool withHeaders = true }) => http.post(API.url(url), body: body, encoding: encoding, headers: withHeaders ? headers() : null);
  Future<http.Response> delete(String url, { Object? body, Encoding? encoding, bool withHeaders = true }) => http.delete(API.url(url), body: body, encoding: encoding, headers: withHeaders ? headers() : null);
  Future<http.Response> put(String url, { Object? body, Encoding? encoding, bool withHeaders = true }) => http.put(API.url(url), body: body, encoding: encoding, headers: withHeaders ? headers() : null);
  Future<http.Response> patch(String url, { Object? body, Encoding? encoding, bool withHeaders = true }) => http.patch(API.url(url), body: body, encoding: encoding, headers: withHeaders ? headers() : null);



  static Uri url(String url) => baseUrl.resolve(url);
  
  static Future<API?> login(String username, String password) async {
    http.Response response = await http.post(url('/login'), body: {
      'username': username,
      'password': password,
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return API(token: responseData['token'], userId: responseData['user']['id'].toString());
    } else {
      return null;
    }
  }
  
  static Future<bool> register(String username, String password) async {
    http.Response response = await http.post(url('/register'), body: {
      'username': username,
      'password': password,
    });
    
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}