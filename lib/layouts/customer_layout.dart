import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/purchase/purchase_history_screen.dart';
import '../services/cart_service.dart';
import '../utils/app_colors.dart';

class CustomerLayout extends StatefulWidget {
  const CustomerLayout({Key? key}) : super(key: key);

  @override
  _CustomerLayoutState createState() => _CustomerLayoutState();
}

class _CustomerLayoutState extends State<CustomerLayout> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  int _cartItemCount = 0;
  final _cartService = CartService();
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const CartScreen(),
    const PurchaseHistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCartCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadCartCount();
    }
  }

  Future<void> _loadCartCount() async {
    try {
      final items = await _cartService.getCartItems();
      if (mounted) {
        setState(() {
          _cartItemCount = items.fold(0, (sum, item) => sum + (item['cantidad'] as int? ?? 0));
        });
      }
    } catch (e) {
      // Silenciosamente manejar el error
      if (mounted) {
        setState(() {
          _cartItemCount = 0;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Recargar el contador cuando se navega
    _loadCartCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.shopping_cart),
                if (_cartItemCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        _cartItemCount > 99 ? '99+' : '$_cartItemCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Mis Compras',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}