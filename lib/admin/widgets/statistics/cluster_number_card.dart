import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

class ClusterNumberCard extends ConsumerWidget {
  const ClusterNumberCard({
    super.key,
    required this.title,
    required this.downloadUrl,
    required this.registeredStudentsProvider,
    required this.attendanceStudentsProvider,
  });

  final String title;
  final String? downloadUrl;
  final AutoDisposeFutureProvider<int> registeredStudentsProvider;
  final AutoDisposeFutureProvider<int> attendanceStudentsProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combinedProvider = FutureProvider.autoDispose<List<int>>((ref) async {
      final registeredStudentsFuture =
          ref.watch(registeredStudentsProvider.future);
      final attendanceStudentsFuture =
          ref.watch(attendanceStudentsProvider.future);
      return Future.wait([registeredStudentsFuture, attendanceStudentsFuture]);
    });

    final combinedAsyncValue = ref.watch(combinedProvider);

    return combinedAsyncValue.when(
      data: (data) {
        final registeredStudents = data[0];
        final attendanceStudents = data[1];
        return Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Registered Students: $registeredStudents",
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Today's Attendance: $attendanceStudents",
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
                  color: Colors.blue,
                ),
                onPressed: () async {
                  if (downloadUrl != null) {
                    await launchUrl(
                      Uri.parse(
                        downloadUrl!,
                      ),
                      webOnlyWindowName: "_blank",
                    );
                  } else {
                    return;
                  }
                },
              ),
            ),
          ],
        );
      },
      loading: () => ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[
              Colors.grey[500]!,
              Colors.grey[400]!,
              Colors.grey[500]!,
            ],
            stops: const <double>[0.0, 0.5, 1.0],
          ).createShader(bounds);
        },
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width / 5,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10)),
                    height: 30,
                  ),
                  const Gap(20),
                  Container(
                    width: MediaQuery.sizeOf(context).width / 5,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10)),
                    height: 20,
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
                  color: Colors.blue,
                ),
                onPressed: () async {
                  if (downloadUrl != null) {
                    await launchUrl(
                      Uri.parse(
                        downloadUrl!,
                      ),
                      webOnlyWindowName: "_blank",
                    );
                  } else {
                    return;
                  }
                },
              ),
            ),
          ],
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Text("Error: $error"),
      ),
    );
  }
}
