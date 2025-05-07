import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:billy/core/theme/app_theme.dart';
import 'package:billy/features/meal/services/receipt_scanning_service.dart';

class HostMealScreen extends ConsumerStatefulWidget {
  const HostMealScreen({super.key});

  @override
  ConsumerState<HostMealScreen> createState() => _HostMealScreenState();
}

class _HostMealScreenState extends ConsumerState<HostMealScreen> {
  File? _receiptImage;
  bool _isLoading = false;
  List<Map<String, dynamic>> _scannedItems = [];
  String? _errorMessage;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _receiptImage = File(image.path);
          _errorMessage = null;
        });
        await _scanReceipt();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: ${e.toString()}';
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        setState(() {
          _receiptImage = File(image.path);
          _errorMessage = null;
        });
        await _scanReceipt();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to take photo: ${e.toString()}';
      });
    }
  }

  Future<void> _scanReceipt() async {
    if (_receiptImage == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ReceiptScanningService.scanReceipt(_receiptImage!);
      print('Scanning result: $result');

      // Extract data from the response
      final totalAmount = result['totalAmount']?['data'] as double?;
      final merchantName = result['merchantName']?['data'] as String?;
      final date = result['date']?['data'] as String?;
      final taxAmount = result['taxAmount']?['data'] as double?;
      final productLineItems =
          result['entities']?['productLineItems'] as List<dynamic>?;

      if (totalAmount != null) {
        setState(() {
          _scannedItems = [
            {
              'name': merchantName ?? 'Unknown Merchant',
              'price': totalAmount,
              'quantity': 1,
              'date': date,
              'tax': taxAmount,
              'isSummary': true,
            },
            if (productLineItems != null && productLineItems.isNotEmpty)
              ...productLineItems.map((item) {
                final itemData = item['data'] as Map<String, dynamic>?;
                return {
                  'name': itemData?['name']?['data'] ?? 'Unknown Item',
                  'price': itemData?['totalPrice']?['data'] ?? 0.0,
                  'quantity': itemData?['quantity']?['data'] ?? 1,
                  'isSummary': false,
                };
              }).toList(),
          ];
        });
      } else {
        setState(() {
          _errorMessage =
              'Could not extract total amount from receipt. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to scan receipt: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Host a Meal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            if (_receiptImage != null)
              Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: FileImage(_receiptImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose Image'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_scannedItems.isNotEmpty) ...[
              const SizedBox(height: 24.0),
              const Text(
                'Scanned Items',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _scannedItems.length,
                itemBuilder: (context, index) {
                  final item = _scannedItems[index];
                  if (item['isSummary'] == true) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item['date'] != null) ...[
                              const SizedBox(height: 8.0),
                              Text(
                                'Date: ${DateTime.parse(item['date']).toLocal().toString().split('.')[0]}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (item['tax'] != null)
                                  Text(
                                    'Tax: \$${item['tax'].toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                Text(
                                  'Total: \$${item['price'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return ListTile(
                      title: Text('${item['quantity']}x ${item['name']}'),
                      trailing: Text(
                        '\$${item['price'].toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
