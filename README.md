# Expense Tracker

A personal expense tracking app built with Flutter, following **Clean Architecture** principles. Track your daily spending, organise by category, and view monthly summaries — all stored locally on device with Hive.

---

## Features

- **Add & manage expenses** — create, edit, and delete expense entries
- **Category support** — colour-coded categories with icons, seeded with defaults on first launch
- **Monthly summary** — pie chart breakdown of spending by category per month
- **Offline-first** — all data stored locally using Hive (no backend required)
- **Material 3 design** — modern teal/green finance theme with rounded cards

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter 3.x |
| State Management | Riverpod (`StateNotifier` + `Provider`) |
| Local Database | Hive |
| Charts | fl_chart |
| Architecture | Clean Architecture (Domain / Data / Presentation) |

---

## Project Structure

```
lib/
├── main.dart                        # Hive init, adapter registration, runApp
├── app.dart                         # ProviderScope, MaterialApp, bottom nav
├── core/
│   ├── constants/
│   │   ├── app_colors.dart          # Brand palette (teal finance theme)
│   │   ├── app_strings.dart         # All UI text constants
│   │   └── hive_boxes.dart          # Hive box name constants
│   ├── error/
│   │   └── failures.dart            # Failure types
│   ├── theme/
│   │   └── app_theme.dart           # Material 3 light theme
│   └── utils/
│       └── date_formatter.dart      # Date and currency formatters
└── features/
    ├── expense/
    │   ├── data/
    │   │   ├── datasources/         # Hive box read/write operations
    │   │   ├── models/              # ExpenseModel (Hive typeId = 0)
    │   │   └── repositories/        # ExpenseRepositoryImpl
    │   ├── domain/
    │   │   ├── entities/            # Expense entity (pure Dart)
    │   │   ├── repositories/        # ExpenseRepository (abstract)
    │   │   └── usecases/            # AddExpense, GetExpenses, UpdateExpense, DeleteExpense, GetExpensesByMonth
    │   └── presentation/
    │       ├── providers/           # ExpenseNotifier + Riverpod providers
    │       ├── screens/             # ExpenseListScreen, AddExpenseScreen
    │       └── widgets/             # ExpenseCard
    ├── category/
    │   ├── data/                    # CategoryModel (Hive typeId = 1), datasource, repo impl
    │   ├── domain/                  # Category entity, repository, use cases
    │   └── presentation/            # CategoryNotifier (auto-seeds defaults), CategoryPage
    └── summary/
        ├── domain/                  # MonthlySummary entity, GetMonthlySummary use case
        └── presentation/            # SummaryPage, SummaryPieChart, summaryProvider
```

---

## Architecture

This project follows **Clean Architecture** with three layers per feature:

```
Presentation  →  Domain  ←  Data
(Riverpod)       (Entities,    (Hive models,
                  UseCases,     Datasources,
                  Repos)        RepoImpls)
```

- **Domain layer** has zero Flutter/Hive dependencies — pure Dart classes only
- **Data layer** owns Hive models with `fromEntity` / `toEntity` converters
- **Presentation layer** wires everything through Riverpod providers

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`

### Run

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Generate Hive adapters (if needed)

The `.g.dart` adapter files are pre-written and committed. If you modify a Hive model, regenerate with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Dependencies

```yaml
# Runtime
flutter_riverpod: ^2.5.1    # State management
hive: ^2.2.3                 # Local database
hive_flutter: ^1.1.0         # Hive Flutter integration
fl_chart: ^0.68.0            # Pie charts
flutter_slidable: ^3.1.0     # Swipe-to-delete on expense cards
intl: ^0.19.0                # Date and currency formatting
uuid: ^4.4.0                 # Unique ID generation
equatable: ^2.0.5            # Value equality

# Dev
hive_generator: ^2.0.1       # Hive adapter codegen
build_runner: ^2.4.9         # Code generation runner
```

---

## License

MIT
