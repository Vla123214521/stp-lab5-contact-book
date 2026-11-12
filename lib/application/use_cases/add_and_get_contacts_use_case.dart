import '../../domain/entities/contact.dart';
import '../../domain/repositories/i_contact_repository.dart';
import '../../domain/validators/contact_validator.dart';

/// Use Case: Додавання нового контакту (Application Layer).
/// Залежить лише від абстракції IContactRepository (Dependency Inversion Principle).
class AddContactUseCase {
  final IContactRepository _repository;

  const AddContactUseCase(this._repository);

  Contact execute({
    required String name,
    required String phone,
    required String email,
    String category = 'Загальні',
    bool isFavorite = false,
  }) {
    ContactValidator.validate(name: name, phone: phone, email: email);

    final existing = _repository.getAll();
    final nextId = (existing.length + 1).toString().padLeft(3, '0');

    final contact = Contact(
      id: 'C-$nextId',
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      category: category.trim().isEmpty ? 'Загальні' : category.trim(),
      isFavorite: isFavorite,
    );

    _repository.add(contact);
    return contact;
  }
}

/// Use Case: Отримання відсортованого списку контактів.
class GetContactsUseCase {
  final IContactRepository _repository;

  const GetContactsUseCase(this._repository);

  List<Contact> execute({bool sortByName = true, bool onlyFavorites = false}) {
    var list = List<Contact>.from(_repository.getAll());
    if (onlyFavorites) {
      list = list.where((c) => c.isFavorite).toList();
    }
    if (sortByName) {
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return list;
  }
}
