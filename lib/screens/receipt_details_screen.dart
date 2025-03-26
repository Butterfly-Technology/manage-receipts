import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ReceiptDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> receiptData;
  final String imageUrl;

  const ReceiptDetailsScreen({
    super.key,
    required this.receiptData,
    required this.imageUrl,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ReceiptDetailsScreenState createState() => _ReceiptDetailsScreenState();
}

class _ReceiptDetailsScreenState extends State<ReceiptDetailsScreen> {
  String? selectedCategory;
  TextEditingController customCategoryController = TextEditingController();
  String? savedFilePath; // To store the path of the saved file

  Future<void> _saveDetails() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/receipt_details.txt');

      // Prepare data to save
      final data = '''
Merchant: ${widget.receiptData['merchant'] ?? "Unknown Merchant"}
Amount: ${widget.receiptData['amount']?.toString() ?? "0.00"}
Date: ${widget.receiptData['receiptDate'] ?? "N/A"}
Category: ${selectedCategory ?? "N/A"}
Custom Category: ${customCategoryController.text.isNotEmpty ? customCategoryController.text : "N/A"}
      ''';

      // Write data to file
      await file.writeAsString(data);

      setState(() {
        savedFilePath = file.path; // Update the saved file path
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Details saved successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save details: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Receipt Details")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Fixed-size Receipt Image Block (Showing Full Image)
                  Container(
                    width: double.infinity,
                    height: 250, // Fixed height
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color.fromARGB(255, 8, 8, 8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          spreadRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child:
                        widget.imageUrl.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.imageUrl,
                                width: double.infinity,
                                height: 230, // Fixed height
                                fit:
                                    BoxFit
                                        .contain, // Shows the full image inside the block
                              ),
                            )
                            : const Center(child: Text("No Image Available")),
                  ),
                  const SizedBox(height: 20),

                  // Merchant, Amount, Date Fields
                  _buildDetailField(
                    "Merchant Name",
                    widget.receiptData['merchant'] ?? "Unknown Merchant",
                  ),
                  _buildDetailField(
                    "Amount",
                    widget.receiptData['amount']?.toString() ?? "0.00",
                  ),
                  _buildDetailField(
                    "Date",
                    widget.receiptData['receiptDate'] ?? "N/A",
                  ),
                  const SizedBox(height: 20),

                  // Category Dropdown
                  _buildCategoryDropdown(),
                  const SizedBox(height: 20),

                  // Save Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveDetails, // Call the save method
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 8, 8, 8),
                      ),
                      child: const Text("Save"),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Display Saved File Content
                  if (savedFilePath != null)
                    FutureBuilder<String>(
                      future: File(savedFilePath!).readAsString(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Saved Details:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(snapshot.data ?? "No data available"),
                            ],
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: value,
            decoration: const InputDecoration(border: UnderlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          items:
              [
                    "Meal",
                    "Education",
                    "Rent",
                    "Shopping",
                    "Travel",
                    "Investment",
                    "Other",
                  ]
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
          onChanged: (value) => setState(() => selectedCategory = value),
          decoration: const InputDecoration(border: UnderlineInputBorder()),
        ),
        if (selectedCategory == "Other")
          TextFormField(
            controller: customCategoryController,
            decoration: const InputDecoration(
              hintText: "Enter custom category",
            ),
          ),
      ],
    );
  }
}
