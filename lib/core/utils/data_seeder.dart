import 'package:uuid/uuid.dart';

/// Data Seeder untuk testing aplikasi MomJournal
/// File ini berisi dummy data untuk semua fitur: Categories, Schedules, Journals, Photos
class DataSeeder {
  static const _uuid = Uuid();
  
  // User ID untuk testing (ganti dengan user ID yang sebenarnya saat testing)
  static const String testUserId = 'test-user-123';
  
  /// ============================================================================
  /// CATEGORIES SEEDER
  /// ============================================================================
  
  /// Seed categories dengan berbagai tipe (schedule, photo, both)
  static List<Map<String, dynamic>> seedCategories() {
    final now = DateTime.now();
    
    return [
      // Categories untuk BOTH (Schedule & Photo)
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'name': 'Pemberian Makan/Menyusui',
        'icon': 'restaurant',
        'colorHex': '#4A90E2',
        'type': 'both',
        'isDefault': true,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'name': 'Tidur',
        'icon': 'bedtime',
        'colorHex': '#9B59B6',
        'type': 'both',
        'isDefault': true,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'name': 'Kesehatan',
        'icon': 'medical_services',
        'colorHex': '#E74C3C',
        'type': 'both',
        'isDefault': true,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'name': 'Bermain',
        'icon': 'toys',
        'colorHex': '#FFA726',
        'type': 'both',
        'isDefault': true,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      
      // Categories khusus SCHEDULE
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'name': 'Olahraga',
        'icon': 'sports',
        'colorHex': '#66BB6A',
        'type': 'schedule',
        'isDefault': true,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'name': 'Lainnya',
        'icon': 'more_horiz',
        'colorHex': '#95A5A6',
        'type': 'schedule',
        'isDefault': true,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      
      // Categories khusus PHOTO
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'name': 'Ulang Tahun',
        'icon': 'cake',
        'colorHex': '#FF6B9D',
        'type': 'photo',
        'isDefault': true,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'name': 'Liburan',
        'icon': 'beach_access',
        'colorHex': '#4FC3F7',
        'type': 'photo',
        'isDefault': true,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'name': 'Keluarga',
        'icon': 'family_restroom',
        'colorHex': '#8D6E63',
        'type': 'photo',
        'isDefault': true,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'name': 'Pencapaian',
        'icon': 'stars',
        'colorHex': '#FFD54F',
        'type': 'photo',
        'isDefault': true,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'name': 'Keseharian',
        'icon': 'wb_sunny',
        'colorHex': '#FFCA28',
        'type': 'photo',
        'isDefault': true,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      
      // Custom categories untuk testing
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'name': 'Belajar',
        'icon': 'school',
        'colorHex': '#3498DB',
        'type': 'both',
        'isDefault': false,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
    ];
  }
  
  /// ============================================================================
  /// SCHEDULES SEEDER
  /// ============================================================================
  
