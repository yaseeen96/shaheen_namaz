import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class MasjidPopup extends StatefulWidget {
  const MasjidPopup({
    super.key,
    this.masjidName,
    this.clusterName,
    required this.onPressed,
    required this.actionText,
  });
  final String? masjidName;
  final String? clusterName;
  final void Function(String masjidName, int clusterNumber) onPressed;
  final String actionText;

  @override
  State<MasjidPopup> createState() => _MasjidPopupState();
}

class _MasjidPopupState extends State<MasjidPopup> {
  final TextEditingController masjidNameController = TextEditingController();
  final TextEditingController clusterNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    masjidNameController.text = widget.masjidName ?? "";
    clusterNameController.text = widget.clusterName ?? "";
    super.initState();
  }

  @override
  void dispose() {
    masjidNameController.dispose();
    clusterNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Please Enter the Name of Masjid'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: ListBody(
            children: <Widget>[
              TextFormField(
                controller: masjidNameController,
                decoration: const InputDecoration(
                  label: Text("Name of Masjid"),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const Gap(10),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: clusterNameController,
                decoration: const InputDecoration(
                  label: Text("Cluster Number"),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a cluster number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            context.pop();
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onPressed(masjidNameController.text,
                  int.parse(clusterNameController.text));
              context.pop();
            }
          },
          child: Text(widget.actionText),
        ),
      ],
    );
  }
}
