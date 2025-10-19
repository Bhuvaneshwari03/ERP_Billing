import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../models/product_model.dart';
import '../utils/bill_pdf.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _shopkeeperNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();

  Product? selectedProduct;
  List<Map<String, dynamic>> billItems = [];

  double get totalAmount {
    return billItems.fold(0, (sum, item) => sum + item['total']);
  }

  Future<List<Product>> getSuggestions(String pattern) async {
    try {
      // Fetch all products from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();
      
      // Convert to Product objects
      List<Product> allProducts = querySnapshot.docs.map((doc) {
        return Product.fromMap(doc.id, doc.data());
      }).toList();
      
      // If no pattern, return all products
      if (pattern.isEmpty) {
        return allProducts;
      }
      
      // Filter products that contain the pattern (case insensitive)
      return allProducts.where((product) {
        return product.name.toLowerCase().contains(pattern.toLowerCase());
      }).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  void addItemToBill() {
    if (selectedProduct == null || _quantityController.text.isEmpty) return;

    int qty = int.parse(_quantityController.text);
    double rate = selectedProduct!.rate;
    double gst = selectedProduct!.gst;

    double amount = qty * rate;
    double gstAmount = amount * (gst / 100);
    double total = amount + gstAmount;

    setState(() {
      billItems.add({
        'product': selectedProduct!,
        'qty': qty,
        'rate': rate,
        'gst': gst,
        'total': total,
      });
      selectedProduct = null;
      _productController.clear();
      _quantityController.clear();
    });
  }

  String getCurrentDate() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Bill")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _shopkeeperNameController,
              decoration: const InputDecoration(labelText: "Shopkeeper Name"),
            ),
            TextField(
              controller: _customerPhoneController,
              decoration: const InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            TypeAheadFormField<Product>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _productController,
                decoration: const InputDecoration(labelText: "Search Product"),
              ),
              suggestionsCallback: getSuggestions,
              itemBuilder: (context, Product suggestion) {
                return ListTile(
                  title: Text(suggestion.name),
                  subtitle: Text("₹${suggestion.rate} | GST ${suggestion.gst}%"),
                );
              },
              onSuggestionSelected: (Product suggestion) {
                setState(() {
                  selectedProduct = suggestion;
                  _productController.text = suggestion.name;
                });
              },
            ),

            if (selectedProduct != null) ...[
              const SizedBox(height: 10),
              Text("Rate: ₹${selectedProduct!.rate} | GST: ${selectedProduct!.gst}%"),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Quantity"),
              ),
              ElevatedButton(
                onPressed: addItemToBill,
                child: const Text("Add to Bill"),
              ),
            ],

            const SizedBox(height: 20),
            const Text("Bill Items", style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: billItems.length,
                itemBuilder: (context, index) {
                  final item = billItems[index];
                  final p = item['product'] as Product;
                  return ListTile(
                    title: Text("${p.name} x${item['qty']}"),
                    subtitle: Text("₹${item['total'].toStringAsFixed(2)}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          billItems.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
            Text("Total: ₹${totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BillPdfPreview(
                      agencyName: _shopkeeperNameController.text.isNotEmpty 
                          ? _shopkeeperNameController.text 
                          : 'Guru Traders', // Default fallback
                      billNumber: 'INV-001', // You can generate dynamically
                      date: getCurrentDate(),
                      items: billItems.map((item) {
                        final p = item['product'] as Product;
                        return {
                          'name': p.name,
                          'qty': item['qty'],
                          'rate': p.rate,
                          'gst': p.gst,
                        };
                      }).toList(),
                    ),
                  ),
                );
              },
              child: const Text('Generate Bill'),
            ),
          ],
        ),
      ),
    );
  }
}
