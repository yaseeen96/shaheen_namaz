import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';

class SchoolDropdownWidget extends StatefulWidget {
  final void Function(String selectedSchool) onSelected;
  final String? initialValue;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const SchoolDropdownWidget({
    super.key,
    required this.onSelected,
    this.initialValue,
    this.validator,
    this.onSaved,
  });

  @override
  _SchoolDropdownWidgetState createState() => _SchoolDropdownWidgetState();
}

class _SchoolDropdownWidgetState extends State<SchoolDropdownWidget> {
  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      items: Constants.schools,
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: const TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Search by school name',
          ),
        ),
        itemBuilder: (context, school, isSelected) {
          return ListTile(
            title: Text(school),
          );
        },
      ),
      onChanged: (selectedSchool) {
        if (selectedSchool != null) {
          widget.onSelected(selectedSchool);
        }
      },
      dropdownBuilder: (context, selectedItem) {
        return Text(selectedItem ?? 'Select School');
      },
      selectedItem: widget.initialValue,
      validator: widget.validator,
      onSaved: widget.onSaved,
    );
  }
}
