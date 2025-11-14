/// Example: Font Management System Usage
///
/// This file demonstrates all ways to use the new font management system
///
/// Delete this file after understanding the usage patterns

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/index.dart';

class FontExamplesScreen extends StatelessWidget {
  const FontExamplesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Font Usage Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============= Method 1: R accessor for quick styles =============
            const SizedBox(height: 24),
            const Text(
              '📌 Method 1: R Accessor (Recommended)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Heading using R.styles.heading1()',
              style: R.styles.heading1(
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Body text using R.styles.body()',
              style: R.styles.body(
                size: 16,
                weight: FontWeight.w400,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Caption using R.styles.caption()',
              style: R.styles.caption(
                weight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Button text using R.styles.button()',
              style: R.styles.button(
                size: 16,
                weight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Display text using R.styles.display()',
              style: R.styles.display(
                size: 32,
                weight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),

            // ============= Method 2: Font Family using R.fonts =============
            const SizedBox(height: 24),
            const Text(
              '📌 Method 2: Font Family using R.fonts',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'SF Pro Text using R.fonts.sfPro',
              style: TextStyle(
                fontFamily: R.fonts.sfPro, // 'SFProText'
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'SF Pro Display using R.fonts.sfProDisplay',
              style: TextStyle(
                fontFamily: R.fonts.sfProDisplay, // 'SFProDisplay'
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            // ============= Method 3: Pre-defined Styles =============
            const SizedBox(height: 24),
            const Text(
              '📌 Method 3: Pre-defined Styles',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Heading 1 - SFProHeadings.h1',
              style: SFProHeadings.h1,
            ),
            const SizedBox(height: 8),
            const Text(
              'Heading 2 - SFProHeadings.h2',
              style: SFProHeadings.h2,
            ),
            const SizedBox(height: 8),
            const Text(
              'Body Text - SFProBody.regular',
              style: SFProBody.regular,
            ),
            const SizedBox(height: 8),
            const Text(
              'Caption - SFProCaptions.regular',
              style: SFProCaptions.regular,
            ),

            // ============= Method 4: Font Weights using R.weights =============
            const SizedBox(height: 24),
            const Text(
              '📌 Method 4: Font Weights using R.weights',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Using R.weights.light',
              style: TextStyle(
                fontSize: 16,
                fontWeight: R.weights.light,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Using R.weights.bold',
              style: TextStyle(
                fontSize: 16,
                fontWeight: R.weights.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Using R.weights.extraBold',
              style: TextStyle(
                fontSize: 16,
                fontWeight: R.weights.extraBold,
              ),
            ),

            // ============= Method 5: Combining Styles =============
            const SizedBox(height: 24),
            const Text(
              '📌 Method 5: Combining/Modifying Styles',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Modifying pre-defined style with copyWith',
              style: SFProHeadings.h1.copyWith(
                color: Colors.red,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Using R.styles with custom modifications',
              style: R.styles
                  .heading2(
                    color: AppColors.primary,
                  )
                  .copyWith(
                    decoration: TextDecoration.underline,
                  ),
            ),

            // ============= Method 6: All Font Weights =============
            const SizedBox(height: 24),
            const Text(
              '📌 All Available Font Weights',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 12),
            _buildWeightRow('UltraLight', R.weights.ultraLight),
            _buildWeightRow('Thin', R.weights.thin),
            _buildWeightRow('Light', R.weights.light),
            _buildWeightRow('Regular', R.weights.regular),
            _buildWeightRow('Medium', R.weights.medium),
            _buildWeightRow('SemiBold', R.weights.semiBold),
            _buildWeightRow('Bold', R.weights.bold),
            _buildWeightRow('ExtraBold', R.weights.extraBold),
            _buildWeightRow('Black', R.weights.black),

            // ============= Method 7: Using Theme TextTheme =============
            const SizedBox(height: 24),
            const Text(
              '📌 Using Theme TextTheme (in Material widgets)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Theme headline medium',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Theme body medium',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Theme label medium',
              style: Theme.of(context).textTheme.labelMedium,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              '✅ Now delete this example file and use the patterns above!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightRow(String label, FontWeight weight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: weight,
        ),
      ),
    );
  }
}
