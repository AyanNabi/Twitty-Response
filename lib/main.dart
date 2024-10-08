import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'SplashScreen.dart'; // For MediaType

void main() {

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: LoginPage(),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  File? _image;
  final TextEditingController _promptController = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (_image == null || _promptController.text.isEmpty) {
      // Show an error message if image or prompt is missing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image and enter a prompt.')),
      );
      return;
    }

    setState(() {
      _loading = true; // Start loading
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:7010/api/PngToResponse/PngToText?prompt=${Uri.encodeComponent(_promptController.text)}'),
    );

    request.files.add(
      http.MultipartFile(
        'file',
        _image!.readAsBytes().asStream(),
        await _image!.length(),
        filename: 'uploaded_image.jpg',
        contentType: MediaType('image', 'jpg'),
      ),
    );

    try {
      print('problem yoxdu'); // For debugging
      var response = await request.send();
      print('problem var'); // For debugging

      if (response.statusCode == 200) {
        // Read response if needed
        var responseString = await response.stream.bytesToString();
        _showResponseDialog(responseString);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission successful!')),
        );
        print('Response: $responseString'); // For debugging
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed with status code ${response.statusCode}.')),
        );
        print('Error: ${response.reasonPhrase}'); // For debugging
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );

    }finally {
      setState(() {
        _loading = false; // End loading
      });

    }
  }


  void _showResponseDialog(String response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Response'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(response),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: response));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Response copied to clipboard')),
                    );
                  },
                  child: Text('Copy to Clipboard'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x401D1E26),
            offset: Offset(10.0, 10.0),
            blurRadius: 20.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '11:33',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 17.0,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    SvgPicture.network(
                      'assets/vectors/mobile_signal_63_x2.svg',
                      width: 20.0,
                      height: 16.0,
                    ),
                    SizedBox(width: 8.0),
                    SvgPicture.network(
                      'assets/vectors/wifi_16_x2.svg',
                      width: 18.0,
                      height: 13.0,
                    ),
                    SizedBox(width: 8.0),
                    SvgPicture.network(
                      'assets/vectors/battery_10_x2.svg',
                      width: 28.0,
                      height: 13.0,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 32.0),
            Stack(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 100.0,
                      height: 80.0,
                      child: SvgPicture.network(
                        'assets/vectors/vector_793_x2.svg',
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Container(
                      width: 4.0,
                      height: 120.0,
                      color: Color(0xFF0D2552),
                    ),
                    SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'twitty',
                          style: GoogleFonts.robotoCondensed(
                            fontWeight: FontWeight.w800,
                            fontSize: 32.0,
                            color: Color(0xFF0D2552),
                          ),
                        ),
                        SizedBox(height: 16.0),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 32.0),
            Text(
              'Welcome!',
              textAlign: TextAlign.start,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 30.0,
                color: Color(0xFF0D2552),
              ),
            ),
            SizedBox(height: 16.0),

            ImageUploadButton(
              onImageSelected: (File? image) {
                setState(() {
                  _image = image;
                });
              },
            ),
            SizedBox(height: 16.0),

            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0x4DC4C4C4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Enter prompt here',
              ),
              maxLines: 1,
            ),

            SizedBox(height: 16.0),

            SizedBox(height: 32.0),
            GestureDetector(
              onTap: _submit,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF522258),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Center(
                  child:  _loading
                    ? CircularProgressIndicator(color: Colors.white) // Show loading indicator
                    :  Text(
                    'Submit',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 23.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120.0,
                  height: 1.0,
                  color: Color(0xFFB3B3B3),
                ),
                SizedBox(width: 16.0),

                Container(
                  width: 120.0,
                  height: 1.0,
                  color: Color(0xFFB3B3B3),
                ),
              ],
            ),
            SizedBox(height: 32.0),

            SizedBox(
              width: double.infinity,
              height: 6.0,
              child: SvgPicture.network(
                'assets/vectors/line_23_x2.svg',
              ),
            ),
            SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }
}

class ImageUploadButton extends StatefulWidget {
  final ValueChanged<File?> onImageSelected;

  ImageUploadButton({required this.onImageSelected});

  @override
  _ImageUploadButtonState createState() => _ImageUploadButtonState();
}

class _ImageUploadButtonState extends State<ImageUploadButton> {
  File? _image;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
      widget.onImageSelected(_image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0x4DC4C4C4),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Color(0xFFB3B3B3), width: 1.0),
        ),
        width: double.infinity,
        height: 56.0,
        child: Center(
          child: _image == null
              ? Text(
            'Şəkil seçin',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 16.0,
              color: Colors.black,
            ),
          )
              : Image.file(
            _image!,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
