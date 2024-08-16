import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/staff/providers/providers.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

class ManualAttendance extends ConsumerStatefulWidget {
  const ManualAttendance({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManualAttendanceState();
}

class _ManualAttendanceState extends ConsumerState<ManualAttendance> {
  final TextEditingController _searchController = TextEditingController();
  late Query<Object?> _baseQuery;
  Query<Object?>? _currentQuery;
  Key _paginationKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _initializeQuery();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void onTap(String faceId) async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    if (!mounted) return;

    ref.read(selectedFaceIdProvider.notifier).state = faceId;
    logger.i("face Id: $faceId");

    context.pushNamed(
      "camera_preview",
      pathParameters: {
        "isAttendenceTracking": "false",
        "isEdit": "false",
        "isManual": "true",
      },
      extra: firstCamera,
    );
  }

  Future<void> _initializeQuery() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    if (userDoc.exists && userDoc.data()?['imam_details'] != null) {
      _baseQuery = FirebaseFirestore.instance.collection("students");
    } else {
      _baseQuery = FirebaseFirestore.instance.collection("students").where(
          "volunteer.volunteerId",
          isEqualTo: FirebaseAuth.instance.currentUser?.uid);
    }

    setState(() {
      _currentQuery = _baseQuery;
      _paginationKey = UniqueKey(); // Force rebuild
    });
  }

  void _onSearchChanged() {
    setState(() {
      if (_searchController.text.isNotEmpty) {
        _currentQuery = _baseQuery.where("guardianNumber",
            isEqualTo: _searchController.text);
      } else {
        _currentQuery = _baseQuery;
      }
      // Update the key to force FirestorePagination to rebuild
      _paginationKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: TextField(
          controller: _searchController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Search by guardian number',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white54),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _currentQuery != null
          ? FirestorePagination(
              key: _paginationKey,
              query: _currentQuery!,
              itemBuilder: (context, doc, index) {
                final data = doc.data() as Map<String, dynamic>;

                return ListTile(
                    onTap: () {
                      onTap(doc.id);
                    },
                    title: Text(
                      "${data["name"]}",
                    ),
                    subtitle: Text(
                      "${data["guardianNumber"]}",
                    ));
              },
              onEmpty: const Center(
                child: Text('No results found'),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
