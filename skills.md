# Expense Tracker — AI Assistant Skills Reference

> Quick-reference for AI assistants working on this Flutter project across sessions.

---

## Stack & Tools

| Layer              | Technology                                      |
| ------------------ | ----------------------------------------------- |
| Framework          | Flutter 3.x, Material 3 (`useMaterial3: true`)  |
| Architecture       | Clean Architecture (Domain → Data → Presentation) |
| State Management   | Riverpod 2 — `StateNotifier`, `FutureProvider`, `StateProvider` |
| Local DB           | Hive (`Box<ExpenseModel>`, `Box<CategoryModel>`, `Box<double>`, plain `Box`) |
| Charts             | fl_chart (PieChart)                             |
| Auth               | local_auth (biometric + PIN)                    |
| Media              | image_picker, file_picker, permission_handler   |
| Formatting         | intl (`DateFormat`, `NumberFormat`)              |
| IDs                | uuid                                            |

---

## Hive Boxes

| Box Name           | Dart Type               | TypeId | Purpose                |
| ------------------ | ----------------------- | ------ | ---------------------- |
| `expenses`         | `Box<ExpenseModel>`     | 0      | All expense records    |
| `categories`       | `Box<CategoryModel>`    | 1      | User + default categories |
| `settings`         | `Box` (plain/dynamic)   | —      | Key-value app settings |
| `category_budgets` | `Box<double>`           | —      | Per-category budget limits |

Opened in `main.dart` before `runApp`. Adapters manually maintained (no build_runner needed).

---

## Entities & Models

### Expense
```
id: String (UUID)  |  title: String  |  amount: double
categoryId: String |  date: DateTime |  notes: String?
receiptPath: String?
```
Model: `ExpenseModel` (HiveField 0-6), `fromEntity()` / `toEntity()`.

### Category
```
id: String  |  name: String  |  iconCodePoint: int  |  colorValue: int
```
7 default categories seeded in `CategoryNotifier._init()`:
food, transport, shopping, health, bills, entertainment, other.

### MonthlySummary
```
year: int  |  month: int  |  totalAmount: double
byCategory: List<CategoryTotal>  (categoryId, categoryName, colorValue, total)
```

---

## Provider Map

### Expense
| Provider                     | Type                                           |
| ---------------------------- | ---------------------------------------------- |
| `expenseNotifierProvider`    | `StateNotifierProvider<ExpenseNotifier, AsyncValue<List<Expense>>>` |
| `monthlyExpensesProvider`    | `FutureProvider.autoDispose<List<Expense>>`     |
| `expenseRepositoryProvider`  | `Provider<ExpenseRepository>`                   |

Methods on notifier: `load()`, `add(expense)`, `delete(id)`, `update(expense)`.

### Category
| Provider                     | Type                                           |
| ---------------------------- | ---------------------------------------------- |
| `categoryNotifierProvider`   | `StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>` |

Methods: `load()`, `add(name, iconCodePoint, colorValue)`.

### Settings
| Provider                     | Type                   | Default          |
| ---------------------------- | ---------------------- | ---------------- |
| `currencySymbolProvider`     | `StateProvider<String>`| From Hive        |
| `currencyCodeProvider`       | `StateProvider<String>`| From Hive        |
| `monthlyBudgetProvider`      | `StateProvider<double>`| From Hive        |
| `appLockEnabledProvider`     | `StateProvider<bool>`  | From Hive        |
| `appLockTypeProvider`        | `StateProvider<String>`| `'pin'`/`'biometric'` |
| `lockTimeoutProvider`        | `StateProvider<int>`   | Minutes          |
| `isFirstLaunchProvider`      | `Provider<bool>`       | One-time flag    |
| `settingsRepositoryProvider` | `Provider<SettingsRepository>` | —        |

### Summary
| Provider                     | Type                                           |
| ---------------------------- | ---------------------------------------------- |
| `monthlySummaryProvider`     | `FutureProvider.autoDispose<MonthlySummary>`    |
| `selectedMonthProvider`      | `StateProvider<DateTime>`                       |

### Security
| Provider                     | Type                          |
| ---------------------------- | ----------------------------- |
| `authServiceProvider`        | `Provider<AuthService>`       |
| `biometricAvailableProvider` | `FutureProvider<bool>`        |

### Category Budgets
| Provider                     | Type                              |
| ---------------------------- | --------------------------------- |
| `categoryBudgetsProvider`    | `StateProvider<Map<String,double>>`|

---

## Navigation & Screens

```
ExpenseTrackerApp
└─ SplashScreen (animated, 2s)
   ├─ (first launch) → CurrencySetupPage → MainScaffold
   └─ (returning)    → MainScaffold

MainScaffold (wrapped in SecurityGate)
├── Tab 0: HomeScreen           — budget hero, category spending, recent expenses
├── Tab 1: ExpenseListScreen    — month's expenses, slidable delete
├── Tab 2: SummaryPage          — pie chart, month selector, breakdown
├── Tab 3: SettingsScreen       — budget/currency, categories, security, about
├── FAB  → AddExpenseScreen     — amount hero, form card, receipt, save
│
├── Settings → CategoryPage           (view/add categories)
├── Settings → CategoryBudgetPage     (per-category budgets)
├── Settings → PinSetupPage           (create 4-digit PIN)
└── SecurityGate → LockScreen         (PIN keypad / biometric retry)
```

