# 🛠️ Mass Spare Parts — Shop Management App

**Mass Spare Parts** is an offline mobile application built with **Flutter & SQLite** for daily spare-parts shop operations specializing in **Bajaj & Car auto spare parts**.

The application is engineered to operate 100% offline on Android devices, serving as the local source of truth for daily product inventory, stock levels, sales, and shop management. QuickBooks Desktop remains the primary accounting system.

---

## 🚀 Key Features

* **⚡ 100% Offline Architecture**: No internet, remote API, or cloud database required. Uses local SQLite (`sqflite`).
* **📊 Home Dashboard**:
  * Real-time SQLite metrics: **Today's Sales**, **Transactions Count**, **Total Inventory Valuation**, and **Low Stock Warnings**.
  * Quick Actions: New Sale, Receive Stock, Products Catalog, Inventory.
  * Prominent **● Offline** status badge indicator.
* **📦 Complete Products Module**:
  * Support for **Cars** and **Bajaj** spare-parts categories.
  * **Live Search**: Instant filtering while typing by Name, SKU, Barcode, Brand, Vehicle Compatibility, or Model.
  * **Filter Chips**: All, Cars, Bajaj, Low Stock, Out of Stock.
  * **Add & Edit Product**: Form validation, duplicate SKU prevention, numeric keyboard bindings, cost/selling price rules.
  * **Local Image Picker**: Select product photos from Android device camera or gallery stored locally.
  * **Product Details View**:
    * **Estimated Stock Value**: `stock_quantity × cost_price`
    * **Potential Sales Value**: `stock_quantity × selling_price`
    * Stock status badges (**In Stock**, **Low Stock**, **Out of Stock**).
  * **Safe Soft Deactivation**: Deactivates products (`is_active = 0`) to preserve historical sales & inventory logs.

---

## 🛠️ Tech Stack & Dependencies

* **Framework**: [Flutter](https://flutter.dev/) (Dart 3)
* **UI Design System**: Material 3 Industrial Theme (Shop Orange & Dark Charcoal)
* **Local Database**: [`sqflite`](https://pub.dev/packages/sqflite) (SQLite)
* **Device Storage & Paths**: [`path_provider`](https://pub.dev/packages/path_provider) & [`path`](https://pub.dev/packages/path)
* **Media Handling**: [`image_picker`](https://pub.dev/packages/image_picker)
* **Formatting**: [`intl`](https://pub.dev/packages/intl)

---

## 🗄️ Database Architecture

The application initializes an offline SQLite database (`mass_spare_parts.db`) with index optimizations on `name`, `sku`, `barcode`, and foreign key relations:

```
products
├── id (INTEGER PRIMARY KEY)
├── name (TEXT)
├── sku (TEXT UNIQUE)
├── barcode (TEXT)
├── category (TEXT: 'Cars' | 'Bajaj')
├── brand (TEXT)
├── vehicle (TEXT)
├── model (TEXT)
├── image_path (TEXT)
├── cost_price (REAL)
├── selling_price (REAL)
├── stock_quantity (INTEGER)
├── minimum_stock (INTEGER)
├── is_active (INTEGER)
├── created_at (TEXT)
└── updated_at (TEXT)

sales
├── id (INTEGER PRIMARY KEY)
├── sale_number (TEXT UNIQUE)
├── total_amount (REAL)
├── payment_method (TEXT)
└── created_at (TEXT)

sale_items
├── id (INTEGER PRIMARY KEY)
├── sale_id (FK -> sales.id)
├── product_id (FK -> products.id)
├── quantity (INTEGER)
├── unit_price (REAL)
└── total_price (REAL)

inventory_transactions
├── id (INTEGER PRIMARY KEY)
├── product_id (FK -> products.id)
├── transaction_type (TEXT: 'opening_stock', 'IN', 'OUT')
├── quantity (INTEGER)
├── reference_id (TEXT)
├── note (TEXT)
└── created_at (TEXT)
```

---

## 📲 Getting Started

### Prerequisites
* Flutter SDK (3.24+ / 3.35+)
* Android SDK & Device / Emulator

### Installation & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/bukhaari1511/mass-app.git
   cd mass-app
   ```

2. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```

3. Run on connected Android device / emulator:
   ```bash
   flutter run
   ```

4. Run code analyzer & tests:
   ```bash
   flutter analyze
   flutter test
   ```

---

## 📦 Building Android Release APK

To generate an installable standalone Android APK (`.apk`):

```bash
flutter build apk --release
```

The compiled APK will be output at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📄 License

Private repository for Mass Spare Parts shop operations.
