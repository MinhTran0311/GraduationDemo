class Endpoints {
  Endpoints._();

  // base url
  static const String baseUrl = "http://192.168.20.166:3000/minh";

  static const String upload = baseUrl + "/upload";
  static const String getHistory = baseUrl + "/history";

  // receiveTimeout
  static const int receiveTimeout = 30000;

  // connectTimeout
  static const int connectionTimeout = 60000;

  // booking endpoints
  static const String getPosts = baseUrl + "/posts";
}