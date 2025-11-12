import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../components/product/product_card.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../services/cart_service.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';
import '../../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _productService = ProductService();
  final _cartService = CartService();
  final _categoryService = CategoryService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Category> _categories = [];
  
  bool _isLoading = true;
  bool _isAddingToCart = false;
  bool _isListening = false;
  String? _error;
  final _searchController = TextEditingController();
  int? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadData();
  }

  void _initSpeech() async {
    await _speech.initialize();
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _searchController.text = result.recognizedWords;
              _filterProducts();
            });
          },
          localeId: 'es_ES',
        );
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _filterProducts() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      _filteredProducts = _allProducts.where((product) {
        bool matchesSearch = query.isEmpty ||
            product.nombre.toLowerCase().contains(query) ||
            (product.descripcion?.toLowerCase() ?? '').contains(query);
        
        bool matchesCategory = _selectedCategoryId == null ||
            product.categoria == _selectedCategoryId;
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _selectCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _filterProducts();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        _productService.getProducts(),
        _categoryService.getCategories(),
      ]);

      setState(() {
        _allProducts = results[0] as List<Product>;
        _categories = results[1] as List<Category>;
        _filteredProducts = List.from(_allProducts);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addToCart(Product product) async {
    try {
      setState(() => _isAddingToCart = true);
      await _cartService.addToCart(product.id, 1);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto agregado al carrito'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'Ver Carrito',
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    String name = categoryName.toLowerCase();
    if (name.contains('cocina')) return Icons.kitchen;
    if (name.contains('refrigera')) return Icons.kitchen_outlined;
    if (name.contains('lavado') || name.contains('lavadora')) return Icons.local_laundry_service;
    if (name.contains('pequeño') || name.contains('aparato')) return Icons.blender;
    if (name.contains('electró')) return Icons.electrical_services;
    if (name.contains('comput')) return Icons.computer;
    if (name.contains('audio') || name.contains('sonido')) return Icons.speaker;
    if (name.contains('video') || name.contains('tv')) return Icons.tv;
    return Icons.category; // Por defecto
  }

  Widget _buildCategoryItem(String nombre, IconData icon, {int? categoryId}) {
    bool isSelected = categoryId == _selectedCategoryId;
    
    return GestureDetector(
      onTap: () => _selectCategory(categoryId),
      child: Container(
        width: 75,
        margin: EdgeInsets.only(right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.grey[200],
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  width: isSelected ? 2.5 : 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              nombre,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SmartSales 365',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _filterProducts(),
                decoration: InputDecoration(
                  hintText: 'Buscar productos...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: _isListening
                      ? IconButton(
                          icon: Icon(Icons.mic, color: Colors.red),
                          onPressed: _stopListening,
                        )
                      : IconButton(
                          icon: Icon(Icons.mic_none, color: Colors.grey[600]),
                          onPressed: _startListening,
                        ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // Categorías horizontales
          Container(
            height: 100,
            color: Colors.white,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    children: [
                      _buildCategoryItem('Todos', Icons.apps),
                      ..._categories.map((category) {
                        IconData icon = _getCategoryIcon(category.nombre);
                        return _buildCategoryItem(category.nombre, icon, categoryId: category.id);
                      }).toList(),
                    ],
                  ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 60, color: AppColors.error),
                              SizedBox(height: 16),
                              Text('Error al cargar productos', style: TextStyle(color: AppColors.error, fontSize: 16, fontWeight: FontWeight.w500)),
                              SizedBox(height: 8),
                              Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                              SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadData,
                                icon: Icon(Icons.refresh),
                                label: Text('Reintentar'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              ),
                            ],
                          ),
                        )
                      : _filteredProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                                  SizedBox(height: 16),
                                  Text(
                                    _searchController.text.isNotEmpty || _selectedCategoryId != null
                                        ? 'No se encontraron productos'
                                        : 'No hay productos disponibles',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.all(12),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.68, // Ajustado para más altura
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () => Navigator.pushNamed(context, '/product-detail', arguments: product),
                                  onAddToCart: () {
                                    if (_isAddingToCart) return;
                                    _addToCart(product);
                                  },
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}