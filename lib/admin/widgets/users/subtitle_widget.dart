import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/admin/providers/get_masjids_provider.dart';

class SubtitleWidget extends ConsumerWidget {
  const SubtitleWidget({super.key, required this.masjidId});
  final String masjidId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masjidName = ref.watch(getMasjidNameProvider(masjidId));
    return masjidName.when(
      data: (data) => Chip(label: Text(data)),
      error: (err, stk) => Text("NO Data found $err"),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
