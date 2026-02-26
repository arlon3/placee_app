import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final Function(double)? onRatingUpdate;
  final double size;
  final bool readOnly;

  const RatingWidget({
    super.key,
    required this.rating,
    this.onRatingUpdate,
    this.size = 30,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (readOnly) {
      return RatingBarIndicator(
        rating: rating,
        itemBuilder: (context, index) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        itemCount: 5,
        itemSize: size,
      );
    }

    return RatingBar.builder(
      initialRating: rating,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: size,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: onRatingUpdate ?? (_) {},
    );
  }
}
