import '../../domain/entities/contact.dart';
import '../../domain/repositories/i_contact_repository.dart';
import '../../domain/validators/contact_validator.dart';

/// Use Case: Пошук контактів за запитом (ім'я, телефон або email).
class SearchContactsUseCase {
  final IContactRepository _repository;

  const SearchContactsUseCase(this._repository);

  List<Contact> execute(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    return _repository.search(trimmed);
  }
}

/// Use Case: Редагування існуючого контакту.
class UpdateContactUseCase {
  final IContactRepository _repository;

  const UpdateContactUseCase(this._repository);

  Contact execute({
    required String id,
    String? newName,
    String? newPhone,
    String? newEmail,
    String? newCategory,
    bool? newIsFavorite,
  }) {
    final existing = _repository.getById(id);
    if (existing == null) {
      throw DomainValidationException('Контакт із ID "$id" не знайдено.');
    }

    final updated = existing.copyWith(
      name: (newName != null && newName.trim().isNotEmpty) ? newName.trim() : existing.name,
      phone: (newPhone != null && newPhone.trim().isNotEmpty) ? newPhone.trim() : existing.phone,
      email: (newEmail != null && newEmail.trim().isNotEmpty) ? newEmail.trim() : existing.email,
      category: (newCategory != null && newCategory.trim().isNotEmpty) ? newCategory.trim() : existing.category,
      isFavorite: newIsFavorite ?? existing.isFavorite,
    );

    ContactValidator.validate(
      name: updated.name,
      phone: updated.phone,
      email: updated.email,
    );

    _repository.update(updated);
    return updated;
  }
}

/// Use Case: Видалення контакту за ID.
class DeleteContactUseCase {
  final IContactRepository _repository;

  const DeleteContactUseCase(this._repository);

  bool execute(String id) {
    return _repository.delete(id.trim());
  }
}
