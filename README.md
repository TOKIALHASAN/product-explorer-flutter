# Product Explorer

Product Explorer is a Flutter application created for a Mobile Application
Development course assignment. The app connects to the public DummyJSON REST API
and displays product data in a clean, responsive interface.

The application allows users to:

- Browse products in a responsive grid.
- View a product's image, title, price, and rating.
- Search for products by name.
- Open a product detail screen.
- Refresh the product list.
- See loading, empty, and error states.

The interface uses Material 3 and the existing API integration in
`lib/services/api_service.dart`.

## API Information

| Item | Value |
| --- | --- |
| API | DummyJSON |
| Base URL | `https://dummyjson.com` |
| Authentication | None required |
| Documentation | <https://dummyjson.com/docs/products> |
| Response format | JSON |

DummyJSON is a public fake REST API used for learning and prototyping. Its
write operations are simulated: requests receive realistic responses, but the
changes are not permanently saved on the server.

## API Endpoints Used

| HTTP Method | Endpoint | Purpose |
| --- | --- | --- |
| GET | `/products?limit=30&skip=0` | Fetch a paginated list of products |
| GET | `/products/{id}` | Fetch one product by its ID |
| GET | `/products/search?q={query}&limit=30&skip=0` | Search products |
| GET | `/products/category/{category}?limit=10&skip=0` | Fetch products in a category |
| POST | `/products/add` | Add a new product |
| PUT | `/products/{id}` | Update an existing product |
| DELETE | `/products/{id}` | Delete a product |

The list screen currently uses the two read endpoints needed by the UI. The API
service also implements the remaining endpoints so the complete CRUD
integration is available.

## HTTP Methods Explained

### GET

`GET` requests retrieve data from the server without changing it.

Examples in this project:

- Fetch all products with pagination.
- Fetch a single product by ID.
- Search products.
- Fetch products by category.

### POST

`POST` sends new data to the server and creates a resource.

In this project, `POST /products/add` sends a JSON object containing fields such
as title, price, category, description, and stock.

### PUT

`PUT` updates an existing resource.

In this project, `PUT /products/{id}` sends only the fields that should change,
such as a new title or price.

### DELETE

`DELETE` removes a resource from the server.

In this project, `DELETE /products/{id}` returns a response containing
`isDeleted: true`.

## JSON Parsing

Dio automatically decodes JSON responses into Dart maps and lists.

### Product parsing

The `Product` model is defined in `lib/models/product.dart`.

`Product.fromJson()` converts one JSON object into a `Product` object:

- Numeric values are converted with `toDouble()` or `toInt()`.
- Text fields use null-safe parsing with sensible defaults.
- `tags` and `images` are converted from JSON lists into `List<String>`.
- The optional `brand` field is stored as `String?`.

### Paginated response parsing

The `ProductPage` model is defined in `lib/models/product_page.dart`.

`ProductPage.fromJson()` reads the paginated response:

```json
{
  "products": [],
  "total": 194,
  "skip": 0,
  "limit": 30
}
```

It creates a list of `Product` objects and stores `total`, `skip`, and `limit`.
The `hasMore` getter reports whether more products are available.

## Pagination

Pagination uses the DummyJSON `limit` and `skip` query parameters:

- `limit` controls how many products are returned.
- `skip` controls how many products are skipped.

Example:

```dart
final firstPage = await apiService.fetchProducts(limit: 10, skip: 0);
final secondPage = await apiService.fetchProducts(limit: 10, skip: 10);
```

The same parameters are supported by the search and category methods. The
current list screen requests one page of 30 products, and the service is ready
for incremental pagination.

## Error Handling

All HTTP requests are wrapped in a shared `_send()` method in `ApiService`.

Dio errors are converted into a custom `ApiException` with a readable message.
The service handles:

- Connection and timeout errors.
- HTTP 400, 401, 403, and 404 responses.
- Server errors such as HTTP 500.
- Cancelled requests and invalid certificates.
- Unexpected response formats.

The UI catches `ApiException` and displays an error message with a retry button.

## Packages Used

| Package | Version | Purpose |
| --- | --- | --- |
| `flutter` | SDK | UI framework |
| `dio` | `^5.11.1` | HTTP requests and JSON handling |
| `flutter_test` | SDK | Unit testing |
| `flutter_lints` | `^6.0.0` | Recommended Dart and Flutter lints |

No additional state-management, routing, or image-caching packages are used.
The project intentionally keeps the implementation simple.

## Project Structure

```text
product_explorer/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── product.dart
│   │   └── product_page.dart
│   ├── screens/
│   │   ├── product_detail_screen.dart
│   │   └── product_list_screen.dart
│   └── services/
│       └── api_service.dart
├── test/
│   └── product_model_test.dart
├── pubspec.yaml
└── README.md
```

### File responsibilities

- `lib/main.dart` sets up the Material 3 application and starts the list screen.
- `lib/models/product.dart` defines the product data model and JSON parsing.
- `lib/models/product_page.dart` defines the paginated product response.
- `lib/services/api_service.dart` contains all API requests and error handling.
- `lib/screens/product_list_screen.dart` displays the grid, search, and states.
- `lib/screens/product_detail_screen.dart` displays full product information.
- `test/product_model_test.dart` verifies JSON parsing for products and pages.

## How to Run the Application

### Prerequisites

- Flutter SDK installed.
- A connected device, emulator, or supported browser.
- Internet access for the DummyJSON API.

### Steps

```bash
flutter pub get
flutter run
```

To run directly in a browser:

```bash
flutter run -d chrome
```

To run on Windows desktop:

```bash
flutter run -d windows
```

### Quality checks

```bash
flutter analyze
flutter test
```

Both commands should complete without errors.

## Assignment Notes

- The existing `ApiService` is reused without duplicating API logic.
- The existing `Product` model is reused throughout the UI.
- The implementation uses only `StatefulWidget`, `Future`, and `setState` for
  state management.
- No complicated architecture or unnecessary packages are introduced.
