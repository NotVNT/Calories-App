import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Thực Đơn',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFAAF0D1),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFAAF0D1),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Yêu thích'),
            Tab(text: 'Của tôi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllMenuTab(),
          _buildFavoriteMenuTab(),
          _buildMyMenuTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new recipe
        },
        backgroundColor: const Color(0xFFAAF0D1),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAllMenuTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCategorySection('Bữa sáng', [
          _buildRecipeCard('Phở bò', '350 kcal', Icons.ramen_dining),
          _buildRecipeCard('Bánh mì', '280 kcal', Icons.bakery_dining),
        ]),
        const SizedBox(height: 20),
        _buildCategorySection('Bữa trưa', [
          _buildRecipeCard('Cơm gà', '450 kcal', Icons.rice_bowl),
          _buildRecipeCard('Bún chả', '420 kcal', Icons.restaurant),
        ]),
        const SizedBox(height: 20),
        _buildCategorySection('Bữa tối', [
          _buildRecipeCard('Salad', '180 kcal', Icons.eco),
          _buildRecipeCard('Cá hồi nướng', '320 kcal', Icons.set_meal),
        ]),
      ],
    );
  }

  Widget _buildFavoriteMenuTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có món ăn yêu thích',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn vào biểu tượng trái tim để lưu món ăn',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyMenuTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có công thức của bạn',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút + để tạo công thức mới',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, List<Widget> recipes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...recipes,
      ],
    );
  }

  Widget _buildRecipeCard(String name, String calories, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFAAF0D1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFAAF0D1), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.local_fire_department, 
                      size: 16, 
                      color: Colors.orange[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      calories,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            color: Colors.grey[400],
            onPressed: () {
              // TODO: Toggle favorite
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: const Color(0xFFAAF0D1),
            onPressed: () {
              // TODO: Add to meal
            },
          ),
        ],
      ),
    );
  }
}

