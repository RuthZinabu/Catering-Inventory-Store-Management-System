/// Standardized API response wrapper
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final PaginationMeta? pagination;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.pagination,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'],
      errors: json['errors'],
      pagination: json['data'] != null && json['data']['pagination'] != null
          ? PaginationMeta.fromJson(json['data']['pagination'])
          : null,
    );
  }

  /// Check if the response indicates success
  bool get isSuccess => success && data != null;
  
  /// Check if the response has errors
  bool get hasErrors => errors != null && errors!.isNotEmpty;
  
  /// Get error messages as a list
  List<String> get errorMessages {
    if (!hasErrors) return [];
    
    final List<String> messages = [];
    errors!.forEach((key, value) {
      if (value is List) {
        messages.addAll(value.map((e) => e.toString()));
      } else {
        messages.add(value.toString());
      }
    });
    
    return messages;
  }
}

/// Pagination metadata
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
      from: json['from'],
      to: json['to'],
    );
  }

  /// Check if there are more pages available
  bool get hasNextPage => currentPage < lastPage;
  
  /// Check if there are previous pages
  bool get hasPreviousPage => currentPage > 1;
  
  /// Get next page number (null if no next page)
  int? get nextPage => hasNextPage ? currentPage + 1 : null;
  
  /// Get previous page number (null if no previous page)
  int? get previousPage => hasPreviousPage ? currentPage - 1 : null;

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'from': from,
      'to': to,
    };
  }
}