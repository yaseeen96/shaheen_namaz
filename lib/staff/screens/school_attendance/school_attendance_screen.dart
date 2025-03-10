import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SchoolAttendanceScreen extends ConsumerWidget {
  const SchoolAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current Firebase user.
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    // Fetch current user document from Users collection.
    final userDocFuture = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .get();

    return FutureBuilder<DocumentSnapshot>(
      future: userDocFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
              body: Center(child: Text("User data not found")));
        }
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final schoolName = userData['school_name'] ?? "School";

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schoolName,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const Text(
                    "Today's Attendance",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: "Present"),
                  Tab(text: "Absent"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                SearchableStudentPaginationList(
                  schoolName: schoolName,
                  isPresent: true,
                ),
                SearchableStudentPaginationList(
                  schoolName: schoolName,
                  isPresent: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A widget that displays a nicely styled count card.
class CountCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color backgroundColor;
  const CountCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.count,
    this.backgroundColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Icon(
                icon,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    child: Text(label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        )),
                  ),
                  Text("$count",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A stateful widget that uses firebase_pagination to display a list of students
/// with an added search field for guardianNumber.
/// It also displays at the top a count area that shows:
///   - A total count (blue)
///   - A row with present (green) and absent (red) counts.
/// The Firestore queries include the search text (if provided).
class SearchableStudentPaginationList extends StatefulWidget {
  final String schoolName;
  final bool isPresent;
  const SearchableStudentPaginationList({
    Key? key,
    required this.schoolName,
    required this.isPresent,
  }) : super(key: key);

  @override
  _SearchableStudentPaginationListState createState() =>
      _SearchableStudentPaginationListState();
}

class _SearchableStudentPaginationListState
    extends State<SearchableStudentPaginationList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  /// Returns the start of today.
  DateTime get startOfToday {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Returns the start of tomorrow.
  DateTime get startOfTomorrow => startOfToday.add(const Duration(days: 1));

  /// Checks if the given [timestamp] falls on today.
  bool isTimestampToday(Timestamp? timestamp) {
    if (timestamp == null) return false;
    DateTime dt = timestamp.toDate();
    return dt.isAtSameMomentAs(startOfToday) ||
        (dt.isAfter(startOfToday) && dt.isBefore(startOfTomorrow));
  }

  /// Formats the [dob] (Timestamp) into a readable string.
  String formatDOB(Timestamp? dob) {
    if (dob == null) return "";
    return DateFormat('dd MMM, yyyy').format(dob.toDate());
  }

  /// Launches the phone dialer with the given [phoneNumber].
  void _launchCaller(String phoneNumber) async {
    // Prepend country code if missing.
    final formattedNumber =
        phoneNumber.startsWith('+') ? phoneNumber : "+91$phoneNumber";
    final Uri launchUri = Uri(scheme: 'tel', path: formattedNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $formattedNumber");
    }
  }

  /// Shows a nicely styled bottom modal sheet with student details.
  void _showStudentDetails(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Wrap(
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data['name'] ?? "No Name",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _detailRow("Guardian Name", data['guardianName'] ?? ''),
              _detailRow("Guardian Number", data['guardianNumber'] ?? ''),
              _detailRow("School Name", data['school_name'] ?? ''),
              _detailRow("DOB", formatDOB(data['dob'])),
              _detailRow("Class", data['class'] ?? data['className'] ?? ''),
              _detailRow("Section", data['section'] ?? ''),
              _detailRow(
                "Masjid Name",
                data['masjid_details'] is Map<String, dynamic>
                    ? data['masjid_details']['masjidName'] ?? ''
                    : '',
              ),
              _detailRow(
                "Cluster Number",
                data['masjid_details'] is Map<String, dynamic>
                    ? "c${data['masjid_details']['clusterNumber'] ?? ''}"
                    : '',
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close"),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// Helper method to build a detail row for the bottom modal sheet.
  static Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  /// Builds the widget for each student document.
  Widget _buildStudentItem(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // For the absent tab, skip items whose streak_last_modified is today.
    final Timestamp? streakTimestamp = data['streak_last_modified'];
    final bool isToday = isTimestampToday(streakTimestamp);
    if (widget.isPresent && !isToday) return const SizedBox.shrink();
    if (!widget.isPresent && isToday) return const SizedBox.shrink();

    // Get cluster marking.
    String clusterMark = "";
    if (data['masjid_details'] is Map<String, dynamic>) {
      final masjidDetails = data['masjid_details'] as Map<String, dynamic>;
      if (masjidDetails['clusterNumber'] != null) {
        clusterMark = "c${masjidDetails['clusterNumber']}";
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: () => _showStudentDetails(context, data),
        title: Text(data['name'] ?? "No Name"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Guardian: ${data['guardianName'] ?? ''}"),
            Text("Cluster: $clusterMark"),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {
            final guardianNumber = data['guardianNumber'] ?? "";
            if (guardianNumber.toString().isNotEmpty) {
              _launchCaller(guardianNumber);
            }
          },
        ),
      ),
    );
  }

  /// Builds a query for the list, including search on guardianNumber if provided.
  Query _buildQuery() {
    Query baseQuery = FirebaseFirestore.instance
        .collection('students')
        .where('school_name', isEqualTo: widget.schoolName)
        .orderBy('streak_last_modified', descending: true);

    if (_searchText.isNotEmpty) {
      baseQuery = baseQuery.where('guardianNumber', isEqualTo: _searchText);
    }

    if (widget.isPresent) {
      // For present, filter by streak_last_modified within today.
      return baseQuery
          .where('streak_last_modified',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
          .where('streak_last_modified',
              isLessThan: Timestamp.fromDate(startOfTomorrow));
    } else {
      // For absent, query all and then filter locally.
      return baseQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Query query = _buildQuery();

    // Build a count query that respects the search text.
    Query countQuery = FirebaseFirestore.instance
        .collection('students')
        .where('school_name', isEqualTo: widget.schoolName);
    if (_searchText.isNotEmpty) {
      countQuery = countQuery.where('guardianNumber', isEqualTo: _searchText);
    }

    // Count area that shows:
    // - Total students (blue)
    // - Present (green) and Absent (red) counts
    Widget countArea = FutureBuilder<QuerySnapshot>(
      future: countQuery.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }
        int totalCount = 0;
        int presentCount = 0;
        int absentCount = 0;
        if (snapshot.hasData) {
          totalCount = snapshot.data!.docs.length;
          presentCount = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final Timestamp? streakTimestamp = data['streak_last_modified'];
            return isTimestampToday(streakTimestamp);
          }).length;
          absentCount = totalCount - presentCount;
        }
        return Column(
          children: [
            // Total count card (full width)
            CountCard(
              icon: Icons.people,
              label: "Total Students",
              count: totalCount,
              backgroundColor: Colors.blue,
            ),
            // Row of present and absent count cards.
            Row(
              children: [
                Expanded(
                  child: CountCard(
                    icon: Icons.check_circle,
                    label: "Present",
                    count: presentCount,
                    backgroundColor: Colors.green,
                  ),
                ),
                Expanded(
                  child: CountCard(
                    icon: Icons.cancel,
                    label: "Absent",
                    count: absentCount,
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    return Column(
      children: [
        // Search field for guardianNumber.
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            keyboardType: TextInputType.number,
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search by Guardian Number',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _searchText = _searchController.text.trim();
                  });
                },
              ),
            ),
            onSubmitted: (value) {
              setState(() {
                _searchText = value.trim();
              });
            },
          ),
        ),
        // Count area (total, present, absent).
        countArea,
        // The paginated list.
        Expanded(
          child: FirestorePagination(
            query: query,
            key: ValueKey(
                "${widget.schoolName}-${widget.isPresent}-$_searchText"),
            viewType: ViewType.list,
            itemBuilder: (context, doc, index) {
              return _buildStudentItem(context, doc);
            },
            onEmpty: const Center(child: Text("No students found")),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }
}
