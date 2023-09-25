import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class ShimmeringCard extends StatelessWidget {
  const ShimmeringCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFCCCCCC),
      highlightColor: const Color(0xFFEEEEEE),
      child: Card(
        elevation: 1.0,
        margin: const EdgeInsets.all(6.0),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 90,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
