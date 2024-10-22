import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/admin/providers/dashboard_provider.dart';
import 'package:shaheen_namaz/admin/widgets/statistics/info_card.dart';
import 'package:shaheen_namaz/admin/widgets/statistics/number_card.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ShaheenStatistics extends ConsumerStatefulWidget {
  const ShaheenStatistics({super.key});

  @override
  ConsumerState<ShaheenStatistics> createState() => _ShaheenStatisticsState();
}

class _ShaheenStatisticsState extends ConsumerState<ShaheenStatistics> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(30),
      children: [
        GridView(
          physics: const ScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          children: [
            NumberCard(
              title: "Total Students",
              downloadUrl:
                  "https://download-all-students-report-ytvfas5sda-uc.a.run.app",
              provider: totalStudentsProvider,
            ),
            NumberCard(
              title: "Total Masjids",
              downloadUrl:
                  "https://download-masjid-student-report-ytvfas5sda-uc.a.run.app",
              provider: totalMasjidsProvider,
            ),
            NumberCard(
              title: "Total Volunteers",
              downloadUrl:
                  "https://download-all-volunteers-report-ytvfas5sda-uc.a.run.app",
              provider: totalVolunteersProvider,
            ),
            NumberCard(
              title: "Students Present Today",
              downloadUrl:
                  "https://download-attendance-report-ytvfas5sda-uc.a.run.app",
              provider: attendanceProvider,
            ),
            NumberCard(
              title: "Students Absent Today",
              downloadUrl:
                  "https://download-absent-report-ytvfas5sda-uc.a.run.app",
              provider: absentProvider,
            ),
            NumberCard(
              title: "Today's Certificates",
              downloadUrl:
                  "https://download-today-certificates-report-ytvfas5sda-uc.a.run.app",
              provider: todayCertificatesProvider,
            ),
            NumberCard(
              title: "Total Certificates",
              downloadUrl:
                  "https://download-certificates-report-ytvfas5sda-uc.a.run.app/",
              provider: totalCertificatesProvider,
            ),
          ],
        ),
        const Gap(15),
        const Text(
          "Attendance based on Cluster",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        const Gap(15),
        // add today's attendance cluster wise
        GridView(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            children: [
              ...List.generate(13, (index) {
                int clusterNumber = index;
                return InfoCard(
                    clusterNumber: clusterNumber,
                    icon: const Icon(Icons.one_k),
                    title: "Cluster $clusterNumber",
                    provider: todayAttendanceByClusterProvider(clusterNumber),
                    downloadUrl:
                        "https://download-cluster$clusterNumber-students-report-ytvfas5sda-uc.a.run.app");
                // return NumberCard(
                //   title: "Cluster $clusterNumber",
                //   downloadUrl:
                //       "https://download-cluster$clusterNumber-students-report-ytvfas5sda-uc.a.run.app",
                //   provider: todayAttendanceByClusterProvider(clusterNumber),
                // );
              }),
              InkWell(
                onTap: () {
                  context.go("/admin/volunteer");
                },
                child: Stack(
                  children: [
                    Ink(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Constants.secondaryColor,
                      ),
                      child: const Center(
                        child: Text(
                          "Volunteers Data",
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.download,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          await launchUrl(
                            Uri.parse(
                                "https://download-volunteer-student-report-ytvfas5sda-uc.a.run.app/"),
                            webOnlyWindowName: "_blank",
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  context.go("/admin/masjid");
                },
                child: Stack(
                  children: [
                    Ink(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Constants.secondaryColor,
                      ),
                      child: const Center(
                        child: Text(
                          "Masjid Data",
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.download,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          await launchUrl(
                            Uri.parse(
                              "https://download-masjid-student-report-ytvfas5sda-uc.a.run.app",
                            ),
                            webOnlyWindowName: "_blank",
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  context.go("/admin/jamaat");
                },
                child: Stack(
                  children: [
                    Ink(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Constants.secondaryColor,
                      ),
                      child: const Center(
                        child: Text(
                          "Jamaat Data",
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.download,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          await launchUrl(
                            Uri.parse(
                                "https://download-jamaat-users-report-ytvfas5sda-uc.a.run.app"),
                            webOnlyWindowName: "_blank",
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ]),
        const Gap(20),
        // Text(
        //   "Cluster Wise Registered Students",
        //   style: Theme.of(context).textTheme.headlineMedium,
        // ),
        // const Gap(30),
        // GridView(
        //     physics: const ScrollPhysics(),
        //     shrinkWrap: true,
        //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: 3,
        //       childAspectRatio: 2.5,
        //       crossAxisSpacing: 10,
        //       mainAxisSpacing: 10,
        //     ),
        //     children: [
        //       ...List.generate(13, (index) {
        //         int clusterNumber = index;
        //         return NumberCard(
        //           title: "Cluster $clusterNumber",
        //           downloadUrl:
        //               "https://download-cluster${clusterNumber}-students-report-ytvfas5sda-uc.a.run.app",
        //           provider: clusterDataProvider(clusterNumber),
        //         );
        //       }),

        //     ]),
      ],
    );
  }
}
