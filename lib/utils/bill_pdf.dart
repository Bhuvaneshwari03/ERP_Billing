import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';


class BillPdfPreview extends StatelessWidget {
  final String agencyName;
  final String billNumber;
  final String date;
  final List<Map<String, dynamic>> items; // name, qty, rate, gst

  BillPdfPreview({
    required this.agencyName,
    required this.billNumber,
    required this.date,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bill PDF Preview")),
      body: PdfPreview(
        build: (format) => _buildPdf(format),
      ),
    );
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          double grandTotal = 0;

          final tableHeaders = ['Item', 'Qty', 'Rate', 'GST %', 'Total'];
          final tableData = items.map((item) {
            double rate = item['rate'];
            int qty = item['qty'];
            double gst = item['gst'];
            double total = qty * rate * (1 + gst / 100);
            grandTotal += total;

            return [
              item['name'],
              qty.toString(),
              rate.toStringAsFixed(2),
              gst.toStringAsFixed(2),
              total.toStringAsFixed(2),
            ];
          }).toList();

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(agencyName,
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text("Date: $date | Bill No: $billNumber"),
              pw.SizedBox(height: 20),

              pw.TableHelper.fromTextArray(
                headers: tableHeaders,
                data: tableData,
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),

              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("Total: ₹${grandTotal.toStringAsFixed(2)}",
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 30),
              pw.Text("Signature: _____________________"),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
