import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/subject.dart';
import '../services/app_controller.dart';
import '../services/attendance_calculator.dart';
import '../theme/app_theme.dart';

/// Opens the add/edit subject dialog and shows a success message when saved.
Future<void> showSubjectDialog(
  BuildContext context,
  AppController controller, {
  Subject? existing,
}) async {
  // Grab the messenger before awaiting so we never use a stale context.
  final messenger = ScaffoldMessenger.of(context);
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => _SubjectDialog(controller: controller, existing: existing),
  );
  if (saved == true) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(existing == null ? 'Subject added' : 'Subject updated'),
        ),
      );
  }
}

class _SubjectDialog extends StatefulWidget {
  const _SubjectDialog({required this.controller, this.existing});

  final AppController controller;
  final Subject? existing;

  @override
  State<_SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<_SubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _attended;
  late final TextEditingController _total;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _name = TextEditingController(text: s?.name ?? '');
    _attended = TextEditingController(text: s == null ? '' : '${s.attended}');
    _total = TextEditingController(text: s == null ? '' : '${s.total}');
  }

  @override
  void dispose() {
    _name.dispose();
    _attended.dispose();
    _total.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = (value ?? '').trim();
    if (name.isEmpty) return 'Enter a subject name';
    if (name.length > 40) return 'Use 40 characters or fewer';
    if (widget.controller.subjectNameExists(
      name,
      exceptId: widget.existing?.id,
    )) {
      return 'This subject already exists';
    }
    return null;
  }

  String? _validateTotal(String? value) {
    final total = int.tryParse((value ?? '').trim());
    if (total == null) return 'Enter total classes conducted';
    if (total < 0) return 'Value cannot be negative';
    if (total > 9999) return 'Number is too large';
    return null;
  }

  String? _validateAttended(String? value) {
    final attended = int.tryParse((value ?? '').trim());
    if (attended == null) return 'Enter classes attended';
    if (attended > 9999) return 'Number is too large';
    final total = int.tryParse(_total.text.trim());
    if (total == null) return attended < 0 ? 'Value cannot be negative' : null;
    return AttendanceCalculator.validateCounts(attended, total);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final attended = int.parse(_attended.text.trim());
    final total = int.parse(_total.text.trim());
    final existing = widget.existing;
    if (existing == null) {
      await widget.controller.addSubject(_name.text, attended, total);
    } else {
      await widget.controller.updateSubject(
        existing.id,
        _name.text,
        attended,
        total,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add subject' : 'Edit subject'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: appInputDecoration('Subject name'),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: _validateName,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _attended,
                decoration: appInputDecoration('Classes attended'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
                validator: _validateAttended,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _total,
                decoration: appInputDecoration('Total classes conducted'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.done,
                validator: _validateTotal,
                onFieldSubmitted: (_) => _save(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
