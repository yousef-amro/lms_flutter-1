class PaginatedData<T> {
  final List<T> dataList;
  final int? nextPage;

  PaginatedData({required this.dataList, this.nextPage = 1});

  factory PaginatedData.empty() {
    return PaginatedData(dataList: [], nextPage: null);
  }

  factory PaginatedData.fromJson({
    required Map<String, dynamic> json,
    required List<T> dataList,
  }) {
    return PaginatedData(dataList: dataList, nextPage: json['next']);
  }

  PaginatedData<T> copyWith(List<T>? dataList, int? nextPage) {
    return PaginatedData(
      dataList: dataList ?? this.dataList,
      nextPage: nextPage,
    );
  }
}
