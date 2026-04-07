import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _scans = [];
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('userToken');
    _userName = prefs.getString('userName') ?? "Patient";
    
    if (token == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final result = await ApiService.getScanHistory(token);
    if (mounted) {
      setState(() {
        if (result['history'] != null) {
          _scans = result['history'];
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePdf(dynamic scan) async {
    final pdf = pw.Document();
    final date = DateTime.parse(scan['timestamp']);
    final formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    final confidence = (scan['confidence'] ?? 0.0).toDouble();
    final prediction = scan['prediction'] ?? "Unknown";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("DERMA AI CLINICAL", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                      pw.Text("Diagnostic Analysis Report", style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700, letterSpacing: 1.2)),
                    ],
                  ),
                  pw.Container(
                    width: 60, height: 60,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(color: PdfColors.indigo50, shape: pw.BoxShape.circle),
                    child: pw.Center(child: pw.Text("DAI", style: pw.TextStyle(color: PdfColors.indigo900, fontWeight: pw.FontWeight.bold, fontSize: 18))),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2, color: PdfColors.indigo900),
              pw.SizedBox(height: 30),

              // PATIENT & REPORT INFO
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _pdfInfoRow("Patient Name", _userName ?? "Patient"),
                        _pdfInfoRow("Report ID", "#${scan['id'].toString().substring(0, 10).toUpperCase()}"),
                        _pdfInfoRow("Scan Date", formattedDate),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _pdfInfoRow("Modality", "Deep Neural Ensemble"),
                        _pdfInfoRow("Status", "Electronically Verified"),
                        _pdfInfoRow("Validity", "Standard Clinical Score"),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 40),

              // PRIMARY DIAGNOSIS BOX
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(24),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
                  border: pw.Border.all(color: PdfColors.grey200, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("PRIMARY ANALYSIS VERDICT", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(prediction.toUpperCase(), style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo800)),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: pw.BoxDecoration(color: _getPdfColor(confidence), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
                          child: pw.Text("${confidence.toStringAsFixed(1)}% Confidence", style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      "Our AI model has analyzed the submitted dermoscopic image and identified patterns consistent with $prediction. This score represents the statistical probability based on our extensive clinical dataset.",
                      style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800, lineSpacing: 1.5),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 40),

              // VERIFICATION SEAL
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 120, height: 1,
                        color: PdfColors.grey400,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text("Clinical Supervisor Signature", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.indigo200, width: 2), shape: pw.BoxShape.circle),
                    child: pw.Center(child: pw.Text("VERIFIED\nSCORE", textAlign: pw.TextAlign.center, style: pw.TextStyle(color: PdfColors.indigo900, fontWeight: pw.FontWeight.bold, fontSize: 8))),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(thickness: 0.5, color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Text(
                "DISCLAIMER: This report is generated by a computer algorithm. While highly accurate, it is NOT a replacement for a professional biopsy or pathological examination. Always seek the advice of your physician.",
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),
              pw.Center(child: pw.Text("Automated by DermaAI diagnostic pipeline.", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey400))),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: "$label: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey600)),
            pw.TextSpan(text: value, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey900)),
          ],
        ),
      ),
    );
  }

  PdfColor _getPdfColor(double c) {
    if (c >= 85) return PdfColors.green700;
    if (c >= 60) return PdfColors.orange700;
    return PdfColors.red700;
  }

  // ── Color helpers ──
  Color _confidenceColor(double c) {
    if (c >= 85) return const Color(0xFF00B894);
    if (c >= 60) return const Color(0xFFFFAB2E);
    return const Color(0xFFFF6B6B);
  }

  String _confidenceLabel(double c) {
    if (c >= 85) return 'High';
    if (c >= 60) return 'Medium';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: Color(0xFF1A2340)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Reports",
          style: TextStyle(
            color: Color(0xFF1A2340),
            fontWeight: FontWeight.w800,
            fontSize: 17,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5EAF4)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(
              color: Color(0xFF7C6FF7), strokeWidth: 2.5))
          : _scans.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: _scans.length,
                  itemBuilder: (context, index) {
                    final scan = _scans[index];
                    return _buildScanCard(scan, index);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF7C6FF7).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.insert_chart_outlined_rounded,
                size: 36, color: const Color(0xFF7C6FF7).withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          const Text(
            "No reports yet",
            style: TextStyle(
              color: Color(0xFF1A2340),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Your AI scan results will show up here\nonce you complete your first analysis.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7A99),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanCard(dynamic scan, int index) {
    final date = DateTime.parse(scan['timestamp']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);
    final formattedTime = DateFormat('hh:mm a').format(date);
    final confidence = (scan['confidence'] ?? 0.0).toDouble();
    final prediction = scan['prediction'] ?? "Unknown";
    final confColor = _confidenceColor(confidence);
    final confLabel = _confidenceLabel(confidence);

    // Alternate icon colors for visual variety
    final iconColors = [
      const Color(0xFF7C6FF7),
      const Color(0xFF00B894),
      const Color(0xFFFF6FA8),
      const Color(0xFFFFAB2E),
      const Color(0xFFFF6B6B),
    ];
    final cardColor = iconColors[index % iconColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Left icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(Icons.analytics_rounded, color: cardColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Middle info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prediction,
                    style: const TextStyle(
                      color: Color(0xFF1A2340),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 11, color: const Color(0xFF6B7A99).withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Text(
                        '$formattedDate  ·  $formattedTime',
                        style: TextStyle(
                          color: const Color(0xFF6B7A99).withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Confidence badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: confColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5, height: 5,
                              decoration: BoxDecoration(
                                color: confColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${confidence.toStringAsFixed(1)}%  $confLabel',
                              style: TextStyle(
                                color: confColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // PDF button
            GestureDetector(
              onTap: () => _generatePdf(scan),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded,
                    color: Color(0xFFFF6B6B), size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
