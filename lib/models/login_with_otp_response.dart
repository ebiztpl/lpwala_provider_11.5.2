// To parse this JSON data, do
//
//     final loginWithOtpResponse = loginWithOtpResponseFromJson(jsonString);

import 'dart:convert';

LoginWithOtpResponse loginWithOtpResponseFromJson(String str) => LoginWithOtpResponse.fromJson(json.decode(str));

String loginWithOtpResponseToJson(LoginWithOtpResponse data) => json.encode(data.toJson());

class LoginWithOtpResponse {
  String message;
  String contactNumber;
  String otp;
  String userType;
  bool status;

  LoginWithOtpResponse({
    required this.message,
    required this.contactNumber,
    required this.otp,
    required this.userType,
    required this.status,
  });

  factory LoginWithOtpResponse.fromJson(Map<String, dynamic> json) => LoginWithOtpResponse(
    message: json["message"],
    contactNumber: json["contact_number"],
    otp: json["otp"],
    userType: json["user_type"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "contact_number": contactNumber,
    "otp": otp,
    "user_type": userType,
    "status": status,
  };
}
