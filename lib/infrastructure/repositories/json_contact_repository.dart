import 'dart:convert';
import 'dart:io';

import '../../domain/entities/contact.dart';
import '../../domain/repositories/i_contact_repository.dart';

/// Реалізація репозиторію контактів із збереженням у JSON-файлі (Infrastructure Layer).
class JsonContactRepository implements IContactRepository {
  final String filePath;
  final List<Contact> _cache = [];

  JsonContactRepository(this.filePath) {
    _loadFromFile();
  }

  void _loadFromFile() {
    final file = File(filePath);
    if (!file.existsSync()) {
      _cache.addAll([
        const Contact(
          id: 'C-001',
          name: 'Олександр Ткачук',
          phone: '+380671112233',
          email: 'o.tkachuk@gmail.com',
          category: 'Робота',
          isFavorite: true,
        ),
        const Contact(
          id: 'C-002',
          name: 'Анна Мельник',
          phone: '+380509876543',
          email: 'melnyk_anna@ukr.net',
          category: 'Друзі',
        ),
        const Contact(
          id: 'C-003',
          name: 'Богдан Шевченко',
          phone: '+380934567890',
          email: 'b.sheva@outlook.com',
          category: 'Коледж',
          isFavorite: true,
        ),
      ]);
      _saveToFile();
      return;
    }

    try {
      final raw = file.readAsStringSync();
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _cache
        ..clear()
        ..addAll(decoded.map((item) {
          final map = item as Map<String, dynamic>;
          return Contact(
            id: map['id'] as String,
            name: map['name'] as String,
            phone: map['phone'] as String,
            email: map['email'] as String,
            category: (map['category'] as String?) ?? 'Загальні',
            isFavorite: (map['isFavorite'] as bool?) ?? false,
          );
        }));
    } catch (_) {
      // Якщо файл пошкоджений, залишаємо поточний кеш
    }
  }

  void _saveToFile() {
    final file = File(filePath);
    file.parent.createSync(recursive: true);
    final data = _cache
        .map((c) => {
              'id': c.id,
              'name': c.name,
              'phone': c.phone,
              'email': c.email,
              'category': c.category,
              'isFavorite': c.isFavorite,
            })
        .toList();
    const encoder = JsonEncoder.withIndent('  ');
    file.writeAsStringSync(encoder.convert(data));
  }

  @override
  List<Contact> getAll() => List.unmodifiable(_cache);

  @override
  Contact? getById(String id) {
    for (final c in _cache) {
      if (c.id.toLowerCase() == id.toLowerCase()) return c;
    }
    return null;
  }

  @override
  void add(Contact contact) {
    _cache.add(contact);
    _saveToFile();
  }

  @override
  bool update(Contact contact) {
    final index = _cache.indexWhere(
      (c) => c.id.toLowerCase() == contact.id.toLowerCase(),
    );
    if (index == -1) return false;
    _cache[index] = contact;
    _saveToFile();
    return true;
  }

  @override
  bool delete(String id) {
    final before = _cache.length;
    _cache.removeWhere((c) => c.id.toLowerCase() == id.toLowerCase());
    if (_cache.length < before) {
      _saveToFile();
      return true;
    }
    return false;
  }

  @override
  List<Contact> search(String query) {
    final q = query.toLowerCase();
    return _cache.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q);
    }).toList();
  }
}
