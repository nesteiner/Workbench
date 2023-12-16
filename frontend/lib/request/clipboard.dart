class PostTextRequest {
  final String text;
  final int userid;

  PostTextRequest({required this.text, required this.userid});

  Map<String, dynamic> toJson() {
    return {
      "text": text,
      "userid": userid
    };
  }
}