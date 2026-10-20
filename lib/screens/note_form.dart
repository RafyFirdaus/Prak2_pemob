import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';

class NoteForm extends StatefulWidget {
  const NoteForm({super.key, required this.database, this.note});

  final DatabaseHelper database;
  final Note? note;

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  static const _categories = ['Umum', 'Tugas', 'Kuliah', 'Pribadi'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late String _selectedCategory;
  bool _saving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title);
    _contentController = TextEditingController(text: widget.note?.content);
    _selectedCategory = widget.note?.category ?? 'Umum';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    final note = Note(
      id: widget.note?.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: widget.note == null
          ? DateTime.now().toIso8601String()
          : widget.note!.createdAt,
      category: _selectedCategory,
    );
    try {
      if (widget.note == null) {
        await widget.database.insert(note);
      } else {
        await widget.database.update(note);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saveError = 'Gagal menyimpan catatan. Coba lagi.';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.note == null ? 'Tambah catatan' : 'Edit catatan',
            style: theme.textTheme.titleMedium,
          ),
        ),
        body: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        readOnly: _saving,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        style: theme.textTheme.titleMedium,
                        decoration: const InputDecoration(
                          labelText: 'Judul',
                          hintText: 'Beri judul catatanmu',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Judul tidak boleh kosong.'
                            : null,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Kategori',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((cat) {
                          final selected = _selectedCategory == cat;
                          final catColor = AppTheme.categoryColor(cat);
                          return ChoiceChip(
                            label: Text(cat),
                            selected: selected,
                            selectedColor: catColor.withOpacity(0.18),
                            labelStyle: TextStyle(
                              color: selected
                                  ? catColor
                                  : theme.colorScheme.onSurface,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: selected
                                  ? catColor
                                  : theme.colorScheme.outlineVariant,
                            ),
                            onSelected: _saving
                                ? null
                                : (val) {
                                    if (val) {
                                      setState(() => _selectedCategory = cat);
                                    }
                                  },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _contentController,
                        readOnly: _saving,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        minLines: 10,
                        maxLines: null,
                        style: theme.textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'Isi catatan',
                          hintText: 'Tulis di sini…',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Isi catatan tidak boleh kosong.'
                            : null,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      if (_saveError != null) ...[
                        const SizedBox(height: 16),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _saveError!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _saving ? null : _saveNote,
                        icon: _saving
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(_saving ? 'Menyimpan…' : 'Simpan catatan'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
