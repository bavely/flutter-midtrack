import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class AboutMediTrackPage extends StatelessWidget {
  const AboutMediTrackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About MediTrack'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Icon and Title
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.local_pharmacy,
                color: Colors.white,
                size: 40,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'MediTrack',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Your medication companion',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Version Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Version',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Description
            Text(
              'MediTrack helps you manage your medications with advanced features like:',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Features List
            Column(
              children: [
                _buildFeatureItem(
                  context,
                  Icons.camera_alt,
                  'Smart Scanning',
                  'Scan medication bottles with advanced OCR technology',
                ),
                _buildFeatureItem(
                  context,
                  Icons.mic,
                  'Voice Input',
                  'Add medications using voice commands',
                ),
                _buildFeatureItem(
                  context,
                  Icons.notifications,
                  'Smart Reminders',
                  'Never miss a dose with intelligent notifications',
                ),
                _buildFeatureItem(
                  context,
                  Icons.analytics,
                  'Adherence Tracking',
                  'Monitor your medication compliance over time',
                ),
                _buildFeatureItem(
                  context,
                  Icons.smart_toy,
                  'AI Assistant',
                  'Get personalized medication guidance',
                ),
                _buildFeatureItem(
                  context,
                  Icons.security,
                  'Secure & Private',
                  'Your health data is encrypted and protected',
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Support Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Need Help?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact our support team for assistance with MediTrack',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Open support contact
                    },
                    child: const Text('Contact Support'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Legal Links
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // Open privacy policy
                  },
                  child: const Text('Privacy Policy'),
                ),
                Text(
                  '•',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () {
                    // Open terms of service
                  },
                  child: const Text('Terms of Service'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Copyright
            Text(
              '© 2024 MediTrack. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}