**Bottom nav**: 4 tabs via `BottomAppBar` + `CircularNotchedRectangle`, center docked FAB. Uses `GestureDetector` (no splash/shadow).

---

## Key Patterns

### State Updates After Settings Change
```dart
// 1. Persist to Hive via repository
await repo.setMonthlyBudget(amount);
// 2. Manually update StateProvider
ref.read(monthlyBudgetProvider.notifier).state = amount;
```

### Expense CRUD Flow
```
UI → ExpenseNotifier.add(expense) → AddExpense usecase
  → ExpenseRepositoryImpl.addExpense() → ExpenseLocalDatasource.add()
  → Hive box.put(model) → notifier._loadExpenses() → UI rebuilds
```

### Security Gate (Background Lock)
```
WidgetsBindingObserver in SecurityGate (app.dart):
  paused  → record timestamp
  resumed → if (elapsed >= timeout) show LockScreen
```

### Category Budget Integration
Home screen reads `categoryBudgetsProvider`. If a category has a budget:
- Progress bar = spent / budget (clamped 0–1)
- Label shows "spent / budget"
- Bar turns red when over budget

---

## File Tree

```
lib/
├── main.dart
├── app.dart                              # MainScaffold + SecurityGate
├── core/
│   ├── constants/
│   │   ├── app_colors.dart               # primary=#00897B, 7-color palette
│   │   ├── app_strings.dart              # All UI text
│   │   ├── hive_boxes.dart               # Box name constants
│   │   └── currencies.dart               # 12 currencies (INR,USD,EUR…)
│   ├── error/failures.dart
│   ├── theme/app_theme.dart
│   └── utils/
│       ├── date_formatter.dart           # formatCurrency(amount, symbol:)
│       └── receipt_helper.dart           # pickFromCamera/Gallery/Pdf
├── features/
│   ├── expense/
│   │   ├── domain/entities/expense.dart
│   │   ├── domain/repositories/expense_repository.dart
│   │   ├── domain/usecases/{add,delete,get,get_by_month,update}_expense.dart
│   │   ├── data/models/expense_model.dart + .g.dart
│   │   ├── data/datasources/expense_local_datasource.dart
│   │   ├── data/repositories/expense_repository_impl.dart
│   │   ├── presentation/providers/expense_provider.dart
│   │   ├── presentation/screens/add_expense_screen.dart
│   │   ├── presentation/screens/expense_list_screen.dart
│   │   └── presentation/widgets/{expense_card,receipt_picker_widget}.dart
│   ├── category/
│   │   ├── domain/entities/category.dart  (+ defaultCategories)
│   │   ├── data/models/category_model.dart + .g.dart
│   │   ├── data/datasources/category_local_datasource.dart
│   │   ├── data/repositories/category_repository_impl.dart
│   │   ├── presentation/providers/category_provider.dart
│   │   └── presentation/pages/category_page.dart
│   ├── summary/
│   │   ├── domain/entities/monthly_summary.dart
│   │   ├── domain/usecases/get_monthly_summary.dart
│   │   ├── presentation/providers/summary_provider.dart
│   │   ├── presentation/pages/summary_page.dart
│   │   └── presentation/widgets/summary_pie_chart.dart
│   ├── home/
│   │   └── presentation/pages/home_screen.dart
│   ├── onboarding/
│   │   └── presentation/pages/{splash_screen,currency_setup_page}.dart
│   ├── security/
│   │   ├── data/auth_service.dart
│   │   ├── presentation/providers/security_provider.dart
│   │   └── presentation/pages/{lock_screen,pin_setup_page}.dart
│   └── settings/
│       ├── domain/repositories/settings_repository.dart
│       ├── data/datasources/settings_local_datasource.dart
│       ├── data/repositories/settings_repository_impl.dart
│       ├── presentation/providers/settings_provider.dart
│       └── presentation/pages/{settings_screen,category_budget_page}.dart
```

---

## Platform Config

### Android
- `FlutterFragmentActivity` (required by local_auth)
- Permissions: `CAMERA`, `READ_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES`, `USE_BIOMETRIC`

### iOS
- `NSFaceIDUsageDescription` — Face ID for app lock
- `NSCameraUsageDescription` — Receipt photos
- `NSPhotoLibraryUsageDescription` — Receipt gallery

---

## Supported Currencies

INR (₹), USD ($), EUR (€), GBP (£), JPY (¥), AUD (A$), CAD (C$), CHF (CHF), CNY (¥), KRW (₩), SGD (S$), AED (د.إ)

---

## Default Category Icons

| Category      | Icon Code   | Material Icon          | Color    |
| ------------- | ----------- | ---------------------- | -------- |
| Food          | `0xe56c`    | restaurant             | Red      |
| Transport     | `0xe1d7`    | directions_car         | Blue     |
| Shopping      | `0xf37e`    | shopping_bag           | Yellow   |
| Health        | `0xe548`    | local_hospital         | Teal     |
| Bills         | `0xe4c0`    | receipt_long           | Purple   |
| Entertainment | `0xe40f`    | sports_esports         | Orange   |
| Other         | `0xe5d3`    | more_horiz             | Grey     |

---

## Settings Keys (Hive `settings` box)

`currency`, `currencySymbol`, `monthlyBudget`, `isFirstLaunch`, `appLockEnabled`, `appLockType`, `appLockPin`, `lockTimeoutMinutes`

---

## Common Commands

```bash
flutter pub get          # Install dependencies
flutter analyze          # Check for errors
flutter run              # Run on connected device
```
