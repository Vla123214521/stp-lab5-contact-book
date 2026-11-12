import 'dart:io';

import '../../application/use_cases/add_and_get_contacts_use_case.dart';
import '../../application/use_cases/manage_contacts_use_cases.dart';
import '../../domain/entities/contact.dart';
import '../../domain/validators/contact_validator.dart';

/// Консольний контролер (Presentation Layer).
/// Приймає залежності Use Cases через конструктор (Dependency Injection).
class ConsoleController {
  final AddContactUseCase _addContactUseCase;
  final GetContactsUseCase _getContactsUseCase;
  final SearchContactsUseCase _searchContactsUseCase;
  final UpdateContactUseCase _updateContactUseCase;
  final DeleteContactUseCase _deleteContactUseCase;

  const ConsoleController({
    required AddContactUseCase addContactUseCase,
    required GetContactsUseCase getContactsUseCase,
    required SearchContactsUseCase searchContactsUseCase,
    required UpdateContactUseCase updateContactUseCase,
    required DeleteContactUseCase deleteContactUseCase,
  })  : _addContactUseCase = addContactUseCase,
        _getContactsUseCase = getContactsUseCase,
        _searchContactsUseCase = searchContactsUseCase,
        _updateContactUseCase = updateContactUseCase,
        _deleteContactUseCase = deleteContactUseCase;

  void displayTable(List<Contact> list, {String title = 'СПИСОК КОНТАКТІВ'}) {
    if (list.isEmpty) {
      print('[-] Список контактів порожній.');
      return;
    }

    print('\n==================== $title ====================');
    print(
      'ID'.padRight(8) +
          '★'.padRight(3) +
          "ПІБ / Ім'я".padRight(22) +
          'Телефон'.padRight(16) +
          'Email'.padRight(34) +
          'Категорія',
    );
    print('-' * 96);

    for (final c in list) {
      print(
        c.id.padRight(8) +
            (c.isFavorite ? '★' : ' ').padRight(3) +
            c.name.padRight(22) +
            c.phone.padRight(16) +
            c.email.padRight(34) +
            c.category,
      );
    }
    print('-' * 96);
  }

  void runDemoScenario() {
    print('================================================================================');
    print('   КОНСОЛЬНИЙ ЗАСТОСУНОК «КОНТАКТ-КНИГА» (CLEAN ARCHITECTURE, ВАРІАНТ 19)       ');
    print('================================================================================');

    // 1. Виведення початкових контактів
    displayTable(
      _getContactsUseCase.execute(),
      title: "1. ПОЧАТКОВІ КОНТАКТИ (ВІДСОРТОВАНО ЗА ІМ'ЯМ)",
    );

    // 2. Додавання нового контакту через AddContactUseCase
    print('\n[Дія] Додавання нового контакту через AddContactUseCase...');
    final added = _addContactUseCase.execute(
      name: 'Владислав Ніякий',
      phone: '+380681234567',
      email: 'ki27.niiakyi.vladyslav@vtc.vn.ua',
      category: 'Коледж',
      isFavorite: true,
    );
    print('[+] Успішно додано: $added');

    // 3. Пошук контактів через SearchContactsUseCase
    print('\n[Дія] Пошук контактів за запитом "Коледж"...');
    final found = _searchContactsUseCase.execute('Коледж');
    displayTable(found, title: '2. РЕЗУЛЬТАТИ ПОШУКУ ("Коледж")');

    // 4. Редагування контакту через UpdateContactUseCase
    print('\n[Дія] Оновлення телефону для контакту C-002...');
    final updated = _updateContactUseCase.execute(
      id: 'C-002',
      newPhone: '+380501119988',
      newIsFavorite: true,
    );
    print('[+] Контакт оновлено: $updated');

    // 5. Перевірка доменної валідації (спроба передати некоректний email)
    print('\n[Дія] Перевірка бізнес-правил (спроба додати некоректний email)...');
    try {
      _addContactUseCase.execute(
        name: 'Тестовий Користувач',
        phone: '+380670000000',
        email: 'invalid-email-without-at.com',
      );
    } on DomainValidationException catch (e) {
      print('[!] Перехоплено очікувану помилку домену: $e');
    }

    // 6. Підсумковий список
    displayTable(
      _getContactsUseCase.execute(),
      title: '3. АКТУАЛЬНИЙ СПИСОК КОНТАКТІВ У СХОВИЩІ',
    );
  }

  void runInteractiveLoop() {
    while (true) {
      print('\nКоманди: [list, fav, add, find, edit, delete, exit]');
      stdout.write('Введіть команду > ');
      final cmd = (stdin.readLineSync() ?? '').trim().toLowerCase();

      try {
        switch (cmd) {
          case 'list':
            displayTable(_getContactsUseCase.execute());
            break;
          case 'fav':
            displayTable(
              _getContactsUseCase.execute(onlyFavorites: true),
              title: 'ОБРАНІ КОНТАКТИ (★)',
            );
            break;
          case 'add':
            stdout.write("Введіть ім'я: ");
            final name = stdin.readLineSync() ?? '';
            stdout.write('Введіть телефон: ');
            final phone = stdin.readLineSync() ?? '';
            stdout.write('Введіть email: ');
            final email = stdin.readLineSync() ?? '';
            stdout.write('Категорія [Загальні]: ');
            final category = stdin.readLineSync() ?? 'Загальні';
            final created = _addContactUseCase.execute(
              name: name,
              phone: phone,
              email: email,
              category: category,
            );
            print('[+] Контакт створено: $created');
            break;
          case 'find':
            stdout.write('Пошуковий запит: ');
            final q = stdin.readLineSync() ?? '';
            displayTable(
              _searchContactsUseCase.execute(q),
              title: 'РЕЗУЛЬТАТИ ПОШУКУ ($q)',
            );
            break;
          case 'edit':
            stdout.write('ID контакту (напр., C-001): ');
            final id = stdin.readLineSync() ?? '';
            stdout.write("Нове ім'я (Enter — без змін): ");
            final name = stdin.readLineSync();
            stdout.write('Новий телефон (Enter — без змін): ');
            final phone = stdin.readLineSync();
            stdout.write('Новий email (Enter — без змін): ');
            final email = stdin.readLineSync();
            final updated = _updateContactUseCase.execute(
              id: id,
              newName: name,
              newPhone: phone,
              newEmail: email,
            );
            print('[+] Оновлено: $updated');
            break;
          case 'delete':
            stdout.write('ID контакту для видалення: ');
            final id = stdin.readLineSync() ?? '';
            if (_deleteContactUseCase.execute(id)) {
              print('[-] Контакт $id видалено.');
            } else {
              print('[!] Контакт $id не знайдено.');
            }
            break;
          case 'exit':
            print('Роботу завершено!');
            return;
          default:
            print('[!] Невідома команда.');
        }
      } on DomainValidationException catch (e) {
        print('[!] $e');
      }
    }
  }
}
