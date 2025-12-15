import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Корзина'), centerTitle: true),
      body: Consumer<CartProvider>(
        builder: (_, cart, __) {
          if (cart.items.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('Корзина пуста', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            ]));
          }
          return Column(children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cart.items.length,
                itemBuilder: (_, i) {
                  final item = cart.items[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Container(
                          width: 70, height: 70,
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.pets, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text('${_fmt(item.product.price)} сум', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ])),
                        Column(children: [
                          IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => cart.remove(item.product.id)),
                          Row(children: [
                            IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: () => cart.decrement(item.product.id)),
                            Text('${item.quantity}'),
                            IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () => cart.increment(item.product.id)),
                          ]),
                        ]),
                      ]),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
              child: SafeArea(
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Итого:', style: TextStyle(color: Colors.grey[600])),
                    Text('${_fmt(cart.total)} сум', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Оформление заказа скоро!'))),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Оформить заказ'),
                    ),
                  ),
                ]),
              ),
            ),
          ]);
        },
      ),
    );
  }

  String _fmt(double p) => p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
}
