import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:shaheen_namaz/admin/widgets/masjid_dropdown.dart';
import 'package:shaheen_namaz/admin/widgets/volunteer_dropdown.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

class EditStudentDialog extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditStudentDialog({
    super.key,
    required this.data,
    required this.studentId,
  });

  @override
  _EditStudentDialogState createState() => _EditStudentDialogState();
  final String studentId;
}

class _EditStudentDialogState extends State<EditStudentDialog> {
  late TextEditingController nameController;
  late TextEditingController classController;
  late TextEditingController dobController;
  late TextEditingController addressController;
  late TextEditingController guardianNameController;
  late TextEditingController guardianNumberController;
  late Map<String, dynamic> selectedMasjid;
  late Map<String, dynamic> selectedVolunteer;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['name']);
    classController = TextEditingController(text: widget.data['class']);
    dobController = TextEditingController(
        text: (widget.data['dob'] as Timestamp).toDate().toString());
    addressController = TextEditingController(text: widget.data['address']);
    guardianNameController =
        TextEditingController(text: widget.data['guardianName']);
    guardianNumberController =
        TextEditingController(text: widget.data['guardianNumber']);
    selectedMasjid = widget.data['masjid_details'];
    selectedVolunteer = widget.data['volunteer'];
  }

  @override
  void dispose() {
    nameController.dispose();
    classController.dispose();
    dobController.dispose();
    addressController.dispose();
    guardianNameController.dispose();
    guardianNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Student Details'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: classController,
                decoration: const InputDecoration(labelText: 'Class'),
              ),
              GestureDetector(
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: (widget.data['dob'] as Timestamp).toDate(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (selectedDate != null) {
                    setState(() {
                      dobController.text = selectedDate.toString();
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: dobController,
                    decoration:
                        const InputDecoration(labelText: 'Date of Birth'),
                  ),
                ),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: guardianNameController,
                decoration: const InputDecoration(labelText: 'Guardian Name'),
              ),
              TextField(
                controller: guardianNumberController,
                decoration: const InputDecoration(labelText: 'Guardian Number'),
              ),
              const Gap(10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Masjid',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  MasjidDropdownWidget(
                    onSelected: (masjid) {
                      selectedMasjid = masjid;
                    },
                    initialValue: widget.data['masjid_details'],
                  ),
                ],
              ),
              const Gap(10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Volunteer',
                    style: TextStyle(fontSize: 16),
                  ),
                  VolunteerDropdownWidget(
                    onSelected: (volunteer) {
                      selectedVolunteer = volunteer;
                    },
                    initialValue: widget.data['volunteer'],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel")),
        TextButton(
          onPressed: () async {
            final updatedData = {
              'name': nameController.text,
              'class': classController.text,
              'dob': Timestamp.fromDate(DateTime.parse(dobController.text)),
              'address': addressController.text,
              'guardianName': guardianNameController.text,
              'guardianNumber': guardianNumberController.text,
              'masjid': FirebaseFirestore.instance
                  .doc('Masjid/${selectedMasjid['masjidId']}'),
              'masjid_details': selectedMasjid,
              'volunteer': selectedVolunteer,
              // Ensure to include the fields that are already in the document but not edited
              'streak': widget.data['streak'],
              'streak_last_modified': widget.data['streak_last_modified'],
            };

            // Update the document in Firestore
            try {
              await FirebaseFirestore.instance
                  .collection('students')
                  .doc(widget.studentId)
                  .update(updatedData);
              logger.i("Student data updated: $updatedData");
            } catch (e) {
              logger.e("Failed to update student data: $e");
            }
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// {volunteerId: "9bGc3ApBdEZwzecS3E9Y6As8YtN2", volunteerName: "Yaseen"}