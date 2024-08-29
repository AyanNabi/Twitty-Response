import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL to PDF Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _urlController = TextEditingController();
  String _pdfPath = '';

  Future<void> _convertUrlToPdf() async {
    String url = _urlController.text;

    try {
      // Fetch HTML content from the URL
      Response response = await Dio().get(url);
      String htmlContent = response.data;

      // Get the directory to save the PDF
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String targetPath = appDocDir.path;
      String targetFileName = "converted_pdf.pdf";

      // Convert HTML to PDF
      var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
          htmlContent, targetPath, targetFileName);

      setState(() {
        _pdfPath = generatedPdfFile.path;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(pdfPath: _pdfPath),
        ),
      );
    } on DioError catch (dioError) {
      print("DioError: ${dioError.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching content: ${dioError.message}')),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('URL to PDF Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter URL',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertUrlToPdf,
              child: Text('Convert to PDF'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String pdfPath;

  PDFViewerScreen({required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View PDF'),
      ),
      body: PDFView(
        filePath: pdfPath,
      ),
    );
  }
}