  /// Seed schedules dengan berbagai skenario
  static List<Map<String, dynamic>> seedSchedules() {
    final now = DateTime.now();
    final schedules = <Map<String, dynamic>>[];
    
    // ========================================================================
    // RECURRING SCHEDULES - Seminggu ke Belakang (Past Week)
    // ========================================================================
    
    for (int daysAgo = 7; daysAgo >= 1; daysAgo--) {
      final date = now.subtract(Duration(days: daysAgo));
      
      // Sarapan setiap hari (pagi)
      schedules.add({
        'id': _uuid.v4(),
        'userId': testUserId,
        'title': 'Sarapan Pagi',
        'description': 'Bubur + buah',
        'category': 'Pemberian Makan/Menyusui',
        'scheduledTime': DateTime(date.year, date.month, date.day, 7, 0).toIso8601String(),
        'endTime': null,
        'reminderEnabled': true,
        'reminderMinutesBefore': 15,
        'isCompleted': true, // Past schedules sudah completed
        'createdAt': date.subtract(const Duration(days: 30)).toIso8601String(),
        'updatedAt': date.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      });
      
      // Tidur Siang setiap hari
      schedules.add({
        'id': _uuid.v4(),
        'userId': testUserId,
        'title': 'Tidur Siang',
        'description': 'Durasi 1.5-2 jam',
        'category': 'Tidur',
        'scheduledTime': DateTime(date.year, date.month, date.day, 13, 0).toIso8601String(),
        'endTime': DateTime(date.year, date.month, date.day, 15, 0).toIso8601String(),
        'reminderEnabled': true,
        'reminderMinutesBefore': 10,
        'isCompleted': true,
        'createdAt': date.subtract(const Duration(days: 30)).toIso8601String(),
        'updatedAt': date.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      });
      
      // Makan Malam setiap hari
      schedules.add({
        'id': _uuid.v4(),
        'userId': testUserId,
        'title': 'Makan Malam',
        'description': 'Menu sayur + protein',
        'category': 'Pemberian Makan/Menyusui',
        'scheduledTime': DateTime(date.year, date.month, date.day, 18, 30).toIso8601String(),
        'endTime': null,
        'reminderEnabled': true,
        'reminderMinutesBefore': 15,
        'isCompleted': true,
        'createdAt': date.subtract(const Duration(days: 30)).toIso8601String(),
        'updatedAt': date.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      });
    }
    
    // ========================================================================
    // HARI INI - Current Day Schedules
    // ========================================================================
    
    // Sarapan hari ini (completed)
    schedules.add({
      'id': _uuid.v4(),
      'userId': testUserId,
      'title': 'Sarapan Pagi',
      'description': 'Bubur + buah pisang 🍌',
      'category': 'Pemberian Makan/Menyusui',
      'scheduledTime': DateTime(now.year, now.month, now.day, 7, 0).toIso8601String(),
      'endTime': null,
      'reminderEnabled': true,
      'reminderMinutesBefore': 15,
      'isCompleted': true,
      'createdAt': now.subtract(const Duration(days: 30)).toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'isSynced': false,
      'isDeleted': false,
    });
    
    // Tidur Siang hari ini (ongoing/upcoming)
    schedules.add({
      'id': _uuid.v4(),
      'userId': testUserId,
      'title': 'Tidur Siang',
      'description': 'Durasi sekitar 2 jam',
      'category': 'Tidur',
      'scheduledTime': DateTime(now.year, now.month, now.day, 13, 0).toIso8601String(),
      'endTime': DateTime(now.year, now.month, now.day, 15, 0).toIso8601String(),
      'reminderEnabled': true,
      'reminderMinutesBefore': 10,
      'isCompleted': false,
      'createdAt': now.subtract(const Duration(days: 30)).toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'isSynced': false,
      'isDeleted': false,
    });
    
    // Bermain di Taman hari ini (upcoming)
    schedules.add({
      'id': _uuid.v4(),
      'userId': testUserId,
      'title': 'Bermain di Taman',
      'description': 'Main ayunan dan prosotan',
      'category': 'Bermain',
      'scheduledTime': DateTime(now.year, now.month, now.day, 16, 30).toIso8601String(),
      'endTime': null,
      'reminderEnabled': true,
      'reminderMinutesBefore': 30,
      'isCompleted': false,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'isSynced': false,
      'isDeleted': false,
    });
    
    // Makan Malam hari ini (upcoming)
    schedules.add({
      'id': _uuid.v4(),
      'userId': testUserId,
      'title': 'Makan Malam',
      'description': 'Menu ikan + sayur bayam',
      'category': 'Pemberian Makan/Menyusui',
      'scheduledTime': DateTime(now.year, now.month, now.day, 18, 30).toIso8601String(),
      'endTime': null,
      'reminderEnabled': true,
      'reminderMinutesBefore': 15,
      'isCompleted': false,
      'createdAt': now.subtract(const Duration(days: 30)).toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'isSynced': false,
      'isDeleted': false,
    });
    
    // ========================================================================
    // RECURRING SCHEDULES - Seminggu ke Depan (Next Week)
    // ========================================================================
    
    for (int daysAhead = 1; daysAhead <= 7; daysAhead++) {
      final date = now.add(Duration(days: daysAhead));
      
      // Sarapan setiap hari (upcoming)
      schedules.add({
        'id': _uuid.v4(),
        'userId': testUserId,
        'title': 'Sarapan Pagi',
        'description': 'Bubur + buah',
        'category': 'Pemberian Makan/Menyusui',
        'scheduledTime': DateTime(date.year, date.month, date.day, 7, 0).toIso8601String(),
        'endTime': null,
        'reminderEnabled': true,
        'reminderMinutesBefore': 15,
        'isCompleted': false,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      });
      
      // Tidur Siang setiap hari (upcoming)
      schedules.add({
        'id': _uuid.v4(),
        'userId': testUserId,
        'title': 'Tidur Siang',
        'description': 'Durasi 1.5-2 jam',
        'category': 'Tidur',
        'scheduledTime': DateTime(date.year, date.month, date.day, 13, 0).toIso8601String(),
        'endTime': DateTime(date.year, date.month, date.day, 15, 0).toIso8601String(),
        'reminderEnabled': true,
        'reminderMinutesBefore': 10,
        'isCompleted': false,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      });
      
      // Makan Malam setiap hari (upcoming)
      schedules.add({
        'id': _uuid.v4(),
        'userId': testUserId,
        'title': 'Makan Malam',
        'description': 'Menu bervariasi',
        'category': 'Pemberian Makan/Menyusui',
        'scheduledTime': DateTime(date.year, date.month, date.day, 18, 30).toIso8601String(),
        'endTime': null,
        'reminderEnabled': true,
        'reminderMinutesBefore': 15,
        'isCompleted': false,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      });
    }
    
    // ========================================================================
    // SPECIAL SCHEDULES - Event Khusus
    // ========================================================================
    
    // Kontrol Kesehatan Rutin (besok)
    schedules.add({
      'id': _uuid.v4(),
      'userId': testUserId,
      'title': 'Kontrol Kesehatan Rutin',
      'description': 'Cek tumbuh kembang di Puskesmas',
      'category': 'Kesehatan',
      'scheduledTime': now.add(const Duration(days: 1)).copyWith(hour: 9, minute: 0).toIso8601String(),
      'endTime': null,
      'reminderEnabled': true,
      'reminderMinutesBefore': 60,
      'isCompleted': false,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'isSynced': false,
      'isDeleted': false,
    });
    
    // Baby Gym Class (3 hari lagi)
    schedules.add({
      'id': _uuid.v4(),
      'userId': testUserId,
      'title': 'Baby Gym Class',
      'description': 'Sesi mingguan baby gym',
      'category': 'Olahraga',
      'scheduledTime': now.add(const Duration(days: 3)).copyWith(hour: 10, minute: 0).toIso8601String(),
      'endTime': now.add(const Duration(days: 3)).copyWith(hour: 11, minute: 0).toIso8601String(),
      'reminderEnabled': true,
      'reminderMinutesBefore': 30,
      'isCompleted': false,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'isSynced': false,
      'isDeleted': false,
    });
    
    // Imunisasi (kemarin - completed)
    schedules.add({
      'id': _uuid.v4(),
      'userId': testUserId,
      'title': 'Imunisasi DPT Tahap 3',
      'description': 'Di Puskesmas Kecamatan',
      'category': 'Kesehatan',
      'scheduledTime': now.subtract(const Duration(days: 1)).copyWith(hour: 10, minute: 0).toIso8601String(),
      'endTime': null,
      'reminderEnabled': true,
      'reminderMinutesBefore': 30,
      'isCompleted': true,
      'createdAt': now.subtract(const Duration(days: 8)).toIso8601String(),
      'updatedAt': now.subtract(const Duration(days: 1)).toIso8601String(),
      'isSynced': false,
      'isDeleted': false,
    });
    
    // Multi-day Event: Liburan ke Rumah Nenek (minggu depan)
    schedules.add({
      'id': _uuid.v4(),
      'userId': testUserId,
      'title': 'Liburan ke Rumah Nenek',
      'description': 'Perjalanan mudik 3 hari',
      'category': 'Lainnya',
      'scheduledTime': now.add(const Duration(days: 7)).copyWith(hour: 8, minute: 0).toIso8601String(),
      'endTime': now.add(const Duration(days: 10)).copyWith(hour: 18, minute: 0).toIso8601String(),
      'reminderEnabled': true,
      'reminderMinutesBefore': 1440, // 1 day before
      'isCompleted': false,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'isSynced': false,
      'isDeleted': false,
    });
    
    // Schedule yang terlewat (past - not completed)
    schedules.add({
      'id': _uuid.v4(),
      'userId': testUserId,
      'title': 'Baby Swimming Class (Terlewat)',
      'description': 'Tidak jadi ikut karena hujan',
      'category': 'Olahraga',
      'scheduledTime': now.subtract(const Duration(days: 3)).copyWith(hour: 15, minute: 0).toIso8601String(),
      'endTime': null,
      'reminderEnabled': false,
      'reminderMinutesBefore': 15,
      'isCompleted': false,
      'createdAt': now.subtract(const Duration(days: 10)).toIso8601String(),
      'updatedAt': now.subtract(const Duration(days: 3)).toIso8601String(),
      'isSynced': false,
      'isDeleted': false,
    });
    
    // Schedule bulan depan
    schedules.add({
      'id': _uuid.v4(),
      'userId': testUserId,
      'title': 'Pesta Ulang Tahun Pertama 🎂',
      'description': 'Perayaan ulang tahun di rumah dengan keluarga',
      'category': 'Lainnya',
      'scheduledTime': now.add(const Duration(days: 30)).copyWith(hour: 14, minute: 0).toIso8601String(),
      'endTime': now.add(const Duration(days: 30)).copyWith(hour: 18, minute: 0).toIso8601String(),
      'reminderEnabled': true,
      'reminderMinutesBefore': 1440,
      'isCompleted': false,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'isSynced': false,
      'isDeleted': false,
    });
    
    // Schedule yang di-delete (soft delete)
    schedules.add({
      'id': _uuid.v4(),
      'userId': testUserId,
      'title': 'Kelas Musik (Dibatalkan)',
      'description': 'Dibatalkan karena bentrok',
      'category': 'Lainnya',
      'scheduledTime': now.add(const Duration(days: 2)).copyWith(hour: 10, minute: 0).toIso8601String(),
      'endTime': null,
      'reminderEnabled': true,
      'reminderMinutesBefore': 30,
      'isCompleted': false,
      'createdAt': now.subtract(const Duration(days: 3)).toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'isSynced': false,
      'isDeleted': true,
      'deletedAt': now.toIso8601String(),
    });
    
    return schedules;
  }
  
