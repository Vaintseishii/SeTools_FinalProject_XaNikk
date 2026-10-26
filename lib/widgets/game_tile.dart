import 'package:flutter/material.dart';

/// One game row with a cover image, used by the Backlog and Search lists.
/// Takes plain values so it works for both Game and BacklogEntry.
class GameTile extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const GameTile({
    super.key,
    required this.title,
    this.imageUrl,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 56,
          height: 56,
          child: imageUrl == null
              ? const Icon(Icons.videogame_asset)
              : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.videogame_asset),
                ),
        ),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitle == null || subtitle!.isEmpty
          ? null
          : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: trailing,
    );
  }
}
