import 'package:flutter/material.dart';

/// Help & Support Screen
/// 
/// Provides FAQs, guides, and contact information for user support
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan & Dukungan'),
      ),
      body: ListView(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            color: theme.colorScheme.primaryContainer,
            child: Column(
              children: [
                Icon(
                  Icons.help_outline,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Bagaimana kami bisa membantu?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Temukan jawaban untuk pertanyaan umum atau hubungi kami',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aksi Cepat',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildQuickActionCard(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Email Kami',
                  subtitle: 'support@momjournal.app',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membuka aplikasi email...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildQuickActionCard(
                  context,
                  icon: Icons.chat_bubble_outline,
                  title: 'Live Chat',
                  subtitle: 'Chat dengan tim support',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur live chat akan segera tersedia'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildQuickActionCard(
                  context,
                  icon: Icons.bug_report_outlined,
                  title: 'Laporkan Bug',
                  subtitle: 'Bantu kami memperbaiki aplikasi',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membuka form laporan bug...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          // FAQs
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pertanyaan Umum (FAQ)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFAQItem(
                  context,
                  question: 'Bagaimana cara menambahkan jadwal?',
                  answer:
                      'Buka tab Jadwal, ketuk tombol + di pojok kanan bawah, isi detail jadwal, dan simpan.',
                ),
                _buildFAQItem(
                  context,
                  question: 'Bagaimana cara backup data saya?',
                  answer:
                      'Data Anda secara otomatis disinkronkan ke cloud. Anda juga bisa mengekspor data dari menu Pengaturan > Akun > Ekspor Data.',
                ),
                _buildFAQItem(
                  context,
                  question: 'Apakah data saya aman?',
                  answer:
                      'Ya, semua data Anda dienkripsi dan disimpan dengan aman. Kami tidak membagikan data Anda kepada pihak ketiga.',
                ),
                _buildFAQItem(
                  context,
                  question: 'Bagaimana cara mengubah tema aplikasi?',
                  answer:
                      'Buka Pengaturan > Tema, lalu pilih antara Terang, Gelap, atau Sistem.',
                ),
                _buildFAQItem(
                  context,
                  question: 'Bagaimana cara menghapus akun?',
                  answer:
                      'Buka Pengaturan > Akun > Hapus Akun. Perhatian: Tindakan ini tidak dapat dibatalkan dan semua data akan dihapus permanen.',
                ),
                _buildFAQItem(
                  context,
                  question: 'Aplikasi tidak sinkron, apa yang harus dilakukan?',
                  answer:
                      'Pastikan Anda terhubung ke internet. Coba buka Pengaturan > Akun > Sinkronisasi Data untuk sinkronisasi manual. Jika masalah berlanjut, hubungi support.',
                ),
                _buildFAQItem(
                  context,
                  question: 'Bagaimana cara mengatur notifikasi?',
                  answer:
                      'Buka Pengaturan > Notifikasi untuk mengatur preferensi notifikasi, termasuk suara, getar, dan jam tenang.',
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          // Guides
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panduan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildGuideCard(
                  context,
                  icon: Icons.rocket_launch,
                  title: 'Memulai dengan MomJournal',
                  description: 'Panduan lengkap untuk pengguna baru',
                ),
                const SizedBox(height: 8),
                _buildGuideCard(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Mengelola Jadwal',
                  description: 'Tips dan trik untuk mengatur jadwal anak',
                ),
                const SizedBox(height: 8),
                _buildGuideCard(
                  context,
                  icon: Icons.book,
                  title: 'Menulis Jurnal',
                  description: 'Cara membuat catatan harian yang bermakna',
                ),
                const SizedBox(height: 8),
                _buildGuideCard(
                  context,
                  icon: Icons.photo_library,
                  title: 'Mengelola Galeri',
                  description: 'Menyimpan dan mengatur foto kenangan',
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Contact Info
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.support_agent,
                  size: 48,
                  color: Colors.blue[700],
                ),
                const SizedBox(height: 12),
                Text(
                  'Masih butuh bantuan?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tim support kami siap membantu Anda',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membuka form kontak...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.email),
                  label: const Text('Hubungi Support'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) => ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
          ),
        ),
      ],
    );

  Widget _buildGuideCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) => Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Membuka panduan: $title'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
}
