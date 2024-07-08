import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';

class MasjidDropdownWidget extends StatefulWidget {
  final void Function(Map<String, dynamic> selectedMasjid) onSelected;
  final Map<String, dynamic>? initialValue;

  const MasjidDropdownWidget({
    Key? key,
    required this.onSelected,
    this.initialValue,
  }) : super(key: key);

  @override
  _MasjidDropdownWidgetState createState() => _MasjidDropdownWidgetState();
}

class _MasjidDropdownWidgetState extends State<MasjidDropdownWidget> {
  Future<List<Map<String, dynamic>>> fetchMasjids() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Masjid').get();
    return querySnapshot.docs.map((doc) {
      return {
        'masjidId': doc.id,
        'masjidName': doc['name'],
        'clusterNumber': doc['cluster_number'],
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchMasjids(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: LinearProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No masjids found'));
        } else {
          return DropdownSearch<Map<String, dynamic>>(
            items: snapshot.data!,
            itemAsString: (Map<String, dynamic> masjid) => masjid['masjidName'],
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: 'Search by masjid name',
                ),
              ),
              itemBuilder: (context, masjid, isSelected) {
                return ListTile(
                  title: Text(
                    masjid['masjidName'],
                    style: TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    'Cluster Number: ${masjid['clusterNumber']}',
                    style: TextStyle(color: Colors.black),
                  ),
                );
              },
            ),
            onChanged: (selectedMasjid) {
              if (selectedMasjid != null) {
                widget.onSelected(selectedMasjid);
              }
            },
            dropdownBuilder: (context, selectedItem) {
              return Text(selectedItem?['masjidName'] ?? 'Select Masjid');
            },
            selectedItem: widget.initialValue,
          );
        }
      },
    );
  }
}
