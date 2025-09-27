class Product {
  final String id;
  final String title;
  final double price;
  final String thumbnail;
  final List<String> images;
  final String description;
  final String category;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.images,
    required this.description,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // On adapte la logique pour 'fakestoreapi'
    final imageUrl = (json['image'] ?? '').toString();
    return Product(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse('${json['price']}') ?? 0,
      thumbnail: imageUrl, // On utilise 'image' pour la miniature
      images: [imageUrl], // On met 'image' dans une liste pour 'images'
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'thumbnail': thumbnail,
    'images': images,
    'description': description,
    'category': category,
  };
}
