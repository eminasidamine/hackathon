import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../services/admin_service.dart';
import '../services/storage_service.dart';
import 'admin_widgets.dart';

class CollectionsAdminScreen extends StatefulWidget {
  const CollectionsAdminScreen({super.key});

  @override
  State<CollectionsAdminScreen> createState() => _CollectionsAdminScreenState();
}

class _CollectionsAdminScreenState extends State<CollectionsAdminScreen> {
  final _admin = AdminService();
  late Future<List<HomeCollection>> _future;
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _admin.fetchCategories();
    _future = _admin.fetchCollections();
  }

  void _refresh() => setState(() => _future = _admin.fetchCollections());

  Future<void> _openAdd() async {
    final categories = await _categoriesFuture;
    if (!mounted) return;
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => _CollectionDialog(admin: _admin, categories: categories),
    );
    if (created == true) _refresh();
  }

  Future<void> _openEdit(HomeCollection c) async {
    final categories = await _categoriesFuture;
    if (!mounted) return;
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _CollectionDialog(admin: _admin, categories: categories, existing: c),
    );
    if (updated == true) _refresh();
  }

  Future<void> _toggleVisible(HomeCollection c) async {
    try {
      await _admin.setCollectionVisible(c.id, !c.isVisible);
      _refresh();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  Future<void> _delete(HomeCollection c) async {
    final ok = await confirmDialog(context,
        title: 'Delete "${c.title}"?',
        message: 'It will disappear from the home page.');
    if (!ok) return;
    try {
      await _admin.deleteCollection(c.id);
      _refresh();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  Future<void> _move(
      List<HomeCollection> collections, int index, int delta) async {
    final other = index + delta;
    if (other < 0 || other >= collections.length) return;
    try {
      await _admin.swapCollectionOrder(collections[index], collections[other]);
      _refresh();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminPageHeader(
          title: 'Collections',
          subtitle:
              'Banner + selected products, shown on the home page just below the main banner — a specific category or all products mixed together, your choice.',
          action: FilledButton.icon(
              onPressed: _openAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New collection')),
        ),
        Expanded(
          child: FutureBuilder<List<HomeCollection>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final collections = snapshot.data ?? [];
              if (collections.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      "No collections — the home page shows nothing here for now.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AdminTheme.muted),
                    ),
                  ),
                );
              }
              final pad = isNarrowAdmin(context) ? 16.0 : 28.0;
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(pad, 0, pad, pad),
                itemCount: collections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _CollectionRow(
                  collection: collections[i],
                  canMoveUp: i > 0,
                  canMoveDown: i < collections.length - 1,
                  onMoveUp: () => _move(collections, i, -1),
                  onMoveDown: () => _move(collections, i, 1),
                  onToggleVisible: () => _toggleVisible(collections[i]),
                  onEdit: () => _openEdit(collections[i]),
                  onDelete: () => _delete(collections[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

const double _collectionRowBreakpoint = 640;

class _CollectionRow extends StatelessWidget {
  final HomeCollection collection;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onToggleVisible;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CollectionRow({
    required this.collection,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onToggleVisible,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = collection;
    final thumb = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child:
          Image.network(c.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
    );
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(c.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AdminTheme.ink)),
            ),
            if (!c.isVisible) ...[
              const SizedBox(width: 8),
              const AdminStatusPill(label: 'Hidden', color: AdminTheme.muted),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${c.categoryName ?? "All mixed together"} · ${c.productLimit} products',
          style: const TextStyle(fontSize: 12, color: AdminTheme.muted),
        ),
      ],
    );
    final actions = [
      IconButton(
          tooltip: 'Move up',
          icon: const Icon(Icons.arrow_upward, size: 18),
          onPressed: canMoveUp ? onMoveUp : null),
      IconButton(
          tooltip: 'Move down',
          icon: const Icon(Icons.arrow_downward, size: 18),
          onPressed: canMoveDown ? onMoveDown : null),
      Switch(
          value: c.isVisible,
          activeColor: AdminTheme.red,
          onChanged: (_) => onToggleVisible()),
      IconButton(
          tooltip: 'Edit',
          icon: const Icon(Icons.edit_outlined, size: 18),
          onPressed: onEdit),
      IconButton(
          tooltip: 'Delete',
          icon:
              const Icon(Icons.delete_outline, size: 18, color: AdminTheme.red),
          onPressed: onDelete),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _collectionRowBreakpoint) {
          return AdminCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  thumb,
                  const SizedBox(width: 12),
                  Expanded(child: titleBlock),
                ]),
                const Divider(height: 20, color: AdminTheme.hair),
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: actions,
                ),
              ],
            ),
          );
        }
        return AdminCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              thumb,
              const SizedBox(width: 12),
              Expanded(child: titleBlock),
              ...actions,
            ],
          ),
        );
      },
    );
  }
}

