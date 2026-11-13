/// Сутність предметної області «Контакт».
/// Не залежить від жодних зовнішніх бібліотек чи фреймворків (Clean Architecture).
class Contact {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String category;
  final bool isFavorite;

  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.category = 'Загальні',
    this.isFavorite = false,
  });

  /// Створює копію об'єкта зі зміненими полями.
  Contact copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? category,
    bool? isFavorite,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  String toString() {
    final star = isFavorite ? '★ ' : '  ';
    return '$star[$id] $name | Тел: $phone | Email: $email | Категорія: $category';
  }
}

