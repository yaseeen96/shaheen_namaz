import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: avoid_web_libraries_in_flutter

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
                    "$data",
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
                          webOnlyWindowName: "_blank");
                    } else {
                      return;
                    }
                  },
                ))
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => const Center(
        child: Text("Error"),
      ),
    );
  }
}
