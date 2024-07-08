import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';

class VolunteerDropdownWidget extends StatefulWidget {
  final void Function(Map<String, dynamic> selectedVolunteer) onSelected;
  final Map<String, dynamic>? initialValue;

  const VolunteerDropdownWidget({
    Key? key,
    required this.onSelected,
    this.initialValue,
  }) : super(key: key);

  @override
  _VolunteerDropdownWidgetState createState() =>
      _VolunteerDropdownWidgetState();
}

class _VolunteerDropdownWidgetState extends State<VolunteerDropdownWidget> {
  Future<List<Map<String, dynamic>>> fetchVolunteers() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Users').get();
    return querySnapshot.docs.map((doc) {
      return {
        'volunteerId': doc.id,
        'volunteerName': doc['name'],
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchVolunteers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: LinearProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No volunteers found'));
        } else {
          return DropdownSearch<Map<String, dynamic>>(
            items: snapshot.data!,
            itemAsString: (Map<String, dynamic> volunteer) =>
                volunteer['volunteerName'],
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: 'Search by volunteer name',
                ),
              ),
              itemBuilder: (context, volunteer, isSelected) {
                return ListTile(
                  title: Text(
                    volunteer['volunteerName'],
                    style: TextStyle(color: Colors.black),
                  ),
                );
              },
            ),
            onChanged: (selectedVolunteer) {
              if (selectedVolunteer != null) {
                widget.onSelected(selectedVolunteer);
              }
            },
            dropdownBuilder: (context, selectedItem) {
              return Text(selectedItem?['volunteerName'] ?? 'Select Volunteer');
            },
            selectedItem: widget.initialValue,
          );
        }
      },
    );
  }
}

/*
To use the VolunteerDropdownWidget, follow these steps:

1. Define a function to handle the selected volunteer:

void handleSelectedVolunteer(Map<String, dynamic> selectedVolunteer) {
  print('Selected Volunteer: ${selectedVolunteer['volunteerName']}');
}

2. Include the VolunteerDropdownWidget in your widget tree, passing the function defined above and optionally an initial value:

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Select Volunteer'),
    ),
    body: Center(
      child: VolunteerDropdownWidget(
        onSelected: handleSelectedVolunteer,
        initialValue: {
          'volunteerId': 'initialId',
          'volunteerName': 'Initial Volunteer',
        },
      ),
    ),
  );
}
*/
