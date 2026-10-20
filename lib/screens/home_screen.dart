import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';
import 'note_form.dart';

// ponytail: Simple custom date formatter without intl dependency.
String _formatDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return 'Tanggal tidak tersedia';
  final dt = DateTime.tryParse(raw)?.toLocal();
  if (dt == null) return raw;
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  final day = dt.day.toString().padLeft(2, '0');
  final month = months[dt.month];
  final year = dt.year;
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$day $month $year, $hour:$minute';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.database});

  final DatabaseHelper database;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Note> _notes = [];
  bool _loading = true;
  bool _failed = false;
  final Set<int> _deleting = {};

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes([String? query]) async {
    final q = (query ?? _searchController.text).trim();
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final notes = q.isEmpty
          ? await widget.database.getAllNotes()
          : await widget.database.searchNotes(q);
      if (!mounted) return;
      setState(() => _notes = notes);
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm({Note? note}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NoteForm(database: widget.database, note: note),
      ),
    );
    if (saved == true && mounted) await _loadNotes();
  }

  Future<void> _confirmDelete(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan ini?'),
        content: Text('Catatan "${note.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _delete(note);
    }
  }

  Future<void> _delete(Note note) async {
    final id = note.id!;
    if (_deleting.contains(id)) return;
    setState(() => _deleting.add(id));
    try {
      await widget.database.delete(id);
      if (!mounted) return;
      setState(() => _notes.removeWhere((item) => item.id == id));
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Catatan dihapus.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus catatan. Coba lagi.')),
      );
    } finally {
      if (mounted) setState(() => _deleting.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExcludeSemantics(
                          child: Icon(
                            Icons.menu_book_outlined,
                            size: 28,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('Catatan', style: theme.textTheme.headlineLarge),
                        const SizedBox(height: 8),
                        Text(
                          'Tulis yang ingin kamu ingat.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _searchController,
                          onChanged: (val) => _loadNotes(val),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Cari judul catatan…',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    tooltip: 'Hapus pencarian',
                                    onPressed: () {
                                      _searchController.clear();
                                      _loadNotes('');
                                    },
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          _loading || _failed
                              ? 'SEMUA CATATAN'
                              : _searchController.text.isNotEmpty
                                  ? '${_notes.length} HASIL PENCARIAN'
                                  : '${_notes.length} CATATAN',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_loading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Memuat catatan',
                      ),
                    ),
                  )
                else if (_failed)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Catatan belum bisa dimuat.'),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: _loadNotes,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_notes.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ExcludeSemantics(
                            child: Icon(
                              _searchController.text.isNotEmpty
                                  ? Icons.search_off_outlined
                                  : Icons.edit_note_outlined,
                              size: 56,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'Catatan tidak ditemukan'
                                : 'Belum ada catatan',
                            style: theme.textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'Tidak ada catatan dengan judul "${_searchController.text}".'
                                : 'Mulai dengan judul dan beberapa baris.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    sliver: SliverList.separated(
                      itemCount: _notes.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        final deleting = _deleting.contains(note.id);
                        final catColor = AppTheme.categoryColor(note.category);
                        final dateStr = _formatDate(note.createdAt);
                        return Material(
                          color: colors.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: colors.outlineVariant),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: deleting
                                      ? null
                                      : () => _openForm(note: note),
                                  child: Semantics(
                                    button: true,
                                    hint: 'Ketuk untuk mengedit',
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: catColor.withOpacity(
                                                    0.12,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: catColor.withOpacity(
                                                      0.35,
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  note.category,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: catColor,
                                                  ),
                                                ),
                                              ),
                                              if (dateStr.isNotEmpty) ...[
                                                const SizedBox(width: 8),
                                                Icon(
                                                  Icons.schedule,
                                                  size: 13,
                                                  color:
                                                      colors.onSurfaceVariant,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    dateStr,
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: colors
                                                              .onSurfaceVariant,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            note.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            note.content,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                  color:
                                                      colors.onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  right: 8,
                                ),
                                child: IconButton(
                                  tooltip: 'Hapus ${note.title}',
                                  onPressed: deleting
                                      ? null
                                      : () => _confirmDelete(note),
                                  icon: deleting
                                      ? const SizedBox.square(
                                          dimension: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.delete_outline),
                                  color: colors.error,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 672),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah catatan'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
