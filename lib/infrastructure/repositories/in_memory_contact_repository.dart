import '../../domain/entities/contact.dart';
import '../../domain/repositories/i_contact_repository.dart';

/// Реалізація репозиторію контактів в оперативній пам'яті (Infrastructure Layer).
class InMemoryContactRepository implements IContactRepository {
  final List<Contact> _contacts;

  InMemoryContactRepository([List<Contact>? initialContacts])
      : _contacts = initialContacts ??
            [
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
            ];

  @override
  List<Contact> getAll() => List.unmodifiable(_contacts);

  @override
  Contact? getById(String id) {
    for (final c in _contacts) {
      if (c.id.toLowerCase() == id.toLowerCase()) return c;
    }
    return null;
  }

  @override
  void add(Contact contact) {
    _contacts.add(contact);
  }

  @override
  bool update(Contact contact) {
    final index = _contacts.indexWhere(
      (c) => c.id.toLowerCase() == contact.id.toLowerCase(),
    );
    if (index == -1) return false;
    _contacts[index] = contact;
    return true;
  }

  @override
  bool delete(String id) {
    final initialLen = _contacts.length;
    _contacts.removeWhere((c) => c.id.toLowerCase() == id.toLowerCase());
    return _contacts.length < initialLen;
  }

  @override
  List<Contact> search(String query) {
    final q = query.toLowerCase();
    return _contacts.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q);
    }).toList();
  }
}
