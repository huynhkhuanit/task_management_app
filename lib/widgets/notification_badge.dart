import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const NotificationBadge({
    Key? key,
    required this.count,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -4,
          top: -4,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: count > 99 ? 4 : 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.white,
                width: 1.5,
              ),
            ),
            constraints: BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            child: Center(
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: R.styles.caption(
                  weight: FontWeight.w700,
                  color: AppColors.white,
                ).copyWith(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

