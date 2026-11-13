import 'dart:convert';
import 'dart:io';

import 'package:contact_book_clean_arch/application/use_cases/add_and_get_contacts_use_case.dart';
import 'package:contact_book_clean_arch/application/use_cases/manage_contacts_use_cases.dart';
import 'package:contact_book_clean_arch/domain/repositories/i_contact_repository.dart';
import 'package:contact_book_clean_arch/infrastructure/repositories/in_memory_contact_repository.dart';
import 'package:contact_book_clean_arch/infrastructure/repositories/json_contact_repository.dart';
import 'package:contact_book_clean_arch/presentation/cli/console_controller.dart';

/// Точка входу застосунку (Composition Root / Presentation Layer).
/// Збирає всі шари через Dependency Injection.
void main(List<String> args) {
  // 1. Зчитування конфігурації сховища з appsettings.json
  String storageType = 'json_file';
  String storagePath = 'data/contacts_store.json';

  final configFile = File('appsettings.json');
  if (configFile.existsSync()) {
    final config = jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
    storageType = (config['storageType'] as String?) ?? storageType;
    storagePath = (config['storagePath'] as String?) ?? storagePath;
  }

  // 2. Ініціалізація конкретного репозиторію (Infrastructure Layer)
  // Якщо потрібно замінити спосіб зберігання даних — достатньо змінити лише цей рядок,
  // жоден Use Case у шарі Application не потребує змін!
  final IContactRepository repository = storageType == 'in_memory'
      ? InMemoryContactRepository()
      : JsonContactRepository(storagePath);

  // 3. Впровадження залежностей (Dependency Injection) у Use Cases (Application Layer)
  final addContactUseCase = AddContactUseCase(repository);
  final getContactsUseCase = GetContactsUseCase(repository);
  final searchContactsUseCase = SearchContactsUseCase(repository);
  final updateContactUseCase = UpdateContactUseCase(repository);
  final deleteContactUseCase = DeleteContactUseCase(repository);

  // 4. Ініціалізація контролера представлення (Presentation Layer)
  final controller = ConsoleController(
    addContactUseCase: addContactUseCase,
    getContactsUseCase: getContactsUseCase,
    searchContactsUseCase: searchContactsUseCase,
    updateContactUseCase: updateContactUseCase,
    deleteContactUseCase: deleteContactUseCase,
  );

  // Якщо передано прапорець --interactive, запускаємо інтерактивний режим,
  // інакше виконуємо демонстраційний сценарій усіх Use Cases.
  if (args.contains('--interactive')) {
    controller.runInteractiveLoop();
  } else {
    controller.runDemoScenario();
  }
}

