import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:badges/badges.dart' as badges;

class SingleCertificateCard extends StatelessWidget {
  const SingleCertificateCard({
    super.key,
    required this.certificateUrl,
    required this.name,
    required this.guardianNumber,
    required this.clusterNumber,
  });

  final String certificateUrl;
  final String name;
  final String guardianNumber;
  final String clusterNumber;

  @override
  Widget build(BuildContext context) {
    return badges.Badge(
      badgeContent: Text("Cluster ${clusterNumber}"),
      position: badges.BadgePosition.topStart(),
      badgeAnimation: const badges.BadgeAnimation.slide(
        animationDuration: Duration(seconds: 1),
        loopAnimation: false,
        curve: Curves.fastOutSlowIn,
        colorChangeAnimationCurve: Curves.easeInCubic,
      ),
      badgeStyle: badges.BadgeStyle(
        shape: badges.BadgeShape.square,
        badgeColor: Constants.primaryColor,
        padding: const EdgeInsets.all(5),
        borderRadius: BorderRadius.circular(10),
        elevation: 0,
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              launchUrl(Uri.parse(certificateUrl));
            },
            child: Ink(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Constants.secondaryColor),
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              certificateUrl,
                            ),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10))),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Text(
                            name,
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            guardianNumber,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
