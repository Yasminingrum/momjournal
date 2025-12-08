/// Notification Settings Screen
/// 
/// Screen untuk mengatur notification settings
/// Location: lib/presentation/screens/settings/notification_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              // Enable notifications
              SwitchListTile(
                title: const Text('Aktifkan Notifikasi'),
                subtitle: const Text('Terima pengingat untuk jadwal'),
                value: provider.notificationsEnabled,
                onChanged: (value) {
                  provider.toggleNotifications(value);
                },
                secondary: const Icon(Icons.notifications_active),
              ),

              const Divider(),

              // Sound
              SwitchListTile(
                title: const Text('Suara'),
                subtitle: const Text('Mainkan suara saat notifikasi'),
                value: provider.soundEnabled,
                onChanged: provider.notificationsEnabled
                    ? (value) => provider.toggleSound(value)
                    : null,
                secondary: const Icon(Icons.volume_up),
              ),

              // Vibration
              SwitchListTile(
                title: const Text('Getar'),
                subtitle: const Text('Getarkan HP saat notifikasi'),
                value: provider.vibrationEnabled,
                onChanged: provider.notificationsEnabled
                    ? (value) => provider.toggleVibration(value)
                    : null,
                secondary: const Icon(Icons.vibration),
              ),

              const Divider(height: 32),

              // Quiet hours section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Jam Tenang',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SwitchListTile(
                title: const Text('Aktifkan Jam Tenang'),
                subtitle: const Text('Tidak ada notifikasi di jam tenang'),
                value: provider.quietHoursEnabled,
                onChanged: provider.notificationsEnabled
                    ? (value) => provider.toggleQuietHours(value)
                    : null,
                secondary: const Icon(Icons.nightlight_round),
              ),

              // Quiet hours start
              ListTile(
                enabled: provider.notificationsEnabled && 
                         provider.quietHoursEnabled,
                title: const Text('Mulai Jam Tenang'),
                subtitle: Text(
                  _formatTime(provider.quietHoursStart),
                ),
                leading: const Icon(Icons.bedtime),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _selectQuietHoursStart(context, provider),
              ),

              // Quiet hours end
              ListTile(
                enabled: provider.notificationsEnabled && 
                         provider.quietHoursEnabled,
                title: const Text('Akhir Jam Tenang'),
                subtitle: Text(
                  _formatTime(provider.quietHoursEnd),
                ),
                leading: const Icon(Icons.wb_sunny),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _selectQuietHoursEnd(context, provider),
              ),

              const SizedBox(height: 16),

              // Info card
              if (provider.quietHoursEnabled)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Notifikasi akan dinonaktifkan dari ${_formatTime(provider.quietHoursStart)} hingga ${_formatTime(provider.quietHoursEnd)}',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _selectQuietHoursStart(
    BuildContext context,
    NotificationProvider provider,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: provider.quietHoursStart,
      helpText: 'Pilih Waktu Mulai Jam Tenang',
    );

    if (picked != null) {
      provider.setQuietHoursStart(picked);
    }
  }

  Future<void> _selectQuietHoursEnd(
    BuildContext context,
    NotificationProvider provider,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: provider.quietHoursEnd,
      helpText: 'Pilih Waktu Akhir Jam Tenang',
    );

    if (picked != null) {
      provider.setQuietHoursEnd(picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}