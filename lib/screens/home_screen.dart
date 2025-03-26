import 'dart:io';
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import "package:image_picker/image_picker.dart";
import 'receipt_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  XFile? selectedImage;
  bool isUploading = false;
  String? uploadedImageUrl; // Add a variable to store the uploaded image URL

  Future<void> _uploadToCloudinary() async {
    if (selectedImage == null) return;
    setState(() => isUploading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://api.cloudinary.com/v1_1/dexex1gzu/image/upload"),
      );
      request.fields['upload_preset'] = 'receipt_uploads';
      request.fields['cloud_name'] = 'dexex1gzu'; // Ensure this is correct

      // Ensure the file is added correctly
      if (!kIsWeb) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file', // This must match the expected parameter name
            selectedImage!.path,
          ),
        );
      } else {
        // For web, use bytes instead of file path
        final bytes = await selectedImage!.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'file', // This must match the expected parameter name
            bytes,
            filename: selectedImage!.name,
          ),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);
      if (response.statusCode == 200) {
        await _sendToBackend(jsonResponse["secure_url"]);
        setState(
          () => uploadedImageUrl = jsonResponse["secure_url"],
        ); // Save URL for navigation
      } else {
        debugPrint("Cloudinary Error: ${jsonResponse['error']['message']}");
      }
    } catch (e) {
      debugPrint("Upload Error: $e");
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<void> _sendToBackend(String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost:3000/api/process-receipt"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"imageUrl": imageUrl, "userId": 1}),
      );

      if (response.statusCode == 201) {
        final receiptData = jsonDecode(response.body)["receipt"];
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ReceiptDetailsScreen(
                    receiptData: receiptData,
                    imageUrl: imageUrl,
                  ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Backend Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Expense Management'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.black,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 50),
              ListTile(
                leading: const Icon(Icons.menu, color: Colors.white),
                title: const Text(''),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title: const Text(
                  'Home',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text(
                  'Profile',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text(
                  'Settings',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Log Out'),
                          content: const Text(
                            'Are you sure you want to log out?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              child: const Text('Log Out'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          // Added SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage Receipts',
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome John Doe!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                Column(
                  children:
                      selectedImage != null
                          ? [
                            kIsWeb
                                ? Image.network(
                                  selectedImage!.path,
                                ) // Use Image.network for web
                                : Image.file(
                                  File(selectedImage!.path),
                                ), // Use Image.file for other platforms
                            const SizedBox(height: 20),
                            // Removed the "Continue" button here
                          ]
                          : [
                            Center(
                              child: ElevatedButton.icon(
                                onPressed:
                                    isUploading
                                        ? null
                                        : () async {
                                          final ImagePicker picker =
                                              ImagePicker();
                                          final XFile? image = await picker
                                              .pickImage(
                                                source: ImageSource.gallery,
                                              );
                                          if (image != null) {
                                            setState(
                                              () => selectedImage = image,
                                            );
                                            await _uploadToCloudinary();
                                          }
                                        },
                                icon: const Icon(Icons.upload_file),
                                label:
                                    isUploading
                                        ? const Text('Uploading...')
                                        : const Text('Upload Document'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Center(
                              child: Text(
                                'Limit 200Mb per file .pdf, .jpg, .png',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                ),
                const SizedBox(height: 40),
                const Text(
                  'Recent Receipts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap:
                      true, // Added shrinkWrap to prevent infinite height
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling for ListView
                  itemCount: 0, // Replace with actual data
                  itemBuilder: (context, index) {
                    return const Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text('Receipt Name'),
                        subtitle: Text('Date'),
                        trailing: Text('\$0.00'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new receipt functionality would be implemented here
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
