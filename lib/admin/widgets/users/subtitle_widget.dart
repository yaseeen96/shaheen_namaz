import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/admin/providers/get_masjids_provider.dart';
import 'package:shaheen_namaz/admin/providers/get_users_provider.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';

class SubtitleWidget extends ConsumerWidget {
  const SubtitleWidget({
    super.key,
    required this.masjidId,
    required this.userId,
  });
  final String masjidId;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masjidName = ref.watch(getMasjidNameProvider(masjidId));
    return masjidName.when(
      data: (data) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        child: Chip(
          label: Text(data),
          onDeleted: () async {
            try {
              final DocumentReference masjidRef =
                  FirebaseFirestore.instance.collection("Masjid").doc(masjidId);
              await FirebaseFirestore.instance
                  .collection("Users")
                  .doc(userId)
                  .update(
                {
                  "masjid_allocated": FieldValue.arrayRemove(
                    [masjidRef],
                  ),
                },
              );
              ref.invalidate(getUsersProvider);
            } catch (err) {
              logger.e("Error removing masjidL $err");
            }
          },
        ),
      ),
      error: (err, stk) => Text("NO Data found $err"),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
