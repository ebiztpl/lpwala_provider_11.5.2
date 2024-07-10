// To parse this JSON data, do
//
//     final signupWithOtpResponse = signupWithOtpResponseFromJson(jsonString);

import 'dart:convert';

SignupWithOtpResponse signupWithOtpResponseFromJson(String str) => SignupWithOtpResponse.fromJson(json.decode(str));

String signupWithOtpResponseToJson(SignupWithOtpResponse data) => json.encode(data.toJson());

class SignupWithOtpResponse {
  bool status;
  String data;

  SignupWithOtpResponse({
    required this.status,
    required this.data,
  });

  factory SignupWithOtpResponse.fromJson(Map<String, dynamic> json) => SignupWithOtpResponse(
    status: json["status"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data,
  };
}
