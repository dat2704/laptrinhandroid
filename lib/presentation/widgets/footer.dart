
import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'DStore',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildFooterText('123 Fashion Street, New York, USA'),
          const SizedBox(height: 8),
          _buildFooterText('Phone: +1 234 567 890'),
          const SizedBox(height: 8),
          _buildFooterText('Email: support@dstore.com'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(Icons.facebook),
              const SizedBox(width: 16),
              // Add other social icons as needed
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            '© 2025 DStore. All rights reserved.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterText(String text) {
    return Text(text, style: const TextStyle(color: Colors.white70));
  }

  Widget _buildSocialIcon(IconData icon) {
    return Icon(icon, color: Colors.white, size: 24);
  }
}
