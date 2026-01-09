library;

import 'package:flutter/material.dart';

import '../../routes/app_router.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Profil Anak'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header illustration
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.child_care,
                    size: 60,
                    color: colorScheme.primary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'Ceritakan tentang si kecil',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Informasi ini membantu kami personalisasi '
                  'pengalaman Anda',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Child name field
                CustomTextField(
                  label: 'Nama Anak',
                  controller: _nameController,
                  hint: 'Contoh: Emyr',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama anak harus diisi';
                    }
                    if (value.trim().length < 2) {
                      return 'Nama minimal 2 karakter';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Date of birth field
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedDate == null
                            ? Colors.grey[300]!
                            : colorScheme.primary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cake,
                          color: _selectedDate == null
                              ? Colors.grey[600]
                              : colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal Lahir',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedDate == null
                                    ? 'Pilih tanggal lahir'
                                    : _formatDate(_selectedDate!),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: _selectedDate == null
                                      ? Colors.grey[600]
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Age helper text
                if (_selectedDate != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      'Usia: ${_calculateAge(_selectedDate!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 40),
                
                // Submit button
                CustomButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  text: _isLoading ? 'Menyimpan...' : 'Lanjutkan',
                  isFullWidth: true,
                ),
                
                const SizedBox(height: 12),
                
                // Skip button (optional)
                TextButton(
                  onPressed: _isLoading ? null : _handleSkip,
                  child: const Text('Lewati untuk sekarang'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? 
        now.subtract(const Duration(days: 365));
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: 'Pilih Tanggal Lahir',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal lahir'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    await Navigator.pushReplacementNamed(context, Routes.home);
  }

  void _handleSkip() {
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    
    if (months < 0) {
      years--;
      months += 12;
    }
    
    if (years > 0) {
      return '$years tahun $months bulan';
    } else {
      return '$months bulan';
    }
  }
}