import 'package:flutter/material.dart';

class NumberCard extends StatelessWidget {
  const NumberCard({
    super.key,
    required this.title,
    required this.number,
  });
  final int number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            "$number",
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}
