import 'package:flutter/material.dart';

/// Privacy Policy Screen
/// 
/// Displays the app's privacy policy and data handling information
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebijakan Privasi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            'Kebijakan Privasi MomJournal',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Terakhir diperbarui: Januari 2025',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Introduction
          _buildSection(
            context,
            title: 'Pendahuluan',
            content:
                'MomJournal berkomitmen untuk melindungi privasi Anda. Kebijakan privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda saat menggunakan aplikasi kami.',
          ),

          // Data Collection
          _buildSection(
            context,
            title: 'Informasi yang Kami Kumpulkan',
            content:
                'Kami mengumpulkan informasi yang Anda berikan secara langsung, termasuk:\n\n'
                '• Informasi akun (nama, email)\n'
                '• Informasi profil anak\n'
                '• Jadwal dan pengingat\n'
                '• Catatan jurnal\n'
                '• Foto dan media\n'
                '• Data penggunaan aplikasi',
          ),

          // Data Usage
          _buildSection(
            context,
            title: 'Bagaimana Kami Menggunakan Informasi Anda',
            content:
                'Informasi yang kami kumpulkan digunakan untuk:\n\n'
                '• Menyediakan dan meningkatkan layanan aplikasi\n'
                '• Menyimpan dan menyinkronkan data Anda\n'
                '• Mengirim notifikasi dan pengingat\n'
                '• Menganalisis penggunaan aplikasi\n'
                '• Memberikan dukungan pelanggan',
          ),

          // Data Storage
          _buildSection(
            context,
            title: 'Penyimpanan Data',
            content:
                'Data Anda disimpan dengan aman menggunakan:\n\n'
                '• Penyimpanan lokal terenkripsi di perangkat Anda\n'
                '• Cloud storage (Firebase) dengan enkripsi end-to-end\n'
                '• Backup otomatis untuk mencegah kehilangan data\n\n'
                'Anda memiliki kontrol penuh atas data Anda dan dapat menghapusnya kapan saja.',
          ),

          // Data Sharing
          _buildSection(
            context,
            title: 'Berbagi Informasi',
            content:
                'Kami TIDAK akan menjual, menyewakan, atau membagikan informasi pribadi Anda kepada pihak ketiga tanpa persetujuan Anda, kecuali:\n\n'
                '• Diwajibkan oleh hukum\n'
                '• Untuk melindungi hak dan keamanan kami\n'
                '• Dengan penyedia layanan yang membantu operasional aplikasi (dengan perjanjian kerahasiaan)',
          ),

          // User Rights
          _buildSection(
            context,
            title: 'Hak Anda',
            content:
                'Anda memiliki hak untuk:\n\n'
                '• Mengakses data pribadi Anda\n'
                '• Memperbaiki data yang tidak akurat\n'
                '• Menghapus akun dan semua data Anda\n'
                '• Mengekspor data Anda\n'
                '• Menolak pemrosesan data tertentu\n'
                '• Menarik persetujuan kapan saja',
          ),

          // Security
          _buildSection(
            context,
            title: 'Keamanan',
            content:
                'Kami mengimplementasikan langkah-langkah keamanan teknis dan organisasi yang sesuai untuk melindungi data Anda dari akses, pengungkapan, perubahan, atau penghancuran yang tidak sah.',
          ),

          // Children Privacy
          _buildSection(
            context,
            title: 'Privasi Anak',
            content:
                'MomJournal dirancang untuk orang tua yang mencatat informasi tentang anak mereka. Kami tidak secara sengaja mengumpulkan informasi pribadi dari anak-anak di bawah usia 13 tahun tanpa persetujuan orang tua.',
          ),

          // Changes
          _buildSection(
            context,
            title: 'Perubahan Kebijakan',
            content:
                'Kami dapat memperbarui kebijakan privasi ini dari waktu ke waktu. Kami akan memberi tahu Anda tentang perubahan signifikan melalui aplikasi atau email.',
          ),

          // Contact
          _buildSection(
            context,
            title: 'Hubungi Kami',
            content:
                'Jika Anda memiliki pertanyaan tentang kebijakan privasi ini, silakan hubungi kami di:\n\n'
                'Email: privacy@momjournal.app\n'
                'Website: www.momjournal.app',
          ),

          const SizedBox(height: 32),

          // Accept Button
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Saya Mengerti'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
