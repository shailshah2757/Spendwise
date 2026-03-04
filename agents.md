# Expense Tracker — Agent Context

## Stack
- Flutter 3.x + Dart, Material 3 (`useMaterial3: true`)
- Clean Architecture: Domain / Data / Presentation per feature
- State: Riverpod (`StateNotifier<AsyncValue<T>>`, `FutureProvider.autoDispose`, `StateProvider`)
- DB: Hive (typeId 0=ExpenseModel, 1=CategoryModel). Settings use plain `Box` (no typed adapter)
- Charts: fl_chart | Slidable: flutter_slidable | UUID: uuid | Formatting: intl

## Project Root
`d:/Expense Tracker/expense_tracker/`

## Folder Structure
```
lib/
├── main.dart                         # Hive init, adapter registration, box opening
├── app.dart                          # ProviderScope + MaterialApp + 4-tab nav + center FAB
├── core/
│   ├── constants/
│   │   ├── app_colors.dart           # Teal primary (0xFF00897B), category palette
│   │   ├── app_strings.dart          # All UI strings
│   │   ├── app_spacing.dart          # sm=8, md=16, lg=24
│   │   ├── hive_boxes.dart           # expenses, categories, settings, categoryBudgets
│   │   └── currencies.dart           # Currency class + supportedCurrencies list
│   ├── error/failures.dart           # DatabaseFailure, NotFoundFailure, ValidationFailure
│   ├── theme/app_theme.dart          # Full M3 theme (16 components, radius tokens)
│   └── utils/date_formatter.dart     # formatFull, formatMonthYear, formatShort, formatCurrency(amount, symbol)
└── features/
    ├── expense/
    │   ├── domain/
    │   │   ├── entities/expense.dart          # id, title, amount, categoryId, date, notes, receiptPath
    │   │   ├── repositories/expense_repository.dart
    │   │   └── usecases/{add,get,get_by_month,update,delete}_expense.dart
    │   ├── data/
    │   │   ├── models/expense_model.dart+.g.dart (typeId=0, HiveFields 0-6)
    │   │   ├── datasources/expense_local_datasource.dart  # Hive CRUD
    │   │   └── repositories/expense_repository_impl.dart
    │   └── presentation/
    │       ├── providers/expense_provider.dart   # ExpenseNotifier (load/add/delete/update)
    │       ├── screens/{expense_list,add_expense}_screen.dart
    │       └── widgets/expense_card.dart
    ├── category/
    │   ├── domain/entities/category.dart        # + defaultCategories (7 items)
    │   ├── data/ (model typeId=1, datasource with seedDefaults)
    │   └── presentation/
    │       ├── providers/category_provider.dart  # CategoryNotifier (auto-seeds)
    │       └── pages/category_page.dart
    ├── summary/
    │   ├── domain/entities/monthly_summary.dart  # MonthlySummary + CategoryTotal
    │   ├── domain/usecases/get_monthly_summary.dart
    │   └── presentation/ (summary_provider, summary_page, summary_pie_chart)
    ├── home/
    │   └── presentation/
    │       ├── pages/home_screen.dart
    │       ├── providers/home_provider.dart
    │       └── widgets/{budget_progress_card,category_budget_list,recent_expenses_list}.dart
    ├── onboarding/
    │   └── presentation/pages/{splash_screen,currency_setup_page}.dart
    ├── settings/
    │   ├── data/datasources/settings_local_datasource.dart
    │   ├── data/repositories/settings_repository_impl.dart
    │   ├── domain/repositories/settings_repository.dart
    │   └── presentation/
    │       ├── providers/settings_provider.dart
    │       ├── pages/{settings_screen,category_budget_page}.dart
    │       └── widgets/settings_tile.dart
    └── security/
        ├── presentation/pages/{lock_screen,pin_setup_page}.dart
        ├── presentation/providers/security_provider.dart
        └── services/auth_service.dart
```

## Key Patterns
- Hive boxes opened in main.dart before runApp
- .g.dart adapter files are pre-written (manually updated, no build_runner)
- Category seeds happen in CategoryNotifier._init()
- Summary re-fetches when expenseNotifierProvider changes (ref.watch)
- Settings stored as plain Hive Box key-value (currency, monthlyBudget, isFirstLaunch, appLock*)
- Category budgets: Box<double> keyed by categoryId
- Receipts: file paths stored in ExpenseModel.receiptPath, files in app docs dir
- Navigation: 4 tabs + center docked FAB (Home, Expenses, +FAB, Analytics, Settings)
- Security: _SecurityGate wraps app, WidgetsBindingObserver for background timeout

## Hive Boxes
| Box | Type | Content |
|-----|------|---------|
| `expenses` | `Box<ExpenseModel>` | All expenses keyed by id |
| `categories` | `Box<CategoryModel>` | All categories keyed by id |
| `settings` | `Box` (dynamic) | currency, currencySymbol, monthlyBudget, isFirstLaunch, appLock* |
| `category_budgets` | `Box<double>` | Per-category monthly budget keyed by categoryId |

## Provider Architecture
```
// Settings
settingsDatasourceProvider   -> Provider<SettingsLocalDatasource>
settingsRepositoryProvider   -> Provider<SettingsRepositoryImpl>
currencySymbolProvider       -> StateProvider<String>

// Expense
expenseNotifierProvider      -> StateNotifierProvider<ExpenseNotifier, AsyncValue<List<Expense>>>
monthlyExpensesProvider      -> FutureProvider.autoDispose<List<Expense>>

// Category
categoryNotifierProvider     -> StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>

// Summary
monthlySummaryProvider       -> FutureProvider.autoDispose<MonthlySummary>
selectedMonthProvider        -> StateProvider<DateTime>

// Home
recentExpensesProvider       -> FutureProvider.autoDispose<List<Expense>>
monthlySpentProvider         -> FutureProvider.autoDispose<double>

// Security (Phase 3)
isLockedProvider             -> StateProvider<bool>
```

## Implementation Phases
- **Phase 1**: Core infra — navigation (4 tabs + FAB), onboarding/splash, expense CRUD, currency, settings infra
- **Phase 2**: Home screen (budgets + recent), Analytics (pie+legends), receipt attachment (camera/gallery/PDF)
- **Phase 3**: Full settings, app security (biometric/PIN with timeout), category budgets

## Packages
flutter_riverpod, hive, hive_flutter, flutter_slidable, intl, fl_chart, uuid, equatable, path_provider, image_picker, file_picker, permission_handler, local_auth
