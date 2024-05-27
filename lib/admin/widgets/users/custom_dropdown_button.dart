import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

class CustomDropDown extends StatefulWidget {
  const CustomDropDown({
    super.key,
    required this.ref,
    required this.menuItems,
    this.onChanged,
    this.selectedItems = const [],
    this.onMultiSelectChanged,
    this.isMultiSelect = false,
  });

  final WidgetRef ref;
  final List<QueryDocumentSnapshot<Object?>> menuItems;
  final List<QueryDocumentSnapshot<Object?>> selectedItems;

  final Function(QueryDocumentSnapshot<Object?>?)? onChanged;
  final Function(List<QueryDocumentSnapshot<Object?>?>)? onMultiSelectChanged;
  final bool isMultiSelect;

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: (widget.isMultiSelect)
          ? DropdownSearch<QueryDocumentSnapshot<Object?>>.multiSelection(
              itemAsString: (item) => item.get("cluster_number").toString(),
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
              popupProps: PopupPropsMultiSelection.menu(
                showSearchBox: true,
                searchFieldProps: const TextFieldProps(
                  decoration:
                      InputDecoration(labelText: "Search by cluster Number"),
                ),
                itemBuilder: (context, item, isSelected) {
                  return ListTile(
                    title: Text(
                      item.get("name"),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      item.get("cluster_number").toString(),
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
                if (widget.onMultiSelectChanged != null) {
                  logger.i(value);
                  widget.onMultiSelectChanged!(value);
                } else {
                  return;
                }
              },
              items: widget.menuItems,
              selectedItems: widget.selectedItems,
            )
          // no multiselect starts from here
          : DropdownSearch<QueryDocumentSnapshot<Object?>>(
              itemAsString: (item) => item.get("cluster_number").toString(),
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
                  decoration:
                      InputDecoration(labelText: "Search by cluster number"),
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
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                } else {
                  return;
                }
              },
              items: widget.menuItems,
              // selectedItem: (selectedItems.isEmpty) ? null : selectedItems[0],
            ),
    );
  }
}
