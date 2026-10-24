import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RawgAttribution extends StatelessWidget {
  const RawgAttribution({super.key});

  static final Uri _rawgUrl = Uri.parse('https://rawg.io');

  Future<void> _openRawg(BuildContext context) async {
    final opened = await launchUrl(
      _rawgUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open rawg.io')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _openRawg(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text.rich(
          TextSpan(
            text: 'Game data and images provided by ',
            children: [
              TextSpan(
                text: 'RAWG',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }
}