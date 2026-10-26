import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_routes.dart';
import '../models/backlog_entry.dart';
import '../providers/backlog_provider.dart';
import '../widgets/game_tile.dart';
import '../widgets/status_chip.dart';

class EditEntryScreen extends StatefulWidget {
  const EditEntryScreen({super.key});

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  final _notesController = TextEditingController();
  BacklogEntry? _entry;
  BacklogStatus _status = BacklogStatus.playing;
  bool _loaded = false;

  /// True while saving or removing, so a double tap can't pop twice.
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read the entry once so the form keeps the user's unsaved changes.
    if (_loaded) return;
    _loaded = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! int) return; // no game id: shows "not in your backlog"
    _entry = context
        .read<BacklogProvider>()
        .entries
        .where((e) => e.id == args)
        .firstOrNull;
    if (_entry != null) {
      _status = _entry!.status;
      _notesController.text = _entry!.notes;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);

    final entry = _entry!;
    final messenger = ScaffoldMessenger.of(context);
    await context.read<BacklogProvider>().update(
          entry.id,
          status: _status,
          notes: _notesController.text.trim(),
        );
    if (!mounted) return;
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text('${entry.name} saved')));
  }

  Future<void> _remove() async {
    if (_busy) return;
    final entry = _entry!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove game?'),
        content: Text('Remove ${entry.name} from your backlog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || _busy) return;
    setState(() => _busy = true);

    final messenger = ScaffoldMessenger.of(context);
    await context.read<BacklogProvider>().remove(entry.id);
    if (!mounted) return;
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(content: Text('${entry.name} removed from backlog')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entry;

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Entry')),
        body: const Center(child: Text('This game is not in your backlog.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Entry'),
        actions: [
          IconButton(
            tooltip: 'Remove from backlog',
            icon: const Icon(Icons.delete_outline),
            onPressed: _busy ? null : _remove,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          GameTile(
            title: entry.name,
            imageUrl: entry.backgroundImage,
            subtitle: entry.platforms.take(3).join(', '),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final status in BacklogStatus.values)
                      ChoiceChip(
                        label: Text(status.label),
                        selected: _status == status,
                        selectedColor: statusColor(status),
                        labelStyle: TextStyle(
                          color: _status == status ? Colors.white : null,
                        ),
                        onSelected: (_) => setState(() => _status = status),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _notesController,
                  maxLines: 5,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Progress, thoughts, where you left off...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  // Replaces this page so Details and Edit don't stack up.
                  child: OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.gameDetails,
                              arguments: entry.id,
                            ),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('View game details'),
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