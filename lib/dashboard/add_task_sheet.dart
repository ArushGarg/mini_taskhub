import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../utils/validators.dart';
import 'task_model.dart';

class AddTaskSheet extends StatefulWidget {
  final Task? editTask;
  const AddTaskSheet({super.key, this.editTask});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.editTask?.title ?? '');
    _descCtrl = TextEditingController(text: widget.editTask?.description ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final prov = context.read<TaskProvider>();
    try {
      if (widget.editTask != null) {
        await prov.editTask(widget.editTask!.id, _titleCtrl.text.trim(), _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim());
      } else {
        await prov.addTask(_titleCtrl.text.trim(), _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim());
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade600, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 20),
              Text(widget.editTask == null ? 'New Task' : 'Edit Task', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Task Title', prefixIcon: Icon(Icons.title)),
                validator: Validators.taskTitle,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description (optional)', prefixIcon: Icon(Icons.notes)),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(widget.editTask == null ? 'Create Task' : 'Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}