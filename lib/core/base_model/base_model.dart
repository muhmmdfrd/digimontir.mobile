class BaseModel<T> {
  final String message;
  final T? data;

  const BaseModel({required this.message, required this.data});

  factory BaseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return BaseModel<T>(
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? fromJsonT(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
