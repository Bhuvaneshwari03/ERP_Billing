import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController unitController = TextEditingController();

  void addProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        final product = Product(
          id: '',
          name: nameController.text.trim(),
          rate: double.parse(rateController.text.trim()),
          gst: double.parse(gstController.text.trim()),
          unit: unitController.text.trim(),
        );
        
        await FirebaseFirestore.instance
            .collection('products')
            .add(product.toMap());

        // Clear form fields and reset form state
        nameController.clear();
        rateController.clear();
        gstController.clear();
        unitController.clear();
        _formKey.currentState!.reset();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Product added successfully!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error adding product: $e"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product Master")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Product Name"),
                  validator: (val) => val!.isEmpty ? "Enter name" : null,
                ),
                TextFormField(
                  controller: rateController,
                  decoration: const InputDecoration(labelText: "Rate"),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? "Enter rate" : null,
                ),
                TextFormField(
                  controller: gstController,
                  decoration: const InputDecoration(labelText: "GST %"),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? "Enter GST" : null,
                ),
                TextFormField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: "Unit (e.g., Pack)"),
                  validator: (val) => val!.isEmpty ? "Enter unit" : null,
                ),
                const SizedBox(height: 10),
                ElevatedButton(onPressed: addProduct, child: const Text("Add Product")),
              ]),
            ),
            const SizedBox(height: 20),
            const Text("All Products", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error loading products: ${snapshot.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => setState(() {}),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No products found. Add your first product above!'),
                        ],
                      ),
                    );
                  }
                  
                  final products = snapshot.data!.docs.map((doc) {
                    return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
                  }).toList();

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                          title: Text(
                            p.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text("₹${p.rate} | GST: ${p.gst}% | Unit: ${p.unit}"),
                          trailing: Icon(Icons.check_circle, color: Colors.green.shade600),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
