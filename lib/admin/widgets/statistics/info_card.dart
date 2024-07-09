import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class InfoCard extends ConsumerWidget {
  const InfoCard(
      {super.key,
      required this.icon,
      required this.title,
      required this.provider,
      required this.downloadUrl,
      required this.clusterNumber});

  final Icon icon;
  final String title;

  final AutoDisposeFutureProvider provider;
  final String downloadUrl;
  final int clusterNumber;

  Color getProgressLineColor(int percentage) {
    if (percentage >= 75) {
      return Colors.green;
    } else if (percentage >= 50) {
      return Colors.yellow;
    } else if (percentage >= 25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numberAsyncValue = ref.watch(provider);
    return numberAsyncValue.when(
      data: (data) {
        final numOfPresent = data["todayAttendance"];
        final totalStudents = data["totalStudents"];
        final doublePercentage = (numOfPresent / totalStudents) * 100;
        final percentage = doublePercentage.ceil();
        final dynamicProgressLineColor = getProgressLineColor(percentage);
        return Container(
          padding: const EdgeInsets.all(Constants.defaultPadding),
          decoration: const BoxDecoration(
            color: Constants.secondaryColor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(Constants.defaultPadding * 0.75),
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        color: Constants.bgColor,
                        borderRadius:
                            BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Text("$clusterNumber")),
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.white54),
                    onPressed: () async {
                      await launchUrl(
                          Uri.parse(
                            downloadUrl,
                          ),
                          webOnlyWindowName: "_blank");
                    },
                  )
                ],
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              ProgressLine(
                color: dynamicProgressLineColor,
                percentage: percentage,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$numOfPresent present",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.white70),
                  ),
                  Text(
                    "${totalStudents!} in total",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.white),
                  ),
                ],
              )
            ],
          ),
        );
      },
      loading: () => const ShimmerLoadingWidget(),
      error: (error, stackTrace) => Center(
        child: Text("$error"),
      ),
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    this.color = Constants.primaryColor,
    required this.percentage,
  });

  final Color? color;
  final int? percentage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 5,
          decoration: BoxDecoration(
            color: color!.withOpacity(0.1),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => Container(
            width: constraints.maxWidth * (percentage! / 100),
            height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ],
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
      child: Container(
        padding: const EdgeInsets.all(Constants.defaultPadding),
        decoration: const BoxDecoration(
          color: Constants.secondaryColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(Constants.defaultPadding * 0.75),
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: Constants.bgColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Container(
                    width: 20,
                    height: 20,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  color: Colors.grey,
                ),
              ],
            ),
            Container(
              width: double.infinity,
              height: 20,
              color: Colors.grey,
            ),
            Container(
              width: double.infinity,
              height: 5,
              decoration: BoxDecoration(
                color: Constants.primaryColor.withOpacity(0.3),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 50,
                  height: 15,
                  color: Colors.grey,
                ),
                Container(
                  width: 50,
                  height: 15,
                  color: Colors.grey,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
