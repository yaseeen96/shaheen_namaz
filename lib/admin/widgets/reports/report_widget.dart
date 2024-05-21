import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportsWidget extends ConsumerStatefulWidget {
  const ReportsWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReportsWidgetState();
}

class _ReportsWidgetState extends ConsumerState<ReportsWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Center(
        child: Text("Reports Widget"),
      ),
    );
  }
}
