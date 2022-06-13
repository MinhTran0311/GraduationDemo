class Endpoints {
  Endpoints._();

  // base url
  static const String baseUrl = "http://ec2-3-145-105-42.us-east-2.compute.amazonaws.com:3000/thuan";

  static const String upload = baseUrl + "/upload";
  static const String getHistory = baseUrl + "/history";

  // receiveTimeout
  static const int receiveTimeout = 50000;

  // connectTimeout
  static const int connectionTimeout = 60000;

  // booking endpoints
  static const String getPosts = baseUrl + "/posts";
}