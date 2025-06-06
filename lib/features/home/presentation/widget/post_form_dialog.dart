import 'package:flutter/material.dart';

class PostFormDialog extends StatefulWidget {
  final String title;
  final String buttonText;
  final String? initialTitle;
  final String? initialBody;
  final bool isPatch;
  final Function(String title, String body) onSubmit;

  const PostFormDialog({
    super.key,
    required this.title,
    required this.buttonText,
    this.initialTitle,
    this.initialBody,
    this.isPatch = false,
    required this.onSubmit,
  });

  @override
  State<PostFormDialog> createState() => _PostFormDialogState();
}

class _PostFormDialogState extends State<PostFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _bodyController.text = widget.initialBody ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            _getIconForOperation(),
            color: _getColorForOperation(),
          ),
          const SizedBox(width: 8),
          Text(
            widget.title,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildBodyField(),
              if (widget.isPatch) _buildPatchInfo(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getColorForOperation(),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Text(widget.buttonText),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Post Title',
        hintText: 'Enter post title...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a title';
        }
        if (value.trim().length < 3) {
          return 'Title must be at least 3 characters';
        }
        return null;
      },
      maxLength: 100,
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildBodyField() {
    return TextFormField(
      controller: _bodyController,
      decoration: InputDecoration(
        labelText: 'Post Content',
        hintText: 'Enter post content...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.description),
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter content';
        }
        if (value.trim().length < 10) {
          return 'Content must be at least 10 characters';
        }
        return null;
      },
      maxLines: 4,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildPatchInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.purple.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'PATCH will only update fields that have changed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.purple.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForOperation() {
    if (widget.buttonText.contains('CREATE')) return Icons.add;
    if (widget.buttonText.contains('PUT')) return Icons.edit;
    if (widget.buttonText.contains('PATCH')) return Icons.update;
    return Icons.edit;
  }

  Color _getColorForOperation() {
    if (widget.buttonText.contains('CREATE')) return Colors.blue;
    if (widget.buttonText.contains('PUT')) return Colors.orange;
    if (widget.buttonText.contains('PATCH')) return Colors.purple;
    return Colors.blue;
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onSubmit(
        _titleController.text.trim(),
        _bodyController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}