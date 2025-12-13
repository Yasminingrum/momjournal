// ignore_for_file: lines_longer_than_80_chars

class ValidationUtils {
  
  // Private constructor to prevent instantiation
  ValidationUtils._();
  /// Validate if string is not empty
  static bool isNotEmpty(String? value) => value != null && value.trim().isNotEmpty;
  
  /// Validate if string is empty
  static bool isEmpty(String? value) => value == null || value.trim().isEmpty;
  
  /// Validate minimum length
  static bool hasMinLength(String? value, int minLength) {
    if (value == null) {
      return false;
    }
    return value.trim().length >= minLength;
  }
  
  /// Validate maximum length
  static bool hasMaxLength(String? value, int maxLength) {
    if (value == null) {
      return true;
    }
    return value.trim().length <= maxLength;
  }
  
  /// Validate length range
  static bool hasLengthInRange(String? value, int minLength, int maxLength) => hasMinLength(value, minLength) && hasMaxLength(value, maxLength);
  
  /// Validate email format
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) {
      return false;
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    return emailRegex.hasMatch(email.trim());
  }
  
  /// Validate phone number (Indonesian format)
  static bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return false;
    }
    
    // Remove spaces and dashes
    final cleanPhone = phone.replaceAll(RegExp(r'[\s-]'), '');
    
    // Indonesian phone number patterns
    final phoneRegex = RegExp(
      r'^(\+62|62|0)[0-9]{9,12}$',
    );
    
    return phoneRegex.hasMatch(cleanPhone);
  }
  
  /// Validate URL format
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    return urlRegex.hasMatch(url.trim());
  }
  
  /// Validate date is not in future
  static bool isNotFutureDate(DateTime? date) {
    if (date == null) {
      return false;
    }
    return date.isBefore(DateTime.now()) || 
           _isSameDay(date, DateTime.now());
  }
  
  /// Validate date is not in past
  static bool isNotPastDate(DateTime? date) {
    if (date == null) {
      return false;
    }
    return date.isAfter(DateTime.now()) || 
           _isSameDay(date, DateTime.now());
  }
  
  /// Validate date is within range
  static bool isDateInRange(DateTime? date, DateTime start, DateTime end) {
    if (date == null) {
      return false;
    }
    return date.isAfter(start) && date.isBefore(end) ||
           _isSameDay(date, start) || _isSameDay(date, end);
  }
  
  /// Validate number is positive
  static bool isPositive(num? value) => value != null && value > 0;
  
  /// Validate number is not negative
  static bool isNotNegative(num? value) => value != null && value >= 0;
  
  /// Validate number is within range
  static bool isInRange(num? value, num min, num max) {
    if (value == null) {
      return false;
    }
    return value >= min && value <= max;
  }
  
  /// Validate string contains only letters
  static bool isAlphabetic(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(value);
  }
  
  /// Validate string contains only numbers
  static bool isNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return RegExp(r'^[0-9]+$').hasMatch(value);
  }
  
  /// Validate string is alphanumeric
  static bool isAlphanumeric(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value);
  }
  
  /// Validate password strength (minimum requirements)
  static bool isStrongPassword(String? password) {
    if (password == null || password.isEmpty) {
      return false;
    }
    
    // At least 8 characters
    if (password.length < 8) {
      return false;
    }
    
    // Contains at least one uppercase letter
    if (!RegExp('[A-Z]').hasMatch(password)) {
      return false;
    }
    
    // Contains at least one lowercase letter
    if (!RegExp('[a-z]').hasMatch(password)) {
      return false;
    }
    
    // Contains at least one number
    if (!RegExp('[0-9]').hasMatch(password)) {
      return false;
    }
    
    return true;
  }
  
  /// Get validation error message for required field
  static String? validateRequired(String? value, {String? fieldName}) {
    if (isEmpty(value)) {
      return fieldName != null 
          ? '$fieldName wajib diisi' 
          : 'Field ini wajib diisi';
    }
    return null;
  }
  
  /// Get validation error message for email
  static String? validateEmail(String? value) {
    if (isEmpty(value)) {
      return 'Email wajib diisi';
    }
    if (!isValidEmail(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }
  
  /// Get validation error message for phone
  static String? validatePhone(String? value) {
    if (isEmpty(value)) {
      return 'Nomor telepon wajib diisi';
    }
    if (!isValidPhoneNumber(value)) {
      return 'Format nomor telepon tidak valid';
    }
    return null;
  }
  
  /// Get validation error message for min length
  static String? validateMinLength(
    String? value, 
    int minLength, 
    {String? fieldName,}
  ) {
    if (isEmpty(value)) {
      return fieldName != null 
          ? '$fieldName wajib diisi' 
          : 'Field ini wajib diisi';
    }
    if (!hasMinLength(value, minLength)) {
      return fieldName != null
          ? '$fieldName minimal $minLength karakter'
          : 'Minimal $minLength karakter';
    }
    return null;
  }
  
  /// Get validation error message for max length
  static String? validateMaxLength(
    String? value, 
    int maxLength, 
    {String? fieldName,}
  ) {
    if (value != null && !hasMaxLength(value, maxLength)) {
      return fieldName != null
          ? '$fieldName maksimal $maxLength karakter'
          : 'Maksimal $maxLength karakter';
    }
    return null;
  }
  
  /// Get validation error message for length range
  static String? validateLengthRange(
    String? value,
    int minLength,
    int maxLength,
    {String? fieldName,}
  ) {
    if (isEmpty(value)) {
      return fieldName != null 
          ? '$fieldName wajib diisi' 
          : 'Field ini wajib diisi';
    }
    if (!hasLengthInRange(value, minLength, maxLength)) {
      return fieldName != null
          ? '$fieldName harus $minLength-$maxLength karakter'
          : 'Harus $minLength-$maxLength karakter';
    }
    return null;
  }
  
  /// Get validation error message for password
  static String? validatePassword(String? value) {
    if (isEmpty(value)) {
      return 'Password wajib diisi';
    }
    if (!isStrongPassword(value)) {
      return 'Password minimal 8 karakter dengan huruf besar, huruf kecil, dan angka';
    }
    return null;
  }
  
  /// Get validation error message for password confirmation
  static String? validatePasswordConfirmation(
    String? password,
    String? confirmation,
  ) {
    if (isEmpty(confirmation)) {
      return 'Konfirmasi password wajib diisi';
    }
    if (password != confirmation) {
      return 'Password tidak cocok';
    }
    return null;
  }
  
  /// Validate child name (for profile setup)
  static String? validateChildName(String? value) {
    if (isEmpty(value)) {
      return 'Nama anak wajib diisi';
    }
    if (!hasMinLength(value, 2)) {
      return 'Nama minimal 2 karakter';
    }
    if (!hasMaxLength(value, 50)) {
      return 'Nama maksimal 50 karakter';
    }
    return null;
  }
  
  /// Validate schedule title
  static String? validateScheduleTitle(String? value) {
    if (isEmpty(value)) {
      return 'Judul jadwal wajib diisi';
    }
    if (!hasMinLength(value, 3)) {
      return 'Judul minimal 3 karakter';
    }
    if (!hasMaxLength(value, 100)) {
      return 'Judul maksimal 100 karakter';
    }
    return null;
  }
  
  /// Validate journal entry
  static String? validateJournalEntry(String? value) {
    if (isEmpty(value)) {
      return 'Catatan jurnal wajib diisi';
    }
    if (!hasMinLength(value, 10)) {
      return 'Catatan minimal 10 karakter';
    }
    if (!hasMaxLength(value, 500)) {
      return 'Catatan maksimal 500 karakter';
    }
    return null;
  }
  
  /// Validate photo caption
  static String? validatePhotoCaption(String? value) {
    // Caption is optional, only validate if provided
    if (value != null && !hasMaxLength(value, 200)) {
      return 'Keterangan maksimal 200 karakter';
    }
    return null;
  }
  
  /// Helper to check if two dates are the same day
  static bool _isSameDay(DateTime date1, DateTime date2) => date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  
  /// Sanitize input (remove extra spaces, trim)
  static String sanitize(String? input) {
    if (input == null) {
      return '';
    }
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
  
  /// Check if string contains profanity (basic implementation)
  static bool containsProfanity(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    
    // Basic profanity list (extend as needed)
    final profanityList = [
      'badword1',
      'badword2',
      // Add more as needed
    ];
    
    final lowerValue = value.toLowerCase();
    return profanityList.any(lowerValue.contains);
  }
}