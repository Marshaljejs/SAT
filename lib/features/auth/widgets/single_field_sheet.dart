import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_text.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class SingleFieldSheet extends StatefulWidget {
  const SingleFieldSheet({
    super.key,
    required this.title,
    required this.description,
    required this.label,
    required this.hint,
    required this.buttonLabel,
    required this.validator,
    this.initialValue = '',
    this.keyboardType,
    this.inputFormatters,
  });

  final String title;
  final String description;
  final String label;
  final String hint;
  final String buttonLabel;
  final String? Function(String?) validator;
  final String initialValue;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<SingleFieldSheet> createState() => _SingleFieldSheetState();
}

class _SingleFieldSheetState extends State<SingleFieldSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: AppText.h2),
          const SizedBox(height: 8),
          Text(widget.description, style: AppText.bodyGrey),
          const SizedBox(height: 20),
          AppTextField(
            label: widget.label,
            hint: widget.hint,
            controller: _controller,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: widget.buttonLabel, onPressed: _submit),
        ],
      ),
    );
  }
}
