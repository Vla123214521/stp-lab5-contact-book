import '../entities/contact.dart';

/// Абстрактний інтерфейс репозиторію контактів (Domain Layer).
/// Реалізує принцип інверсії залежностей (Dependency Inversion Principle):
/// шар Application працює виключно з цим контрактом, не знаючи про спосіб збереження.
abstract class IContactRepository {
  /// Отримати всі контакти.
  List<Contact> getAll();

  /// Знайти контакт за унікальним ідентифікатором.
  Contact? getById(String id);

  /// Додати новий контакт до сховища.
  void add(Contact contact);

  /// Оновити існуючий контакт.
  bool update(Contact contact);

  /// Видалити контакт за ідентифікатором.
  bool delete(String id);

  /// Пошук контактів за підрядком (ім'я, телефон або email).
  List<Contact> search(String query);
}

