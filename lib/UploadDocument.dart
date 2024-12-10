import 'dart:typed_data'; // For Uint8List (Web)
import 'dart:io'; // For File (Mobile)
import 'package:file_picker/file_picker.dart'; // For PDF selection
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // For PDF viewing
import 'package:image_picker/image_picker.dart';
import 'package:internship_task/main.dart';
import 'package:internship_task/Dashboard.dart';

void main() {
  runApp(const UploadDocumentsApp());
}

class UploadDocumentsApp extends StatelessWidget {
  const UploadDocumentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UploadDocumentsScreen(),
    );
  }
}

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({super.key});

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  final Map<String, dynamic> _uploadedFiles = {
    "Profile Picture": null,
    "Driving License": null,
    "Certificate": null,
    "Passport": null,
  };

  final ImagePicker _picker = ImagePicker();

  Future<void> _showPickerDialog(String documentKey) async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  _updateFile(documentKey, pickedFile);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  _updateFile(documentKey, pickedFile);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Upload PDF'),
              onTap: () async {
                Navigator.pop(context);
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );
                if (result != null) {
                  final fileData = kIsWeb
                      ? result.files.first.bytes // Web: Use Uint8List
                      : result.files.first.path; // Mobile: Use file path
                  setState(() {
                    _uploadedFiles[documentKey] = fileData;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _updateFile(String key, XFile pickedFile) async {
    final fileData = kIsWeb
        ? await pickedFile.readAsBytes() // Web: Uint8List
        : pickedFile.path; // Mobile: File path
    setState(() {
      _uploadedFiles[key] = fileData;
    });
  }

  void _viewDocument(String key) {
    final fileData = _uploadedFiles[key];
    if (fileData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) {
            if (fileData is Uint8List) {
              return FullScreenView(imageData: fileData);
            } else if (fileData is String && fileData.endsWith('.pdf')) {
              return PDFViewerScreen(filePath: fileData);
            } else {
              return FullScreenView(imageData: File(fileData).readAsBytesSync());
            }
          },
        ),
      );
    }
  }

  void _handleBackButton() {
    if (_allDocumentsUploaded()) {
      // Clear documents and navigate back to login
      setState(() {
        _uploadedFiles.updateAll((key, value) => null);
      });
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
    );
  }

  bool _allDocumentsUploaded() {
    return _uploadedFiles.values.every((file) => file != null);
  }

  Color _getTrackColor() {
    int uploadedCount =
        _uploadedFiles.values.where((file) => file != null).length;
    if (uploadedCount == 4) {
      return Colors.green;
    } else if (uploadedCount > 0) {
      return Colors.lightGreen;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBackButton();
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/doc.jpg"), // Add your image in assets
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                AppBar(
                  title: const Text('Upload Documents',style: TextStyle(color: Colors.white),),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: _handleBackButton,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Progress Slider
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Documents Uploaded: ${_uploadedFiles.values.where((file) => file != null).length}/4',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.white, // White for active track
                                inactiveTrackColor: Colors.red, // Dark gray for inactive track
                                thumbColor: Colors.white, // White for thumb
                                overlayColor: Colors.white.withOpacity(0.1), // White overlay for thumb
                              ),
                              child: Slider(
                                value: _uploadedFiles.values
                                    .where((file) => file != null)
                                    .length
                                    .toDouble(),
                                max: 4,
                                divisions: 4,
                                onChanged: null,
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView(
                            children: _uploadedFiles.entries.map((entry) {
                              final key = entry.key;
                              final fileData = entry.value;
                              return GestureDetector(
                                onTap: () => fileData != null
                                    ? _viewDocument(key)
                                    : _showPickerDialog(key),
                                child: Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: fileData != null
                                        ? ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(10),
                                      child: fileData is Uint8List
                                          ? Image.memory(
                                        fileData,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                          : fileData is String &&
                                          fileData.endsWith(
                                              '.pdf')
                                          ? const Icon(
                                        Icons.picture_as_pdf,
                                        size: 50,
                                        color: Colors.red,
                                      )
                                          : Image.file(
                                        File(fileData),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    )
                                        : Center(
                                      child: Text(
                                        'Upload $key',
                                        style: const TextStyle(
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: Tooltip(
                            message: _allDocumentsUploaded()
                                ? ''
                                : 'Please upload all documents',
                            child: ElevatedButton(
                              onPressed: _allDocumentsUploaded()
                                  ? () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardScreen(),
                                  ),
                                );
                              }
                                  : null, // Button becomes inactive when not all documents are uploaded
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _allDocumentsUploaded()
                                    ? Colors.green
                                    : Colors.yellowAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),

                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenView extends StatelessWidget {
  final Uint8List imageData;

  const FullScreenView({super.key, required this.imageData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(217, 188, 111, 10),
      appBar: AppBar(
       backgroundColor: const Color.fromRGBO(217, 188, 111, 10),
       title: const Text('Full Screen View')
      ),
      body: Center(child: Image.memory(imageData)),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String filePath;

  const PDFViewerScreen({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}
