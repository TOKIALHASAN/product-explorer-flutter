import 'package:flutter_test/flutter_test.dart';

import 'package:product_explorer/models/product.dart';
import 'package:product_explorer/models/product_page.dart';

void main() {
  test('Product.fromJson parses a DummyJSON product', () {
    final product = Product.fromJson({
      'id': 1,
      'title': 'Essence Mascara Lash Princess',
      'description': 'A popular mascara.',
      'category': 'beauty',
      'price': 9.99,
      'discountPercentage': 10.48,
      'rating': 2.56,
      'stock': 99,
      'brand': 'Essence',
      'tags': ['beauty', 'mascara'],
      'images': ['https://example.com/image.webp'],
      'thumbnail': 'https://example.com/thumbnail.webp',
    });

    expect(product.id, 1);
    expect(product.title, 'Essence Mascara Lash Princess');
    expect(product.category, 'beauty');
    expect(product.price, 9.99);
    expect(product.rating, 2.56);
    expect(product.stock, 99);
    expect(product.brand, 'Essence');
    expect(product.tags, ['beauty', 'mascara']);
    expect(product.images, ['https://example.com/image.webp']);
  });

  test('ProductPage.fromJson parses the paginated response', () {
    final page = ProductPage.fromJson({
      'products': [
        {
          'id': 1,
          'title': 'Essence Mascara Lash Princess',
          'description': 'A popular mascara.',
          'category': 'beauty',
          'price': 9.99,
          'discountPercentage': 10.48,
          'rating': 2.56,
          'stock': 99,
          'brand': 'Essence',
          'tags': ['beauty', 'mascara'],
          'images': ['https://example.com/image.webp'],
          'thumbnail': 'https://example.com/thumbnail.webp',
        },
      ],
      'total': 194,
      'skip': 0,
      'limit': 10,
    });

    expect(page.products, hasLength(1));
    expect(page.products.first.title, 'Essence Mascara Lash Princess');
    expect(page.total, 194);
    expect(page.skip, 0);
    expect(page.limit, 10);
    expect(page.hasMore, isTrue);
  });
}
