// ignore_for_file: lines_longer_than_80_chars

library;

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/dialogs/info_dialog.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  bool _isExporting = false;
  bool _includeProfile = true;
  bool _includeJournals = true;
  bool _includeSchedules = true;
  bool _includePhotos = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ekspor Data'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues (alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withValues (alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.download,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ekspor Semua Data',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unduh semua data Anda dalam format JSON',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Data selection
              Text(
                'Pilih Data yang Akan Diekspor',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Profile checkbox
              _buildCheckboxTile(
                title: 'Profil Pengguna & Anak',
                subtitle: 'Informasi akun dan profil anak',
                icon: Icons.person,
                value: _includeProfile,
                onChanged: (value) {
                  setState(() {
                    _includeProfile = value ?? true;
                  });
                },
              ),

              const SizedBox(height: 12),

              // Journals checkbox
              _buildCheckboxTile(
                title: 'Jurnal',
                subtitle: 'Semua catatan harian dan mood',
                icon: Icons.book,
                value: _includeJournals,
                onChanged: (value) {
                  setState(() {
                    _includeJournals = value ?? true;
                  });
                },
              ),

              const SizedBox(height: 12),

              // Schedules checkbox
              _buildCheckboxTile(
                title: 'Jadwal',
                subtitle: 'Semua jadwal dan aktivitas',
                icon: Icons.calendar_today,
                value: _includeSchedules,
                onChanged: (value) {
                  setState(() {
                    _includeSchedules = value ?? true;
                  });
                },
              ),

              const SizedBox(height: 12),

              // Photos checkbox
              _buildCheckboxTile(
                title: 'Foto',
                subtitle: 'Metadata foto (URL, caption, tanggal)',
                icon: Icons.photo_library,
                value: _includePhotos,
                onChanged: (value) {
                  setState(() {
                    _includePhotos = value ?? true;
                  });
                },
              ),

              const SizedBox(height: 32),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Data akan diekspor dalam format JSON yang dapat dibuka di aplikasi text editor atau spreadsheet.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Export button
              CustomButton(
                onPressed: _isExporting ? null : _handleExport,
                text: _isExporting ? 'Mengekspor...' : 'Ekspor Data',
                isFullWidth: true,
                icon: Icons.download,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(subtitle),
        ),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Future<void> _handleExport() async {
    // Check if at least one option is selected
    if (!_includeProfile && !_includeJournals && !_includeSchedules && !_includePhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu jenis data untuk diekspor'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.userId;

      if (userId == null) {
        throw Exception('User tidak ditemukan');
      }

      // Collect data
      final Map<String, dynamic> exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'userId': userId,
        'appVersion': '1.0.0',
      };

      // Fetch profile data
      if (_includeProfile) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          // Convert Firestore Timestamps to ISO strings
          exportData['profile'] = _convertTimestamps(userData);
        }
      }

      // Fetch journals
      if (_includeJournals) {
        final journalsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('journals')
            .orderBy('createdAt', descending: true)
            .get();

        exportData['journals'] = journalsSnapshot.docs
            .map((doc) => _convertTimestamps(doc.data()))
            .toList();
        exportData['journalsCount'] = journalsSnapshot.docs.length;
      }

      // Fetch schedules
      if (_includeSchedules) {
        final schedulesSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('schedules')
            .orderBy('time')
            .get();

        exportData['schedules'] = schedulesSnapshot.docs
            .map((doc) => _convertTimestamps(doc.data()))
            .toList();
        exportData['schedulesCount'] = schedulesSnapshot.docs.length;
      }

      // Fetch photos metadata
      if (_includePhotos) {
        final photosSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('photos')
            .orderBy('takenAt', descending: true)
            .get();

        exportData['photos'] = photosSnapshot.docs
            .map((doc) => _convertTimestamps(doc.data()))
            .toList();
        exportData['photosCount'] = photosSnapshot.docs.length;
      }

      // Convert to JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'momjournal_export_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      if (!mounted) {
        return;
      }

      // Show success dialog
      await showInfoDialog(
        context,
        title: 'Ekspor Berhasil',
        message: 'Data berhasil diekspor. File tersimpan di:\n$fileName',
        icon: const Icon(
          Icons.check_circle,
          size: 48,
          color: Colors.green,
        ),
      );

      if (!mounted) {
        return;
      }

      // Ask if user wants to share
      final shouldShare = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Bagikan File?'),
          content: const Text(
            'Apakah Anda ingin membagikan file ekspor sekarang?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tidak'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Bagikan'),
            ),
          ],
        ),
      );

      if ((shouldShare ?? false) && mounted) {
        final xFile = XFile(file.path);
        await Share.shareXFiles(
          [xFile],
          subject: 'MomJournal Data Export',
          text: 'Data ekspor MomJournal - $timestamp',
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ Error exporting data: $e');

      if (!mounted) {
        return;
      }

      await showErrorDialog(
        context,
        title: 'Gagal Mengekspor',
        message: 'Terjadi kesalahan saat mengekspor data:\n${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  /// Helper function to convert Firestore Timestamps to ISO strings
  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> data) {
    final converted = <String, dynamic>{};
    
    data.forEach((key, value) {
      if (value is Timestamp) {
        // Convert Timestamp to ISO string
        converted[key] = value.toDate().toIso8601String();
      } else if (value is Map) {
        // Recursively convert nested maps
        converted[key] = _convertTimestamps(Map<String, dynamic>.from(value));
      } else if (value is List) {
        // Convert list items
        converted[key] = value.map((item) {
          if (item is Timestamp) {
            return item.toDate().toIso8601String();
          } else if (item is Map) {
            return _convertTimestamps(Map<String, dynamic>.from(item));
          }
          return item;
        }).toList();
      } else {
        converted[key] = value;
      }
    });
    
    return converted;
  }
}