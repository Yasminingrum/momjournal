import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/color_constants.dart';

/// Custom Text Field Widget
/// Provides consistent text input styling across the app
class CustomTextField extends StatelessWidget {
  
  const CustomTextField({
    Key? key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.contentPadding,
  }) : super(key: key);
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;
  
  @override
  Widget build(BuildContext context) => TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        helperText: helperText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding,
        counterText: maxLength != null ? null : '',
      ),
    );
}

/// Multi-line Text Field for long text input
class MultiLineTextField extends StatelessWidget {
  
  const MultiLineTextField({
    Key? key,
    this.controller,
    this.label,
    this.hint,
    this.maxLines = 5,
    this.maxLength,
    this.onChanged,
    this.validator,
    this.showCounter = true,
  }) : super(key: key);
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool showCounter;
  
  @override
  Widget build(BuildContext context) => CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      maxLines: maxLines,
      maxLength: showCounter ? maxLength : null,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onChanged: onChanged,
      validator: validator,
    );
}

/// Password Field with show/hide toggle
class PasswordTextField extends StatefulWidget {
  
  const PasswordTextField({
    Key? key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.onSubmitted,
  }) : super(key: key);
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  
  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;
  
  @override
  Widget build(BuildContext context) => CustomTextField(
      controller: widget.controller,
      label: widget.label ?? 'Password',
      hint: widget.hint,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      prefixIcon: Icons.lock_outline,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      validator: widget.validator,
      onSubmitted: widget.onSubmitted,
    );
}

/// Search Field with search icon and clear button
class SearchTextField extends StatefulWidget {
  
  const SearchTextField({
    Key? key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onClear,
  }) : super(key: key);
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  
  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }
  
  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
  
  void _onTextChanged() {
    setState(() {});
  }
  
  void _clearText() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }
  
  @override
  Widget build(BuildContext context) => CustomTextField(
      controller: _controller,
      hint: widget.hint ?? 'Cari...',
      prefixIcon: Icons.search,
      suffixIcon: _controller.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearText,
            )
          : null,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
    );
}

/// Email Field with email validation
class EmailTextField extends StatelessWidget {
  
  const EmailTextField({
    Key? key,
    this.controller,
    this.label,
    this.validator,
  }) : super(key: key);
  final TextEditingController? controller;
  final String? label;
  final FormFieldValidator<String>? validator;
  
  @override
  Widget build(BuildContext context) => CustomTextField(
      controller: controller,
      label: label ?? 'Email',
      hint: 'nama@email.com',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      prefixIcon: Icons.email_outlined,
      validator: validator,
    );
}

/// Phone Field with phone formatting
class PhoneTextField extends StatelessWidget {
  
  const PhoneTextField({
    Key? key,
    this.controller,
    this.label,
    this.validator,
  }) : super(key: key);
  final TextEditingController? controller;
  final String? label;
  final FormFieldValidator<String>? validator;
  
  @override
  Widget build(BuildContext context) => CustomTextField(
      controller: controller,
      label: label ?? 'Nomor Telepon',
      hint: '08xxxxxxxxxx',
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      prefixIcon: Icons.phone_outlined,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(13),
      ],
      validator: validator,
    );
}

/// Number Field for numeric input only
class NumberTextField extends StatelessWidget {
  
  const NumberTextField({
    Key? key,
    this.controller,
    this.label,
    this.hint,
    this.maxLength,
    this.validator,
    this.allowDecimal = false,
  }) : super(key: key);
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final int? maxLength;
  final FormFieldValidator<String>? validator;
  final bool allowDecimal;
  
  @override
  Widget build(BuildContext context) => CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      maxLength: maxLength,
      keyboardType: allowDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: allowDecimal
          ? [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ]
          : [
              FilteringTextInputFormatter.digitsOnly,
            ],
      validator: validator,
    );
}

/// Date Picker Field (read-only with date picker)
class DatePickerField extends StatelessWidget {
  
  const DatePickerField({
    Key? key,
    required this.controller,
    this.label,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.validator,
  }) : super(key: key);
  final TextEditingController controller;
  final String? label;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateSelected;
  final FormFieldValidator<String>? validator;
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
    );
    
    if (picked != null) {
      onDateSelected?.call(picked);
    }
  }
  
  @override
  Widget build(BuildContext context) => CustomTextField(
      controller: controller,
      label: label ?? 'Tanggal',
      prefixIcon: Icons.calendar_today_outlined,
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: validator,
    );
}

/// Time Picker Field (read-only with time picker)
class TimePickerField extends StatelessWidget {
  
  const TimePickerField({
    Key? key,
    required this.controller,
    this.label,
    this.initialTime,
    this.onTimeSelected,
    this.validator,
  }) : super(key: key);
  final TextEditingController controller;
  final String? label;
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay>? onTimeSelected;
  final FormFieldValidator<String>? validator;
  
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
    
    if (picked != null) {
      onTimeSelected?.call(picked);
    }
  }
  
  @override
  Widget build(BuildContext context) => CustomTextField(
      controller: controller,
      label: label ?? 'Waktu',
      prefixIcon: Icons.access_time_outlined,
      readOnly: true,
      onTap: () => _selectTime(context),
      validator: validator,
    );
}