  /// ============================================================================
  /// JOURNALS SEEDER
  /// ============================================================================
  
  /// Seed journals dengan berbagai mood dan konten
  static List<Map<String, dynamic>> seedJournals() {
    final now = DateTime.now();
    
    return [
      // Journal hari ini - Very Happy
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'date': DateTime(now.year, now.month, now.day).toIso8601String(),
        'mood': 'veryHappy',
        'content': '''Hari ini luar biasa menyenangkan! Bayi sudah mulai bisa merangkak sendiri 🎉
        
Pagi ini dia bangun dengan ceria, langsung tersenyum lebar saat melihat mama. Setelah mandi dan sarapan bubur kesukaan, kami bermain di playmat. 

Yang paling membanggakan adalah saat dia berusaha meraih mainan kesukaannya dan berhasil merangkak sejauh 1 meter! Papa dan mama bertepuk tangan sambil teriak kegirangan. Dia juga ikut ketawa senang melihat kami bahagia 😊

Sore hari kami jalan-jalan ke taman, dia senang sekali melihat anak-anak lain bermain. Semoga besok juga hari yang indah!''',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      
      // Journal kemarin - Happy
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'date': now.subtract(const Duration(days: 1)).toIso8601String(),
        'mood': 'happy',
        'content': '''Hari yang cukup menyenangkan walau sedikit lelah.

Bayi tidur nyenyak semalam sehingga mama bisa istirahat dengan baik. Pagi ini kami ke dokter untuk imunisasi DPT tahap ke-3. Dia menangis sebentar saat disuntik, tapi segera tenang setelah digendong.

Siang hari agak rewel mungkin karena efek imunisasi, tapi setelah tidur siang jadi lebih baik. Sore kami video call dengan nenek, dia senang sekali melambai-lambai tangannya.

Overall hari yang baik! 😊''',
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      
      // Journal 2 hari lalu - Neutral
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'date': now.subtract(const Duration(days: 2)).toIso8601String(),
        'mood': 'neutral',
        'content': '''Hari yang biasa-biasa saja.

Rutinitas seperti biasa - makan, tidur, bermain. Tidak ada kejadian spesial hari ini. Bayi dalam kondisi sehat dan cukup aktif.

Papa masih harus lembur di kantor, jadi mama seharian di rumah sendiri dengan bayi. Agak capek tapi masih bisa dijalani.

Semoga besok lebih seru!''',
        'createdAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      
      // Journal 3 hari lalu - Sad
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'date': now.subtract(const Duration(days: 3)).toIso8601String(),
        'mood': 'sad',
        'content': '''Hari yang cukup melelahkan.

Bayi rewel sepanjang hari, mungkin sedang tumbuh gigi. Dia menangis hampir setiap 30 menit dan susah ditidurkan. Mama jadi kurang tidur dan badan terasa pegal-pegal.

Papa mencoba membantu saat pulang kantor, tapi tetap saja dia lebih nyaman dengan mama. Kami berdua jadi sama-sama lelah.

Berharap besok kondisinya membaik. Mama butuh istirahat yang cukup 😔''',
        'createdAt': now.subtract(const Duration(days: 3)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 3)).toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      
      // Journal minggu lalu - Very Happy
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'date': now.subtract(const Duration(days: 7)).toIso8601String(),
        'mood': 'veryHappy',
        'content': '''Milestone baru! Bayi berhasil duduk sendiri! 🎊

Ini hari yang akan selalu kami ingat. Pagi ini saat sedang bermain di playmat, tiba-tiba dia berusaha duduk sendiri dari posisi tengkurap. Dan berhasil! Walaupun hanya bertahan beberapa detik, tapi itu sudah luar biasa.

Kami langsung merekam video dan mengirimkannya ke semua keluarga. Semua orang ikut senang dan bangga. Nenek sampai meneteskan air mata bahagia saat video call.

Ini adalah salah satu momen terindah dalam perjalanan parenting kami. Thank you Allah untuk karunia ini ❤️''',
        'createdAt': now.subtract(const Duration(days: 7)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 7)).toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      
      // Journal 10 hari lalu - Very Sad
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'date': now.subtract(const Duration(days: 10)).toIso8601String(),
        'mood': 'verySad',
        'content': '''Hari terburuk minggu ini.

Bayi demam tinggi sejak pagi, mencapai 38.5°C. Kami langsung panik dan membawanya ke dokter. Dokter bilang ini hanya demam biasa karena tumbuh gigi, tapi sebagai orangtua baru kami tetap sangat khawatir.

Sepanjang hari mama tidak bisa berbuat apa-apa kecuali menjaga bayi. Dia terus menangis dan susah tidur. Mama juga ikut menangis karena tidak tahu harus berbuat apa lagi.

Untungnya setelah diberi obat penurun panas, demamnya mulai turun di malam hari. Tapi ini pengalaman yang sangat melelahkan secara emosional.

Note to self: Harus lebih tenang menghadapi situasi seperti ini. Bayi merasakan energi kita 😢''',
        'createdAt': now.subtract(const Duration(days: 10)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 10)).toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      
      // Journal 2 minggu lalu - Happy
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'date': now.subtract(const Duration(days: 14)).toIso8601String(),
        'mood': 'happy',
        'content': '''Playdate pertama!

Hari ini kami mengunjungi rumah teman yang juga punya bayi seusia. Ini kali pertama bayi kami bertemu dengan bayi lain.

Awalnya dia agak malu-malu, tapi setelah beberapa saat mulai nyaman. Lucu sekali melihat mereka saling menatap dan berusaha menyentuh satu sama lain.

Mama juga senang bisa ngobrol dengan sesama ibu muda, berbagi cerita dan pengalaman. Ternyata banyak hal yang kami alami sama.

Kami sudah sepakat untuk rutin playdate sebulan sekali. Good for baby's social development! 😊''',
        'createdAt': now.subtract(const Duration(days: 14)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 14)).toIso8601String(),
        'isSynced': false,
        'isDeleted': false,
      },
      
      // Journal yang di-delete (soft delete)
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'date': now.subtract(const Duration(days: 20)).toIso8601String(),
        'mood': 'neutral',
        'content': 'Journal yang tidak jadi dipublish.',
        'createdAt': now.subtract(const Duration(days: 20)).toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isDeleted': true,
        'deletedAt': now.toIso8601String(),
      },
    ];
  }
  
  /// ============================================================================
  /// PHOTOS SEEDER
  /// ============================================================================
  
  /// Seed photos dengan berbagai kategori dan status
  /// Note: localPath dan cloudUrl perlu disesuaikan dengan asset yang ada
  static List<Map<String, dynamic>> seedPhotos() {
    final now = DateTime.now();
    
    return [
      // Photo hari ini - Favorite
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'localPath': '/storage/photos/baby_smile_today.jpg',
        'cloudUrl': 'https://firebasestorage.googleapis.com/v0/b/mom-journal.appspot.com/o/demo_photo.jpg', // Belum di-upload
        'caption': 'Senyum pagi yang cerah hari ini 😊',
        'category': 'Keseharian',
        'isMilestone': false,
        'isFavorite': true,
        'dateTaken': now.toIso8601String(),
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isUploaded': false,
        'isDeleted': false,
      },
      
      // Photo kemarin - Milestone merangkak
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'localPath': '/storage/photos/first_crawl.jpg',
        'cloudUrl': 'https://firebasestorage.googleapis.com/photos/first_crawl.jpg',
        'caption': 'Merangkak pertama kali! Milestone baru 🎉',
        'category': 'Pencapaian',
        'isMilestone': true,
        'isFavorite': true,
        'dateTaken': now.subtract(const Duration(days: 1)).toIso8601String(),
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isUploaded': true,
        'isDeleted': false,
      },
      
      // Photo 2 hari lalu - Bermain
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'localPath': '/storage/photos/playing_toys.jpg',
        'cloudUrl': 'https://firebasestorage.googleapis.com/photos/playing_toys.jpg',
        'caption': 'Bermain dengan mainan kesukaan',
        'category': 'Bermain',
        'isMilestone': false,
        'isFavorite': false,
        'dateTaken': now.subtract(const Duration(days: 2)).toIso8601String(),
        'createdAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'isSynced': false,
        'isUploaded': true,
        'isDeleted': false,
      },
      
      // Photo minggu lalu - Tidur
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'localPath': '/storage/photos/sleeping_angel.jpg',
        'cloudUrl': 'https://firebasestorage.googleapis.com/photos/sleeping_angel.jpg',
        'caption': 'Tidur seperti malaikat kecil 😴',
        'category': 'Tidur',
        'isMilestone': false,
        'isFavorite': true,
        'dateTaken': now.subtract(const Duration(days: 7)).toIso8601String(),
        'createdAt': now.subtract(const Duration(days: 7)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 7)).toIso8601String(),
        'isSynced': false,
        'isUploaded': true,
        'isDeleted': false,
      },
      
      // Photo 10 hari lalu - Kesehatan (imunisasi)
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'localPath': '/storage/photos/vaccination.jpg',
        'cloudUrl': 'https://firebasestorage.googleapis.com/photos/vaccination.jpg',
        'caption': 'Imunisasi DPT tahap 3. Anak pemberani! 💉',
        'category': 'Kesehatan',
        'isMilestone': false,
        'isFavorite': false,
        'dateTaken': now.subtract(const Duration(days: 10)).toIso8601String(),
        'createdAt': now.subtract(const Duration(days: 10)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 10)).toIso8601String(),
        'isSynced': false,
        'isUploaded': true,
        'isDeleted': false,
      },
      
      // Photo 2 minggu lalu - Milestone duduk
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'localPath': '/storage/photos/first_sit.jpg',
        'cloudUrl': 'https://firebasestorage.googleapis.com/photos/first_sit.jpg',
        'caption': 'Duduk sendiri pertama kali! 🎊',
        'category': 'Pencapaian',
        'isMilestone': true,
        'isFavorite': true,
        'dateTaken': now.subtract(const Duration(days: 14)).toIso8601String(),
        'createdAt': now.subtract(const Duration(days: 14)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 14)).toIso8601String(),
        'isSynced': false,
        'isUploaded': true,
        'isDeleted': false,
      },
      
      // Photo 3 minggu lalu - Keluarga
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'localPath': '/storage/photos/family_photo.jpg',
        'cloudUrl': 'https://firebasestorage.googleapis.com/photos/family_photo.jpg',
        'caption': 'Foto bersama Papa dan Mama ❤️',
        'category': 'Keluarga',
        'isMilestone': false,
        'isFavorite': true,
        'dateTaken': now.subtract(const Duration(days: 21)).toIso8601String(),
        'createdAt': now.subtract(const Duration(days: 21)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 21)).toIso8601String(),
        'isSynced': false,
        'isUploaded': true,
        'isDeleted': false,
      },
      
      // Photo sebulan lalu - Makan
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'localPath': '/storage/photos/first_solid_food.jpg',
        'cloudUrl': 'https://firebasestorage.googleapis.com/photos/first_solid_food.jpg',
        'caption': 'Mencoba makanan padat pertama kali - bubur pisang! 🍌',
        'category': 'Pemberian Makan/Menyusui',
        'isMilestone': true,
        'isFavorite': true,
        'dateTaken': now.subtract(const Duration(days: 30)).toIso8601String(),
        'createdAt': now.subtract(const Duration(days: 30)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 30)).toIso8601String(),
        'isSynced': false,
        'isUploaded': true,
        'isDeleted': false,
      },
      
      // Photo 2 bulan lalu - Ulang tahun
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'localPath': '/storage/photos/birthday_party.jpg',
        'cloudUrl': 'https://firebasestorage.googleapis.com/photos/birthday_party.jpg',
        'caption': 'Pesta ulang tahun pertama yang meriah! 🎂🎈',
        'category': 'Ulang Tahun',
        'isMilestone': true,
        'isFavorite': true,
        'dateTaken': now.subtract(const Duration(days: 60)).toIso8601String(),
        'createdAt': now.subtract(const Duration(days: 60)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 60)).toIso8601String(),
        'isSynced': false,
        'isUploaded': true,
        'isDeleted': false,
      },
      
      // Photo 3 bulan lalu - Liburan
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'localPath': '/storage/photos/beach_vacation.jpg',
        'cloudUrl': 'https://firebasestorage.googleapis.com/photos/beach_vacation.jpg',
        'caption': 'Liburan pertama ke pantai 🏖️',
        'category': 'Liburan',
        'isMilestone': false,
        'isFavorite': true,
        'dateTaken': now.subtract(const Duration(days: 90)).toIso8601String(),
        'createdAt': now.subtract(const Duration(days: 90)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 90)).toIso8601String(),
        'isSynced': false,
        'isUploaded': true,
        'isDeleted': false,
      },
      
      // Photo yang di-delete (soft delete)
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'localPath': '/storage/photos/blurry_photo.jpg',
        'cloudUrl': 'https://firebasestorage.googleapis.com/v0/b/mom-journal.appspot.com/o/demo_photo.jpg',
        'caption': 'Foto blur, dihapus',
        'category': 'Keseharian',
        'isMilestone': false,
        'isFavorite': false,
        'dateTaken': now.subtract(const Duration(days: 5)).toIso8601String(),
        'createdAt': now.subtract(const Duration(days: 5)).toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isSynced': false,
        'isUploaded': false,
        'isDeleted': true,
        'deletedAt': now.toIso8601String(),
      },
      
      // Photo belum dikategorikan
      {
        'id': _uuid.v4(),
        'userId': testUserId,
        'localPath': '/storage/photos/random_moment.jpg',
        'cloudUrl': 'https://firebasestorage.googleapis.com/v0/b/mom-journal.appspot.com/o/demo_photo.jpg',
        'caption': 'Momen random yang lucu',
        'category': null, // Belum ada kategori
        'isMilestone': false,
        'isFavorite': false,
        'dateTaken': now.subtract(const Duration(hours: 6)).toIso8601String(),
        'createdAt': now.subtract(const Duration(hours: 6)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(hours: 6)).toIso8601String(),
        'isSynced': false,
        'isUploaded': false,
        'isDeleted': false,
      },
    ];
  }
  
  /// ============================================================================
  /// HELPER METHODS
  /// ============================================================================
  
  /// Print summary dari seeded data
  static void printSummary() {
    final categories = seedCategories();
    final schedules = seedSchedules();
    final journals = seedJournals();
    final photos = seedPhotos();
    
    print('=== DATA SEEDER SUMMARY ===');
    print('Categories: ${categories.length}');
    print('  - Schedule only: ${categories.where((c) => c['type'] == 'schedule').length}');
    print('  - Photo only: ${categories.where((c) => c['type'] == 'photo').length}');
    print('  - Both: ${categories.where((c) => c['type'] == 'both').length}');
    print('');
    print('Schedules: ${schedules.length}');
    print('  - Completed: ${schedules.where((s) => s['isCompleted'] == true).length}');
    print('  - Upcoming: ${schedules.where((s) => s['isCompleted'] == false && s['isDeleted'] == false).length}');
    print('  - Deleted: ${schedules.where((s) => s['isDeleted'] == true).length}');
    print('  - Recurring (past 7 days): 21 schedules');
    print('  - Recurring (next 7 days): 21 schedules');
    print('');
    print('Journals: ${journals.length}');
    print('  - Very Happy: ${journals.where((j) => j['mood'] == 'veryHappy').length}');
    print('  - Happy: ${journals.where((j) => j['mood'] == 'happy').length}');
    print('  - Neutral: ${journals.where((j) => j['mood'] == 'neutral').length}');
    print('  - Sad: ${journals.where((j) => j['mood'] == 'sad').length}');
    print('  - Very Sad: ${journals.where((j) => j['mood'] == 'verySad').length}');
    print('  - Deleted: ${journals.where((j) => j['isDeleted'] == true).length}');
    print('');
    print('Photos: ${photos.length}');
    print('  - Favorites: ${photos.where((p) => p['isFavorite'] == true).length}');
    print('  - Milestones: ${photos.where((p) => p['isMilestone'] == true).length}');
    print('  - Uploaded: ${photos.where((p) => p['isUploaded'] == true).length}');
    print('  - Deleted: ${photos.where((p) => p['isDeleted'] == true).length}');
    print('===========================');
  }
}