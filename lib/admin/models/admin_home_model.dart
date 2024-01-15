class AdminHomeModel {
  final int selectedIndex;
  AdminHomeModel({this.selectedIndex = 1});

  AdminHomeModel copyWith({int? selectedIndex}) {
    return AdminHomeModel(selectedIndex: selectedIndex ?? this.selectedIndex);
  }
}
