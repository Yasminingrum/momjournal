// ignore_for_file: lines_longer_than_80_chars

library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/data/datasources/local/hive_database.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/dialogs/info_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  bool _isLoading = false;

  // Gender options
  final List<Map<String, dynamic>> _genderOptions = [
    {'value': 'boy', 'label': 'Laki-laki', 'icon': Icons.boy},
    {'value': 'girl', 'label': 'Perempuan', 'icon': Icons.girl},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentProfile() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.userId;

    if (userId == null) {
      return;
    }

    try {
      // Try to load from local Hive first
      final hiveDb = HiveDatabase();
      final userBox = hiveDb.userBox;
      final localUser = userBox.get(userId);

      if (localUser != null) {
        setState(() {
          _nameController.text = localUser.childName ?? '';
          _selectedDate = localUser.childBirthDate;
          _selectedGender = localUser.childGender;
        });
        debugPrint('✅ Loaded profile from local Hive');
        return;
      }

      // Fallback to Firestore if not in Hive
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists || !mounted) {
        return;
      }

      final data = doc.data();
      if (data == null) {
        return;
      }

      setState(() {
        _nameController.text = data['childName'] as String? ?? '';
        
        if (data['childBirthDate'] != null) {
          final birthDateData = data['childBirthDate'];
          _selectedDate = birthDateData is Timestamp
              ? birthDateData.toDate()
              : DateTime.parse(birthDateData as String);
        }
        
        _selectedGender = data['childGender'] as String?;
      });
      
      debugPrint('✅ Loaded profile from Firestore');
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil Anak'),
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
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 50,
                      color: colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Child name field
                CustomTextField(
                  label: 'Nama Anak',
                  controller: _nameController,
                  hint: 'Contoh: Fjola',
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

                const SizedBox(height: 20),

                // Gender selection
                Text(
                  'Jenis Kelamin',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: _genderOptions.map((option) {
                    final isSelected = _selectedGender == option['value'];
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedGender = option['value'] as String;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primaryContainer
                                  : Colors.grey[100],
                              border: Border.all(
                                color: isSelected
                                    ? colorScheme.primary
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  option['icon'] as IconData,
                                  size: 40,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : Colors.grey[600],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  option['label'] as String,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? colorScheme.primary
                                        : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 40),

                // Save button
                CustomButton(
                  onPressed: _isLoading ? null : _handleSave,
                  text: _isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
                  isFullWidth: true,
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
    final initialDate = _selectedDate ?? now.subtract(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 10),
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

  Future<void> _handleSave() async {
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

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.userId;

      if (userId == null) {
        throw Exception('User tidak ditemukan');
      }

      // Update to local Hive first
      final hiveDb = HiveDatabase();
      final userBox = hiveDb.userBox;
      
      // Get current user data
      final currentUser = userBox.get(userId);
      
      if (currentUser != null) {
        // Update with new child info
        final updatedUser = currentUser.copyWith(
          childName: _nameController.text.trim(),
          childBirthDate: _selectedDate,
          childGender: _selectedGender,
        );
        
        // Save to Hive
        await userBox.put(userId, updatedUser);
        debugPrint('✅ Profile updated in local Hive');
      }

      // Try to update Firestore (optional, may fail due to permissions)
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'childName': _nameController.text.trim(),
          'childBirthDate': _selectedDate!.toIso8601String(),
          'childGender': _selectedGender,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ Profile also updated in Firestore');
      } catch (firestoreError) {
        debugPrint('⚠️ Firestore update failed (will sync later): $firestoreError');
        // Continue even if Firestore fails - data is saved locally
      }

      if (!mounted) {
        return;
      }

      await showInfoDialog(
        context,
        title: 'Berhasil',
        message: 'Profil anak berhasil diperbarui',
        icon: const Icon(
          Icons.check_circle,
          size: 48,
          color: Colors.green,
        ),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ Error saving profile: $e');
      
      if (!mounted) {
        return;
      }

      await showErrorDialog(
        context,
        title: 'Gagal Menyimpan',
        message: 'Terjadi kesalahan saat menyimpan profil. Silakan coba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

    if (now.day < birthDate.day && months > 0) {
      months--;
    }

    if (years > 0) {
      if (months > 0) {
        return '$years tahun $months bulan';
      }
      return '$years tahun';
    } else {
      return '$months bulan';
    }
  }
}