import 'package:flutter/material.dart';

class OnboardingItem {
  final String title;
  final String description;
  final String imagePath;
  final Color? backgroundColor;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
    this.backgroundColor,
  });
}
