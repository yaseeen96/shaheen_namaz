import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class NumberCard extends ConsumerWidget {
  const NumberCard({
    super.key,
    required this.title,
    required this.downloadUrl,
    required this.provider,
  });

  final String title;
  final String? downloadUrl;
  final AutoDisposeFutureProvider provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numberAsyncValue = ref.watch(provider);
    return numberAsyncValue.when(
      data: (data) {
        return Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Constants.secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    (data is Map<String, int>)
                        ? "${data["todayAttendance"]} / ${data["totalStudents"]}"
                        : "$data",
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
            Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(
                    Icons.download,
                    color: Colors.white54,
                  ),
                  onPressed: () async {
                    if (downloadUrl != null) {
                      await launchUrl(
                          Uri.parse(
                            downloadUrl!,
                          ),
                          webOnlyWindowName: "_blank");
                    } else {
                      return;
                    }
                  },
                ))
          ],
        );
      },
      loading: () => const ShimmerLoadingWidget(),
      error: (error, stackTrace) => Center(
        child: Text("Error: $error"),
      ),
    );
  }
}

class ShimmerLoadingWidget extends StatelessWidget {
  const ShimmerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300.withOpacity(0.1),
      highlightColor: Colors.grey.shade100.withOpacity(0.1),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Constants.secondaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 16,
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 30,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 24,
              height: 24,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