class _CollectionDialog extends StatefulWidget {
  final AdminService admin;
  final List<Category> categories;
  final HomeCollection? existing;

  const _CollectionDialog(
      {required this.admin, required this.categories, this.existing});

  @override
  State<_CollectionDialog> createState() => _CollectionDialogState();
}

class _CollectionDialogState extends State<_CollectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _storage = StorageService();
  late final TextEditingController _title;
  late final TextEditingController _subtitle;
  late final TextEditingController _limit;
  String? _categoryId;
  bool _saving = false;
  Uint8List? _pickedBytes;
  String? _pickedName;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _title = TextEditingController(text: c?.title ?? '');
    _subtitle = TextEditingController(text: c?.subtitle ?? '');
    _limit = TextEditingController(text: '${c?.productLimit ?? 8}');
    _categoryId = c?.categoryId;
  }

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _limit.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _pickedBytes = bytes;
      _pickedName = picked.name;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.existing == null && _pickedBytes == null) {
      showAdminError(context, 'Photo requise.');
      return;
    }
    setState(() => _saving = true);
    try {
      String? imageUrl;
      if (_pickedBytes != null) {
        final ext = (_pickedName ?? '').contains('.')
            ? _pickedName!.split('.').last
            : 'jpg';
        final path = '${DateTime.now().millisecondsSinceEpoch}.$ext';

        imageUrl = await _storage.uploadPublic(
            bucket: 'banner-images', path: path, bytes: _pickedBytes!);
      }
      final limit = int.tryParse(_limit.text.trim()) ?? 8;
      final subtitleText = _subtitle.text.trim();
      if (widget.existing == null) {
        await widget.admin.createCollection(
          imageUrl: imageUrl!,
          title: _title.text.trim(),
          subtitle: subtitleText.isEmpty ? null : subtitleText,
          categoryId: _categoryId,
          productLimit: limit,
        );
      } else {
        await widget.admin.updateCollection(
          id: widget.existing!.id,
          imageUrl: imageUrl,
          title: _title.text.trim(),
          subtitle: subtitleText.isEmpty ? '' : subtitleText,
          clearSubtitle: subtitleText.isEmpty,
          categoryId: _categoryId,
          clearCategoryId: _categoryId == null,
          productLimit: limit,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) showAdminError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null
          ? 'Nouvelle collection'
          : 'Modifier la collection'),
      content: SizedBox(
        width: adminDialogWidth(context, 440),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                      labelText: 'Title (e.g. Hermès for Less)'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _subtitle,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Description (optional)'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _categoryId,
                  decoration: const InputDecoration(
                      labelText: 'Products to show below'),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('All mixed together')),
                    ...widget.categories.map((cat) =>
                        DropdownMenuItem(value: cat.id, child: Text(cat.name))),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _limit,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Number of products to list'),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n <= 0) return 'Nombre invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined, size: 18),
                  label: Text(_pickedBytes == null
                      ? (widget.existing == null
                          ? 'Choisir une photo'
                          : 'Remplacer la photo')
                      : _pickedName ?? 'Photo choisie'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black))
              : const Text('Save'),
        ),
      ],
    );
  }
}
