/// Доменний виняток для помилок валідації бізнес-правил.
class DomainValidationException implements Exception {
  final String message;
  const DomainValidationException(this.message);

  @override
  String toString() => 'Помилка валідації: $message';
}

/// Бізнес-правила перевірки даних контакту (Domain Layer).
class ContactValidator {
  static final RegExp _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9\s\-\(\)]{7,16}$');

  static bool isValidEmail(String email) {
    final trimmed = email.trim();
    return trimmed.contains('@') && _emailRegex.hasMatch(trimmed);
  }

  static bool isValidPhone(String phone) {
    return _phoneRegex.hasMatch(phone.trim());
  }

  static void validate({
    required String name,
    required String phone,
    required String email,
  }) {
    if (name.trim().isEmpty) {
      throw const DomainValidationException("Ім'я контакту не може бути порожнім.");
    }
    if (!isValidPhone(phone)) {
      throw const DomainValidationException('Некоректний формат номера телефону.');
    }
    if (!isValidEmail(email)) {
      throw const DomainValidationException('Email повинен містити символ "@" та мати коректний домен.');
    }
  }
}
