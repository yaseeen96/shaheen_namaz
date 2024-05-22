import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomDropDown extends StatelessWidget {
  const CustomDropDown({
    super.key,
    required this.ref,
    required this.menuItems,
    this.onChanged,
  });

  final WidgetRef ref;
  final List<QueryDocumentSnapshot<Object?>> menuItems;
  final Function(QueryDocumentSnapshot<Object?>?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: DropdownSearch<QueryDocumentSnapshot<Object?>>(
        itemAsString: (item) => item.get("name"),
        dropdownBuilder: (context, selectedItem) {
          return const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Please select a masjid",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          );
        },
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: const TextFieldProps(
            decoration: InputDecoration(labelText: "Name"),
          ),
          itemBuilder: (context, item, isSelected) {
            return ListTile(
              title: Text(
                item.get("name"),
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            );
          },
        ),
        dropdownDecoratorProps: DropDownDecoratorProps(
            baseStyle: TextStyle(
          color: Colors.black,
        )),
        onChanged: (value) {
          if (onChanged != null) {
            onChanged!(value);
          } else {
            return;
          }
        },
        items: menuItems,
        selectedItem: (menuItems.isEmpty) ? null : menuItems[0],
      ),
    );
  }
}
