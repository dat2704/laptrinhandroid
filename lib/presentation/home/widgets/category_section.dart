
import 'package:cua_hang_thoi_trang/presentation/category/category_page.dart';
import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          const Text('DANH MỤC SẢN PHẨM', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.8,
            children: const [
              CategoryCard(title: 'ÁO SƠ MI', imageUrl: 'https://picsum.photos/400/500?random=1'),
              CategoryCard(title: 'ÁO POLO', imageUrl: 'https://picsum.photos/400/500?random=2'),
              CategoryCard(title: 'QUẦN', imageUrl: 'https://picsum.photos/400/500?random=3'),
              CategoryCard(title: 'PHỤ KIỆN', imageUrl: 'https://picsum.photos/400/500?random=4'),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const CategoryCard({super.key, required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CategoryPage(categoryName: title)),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
