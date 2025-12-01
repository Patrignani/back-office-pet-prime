class Paginator<T> {
  final List<T> data;
  final int totalCount;
  final int totalPage;
  final int? nextPage;
  final int? previousPage;

  Paginator({
    required this.data,
    required this.totalCount,
    required this.totalPage,
    this.nextPage,
    this.previousPage,
  });

  factory Paginator.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) convert,
  ) {
    return Paginator(
      data: (json['data'] as List).map((e) => convert(e as Map<String, dynamic>)).toList(),
      totalCount: json['totalCount'],
      totalPage: json['totalPage'],
      nextPage: json['nextPage'],
      previousPage: json['previousPage'],
    );
  }
}
