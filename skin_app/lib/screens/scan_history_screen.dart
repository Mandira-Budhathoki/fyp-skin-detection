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

  // Pagination Variables
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  // Theme Palette
  static const Color creamBg = Color(0xFFF2EAE0);
  static const Color cyan = Color(0xFFB4D3D9);
  static const Color softPurple = Color(0xFFBDA6CE);
  static const Color deepPurple = Color(0xFF9B8EC7);
  static const Color textDark = Color(0xFF333333);

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
          // Sort newest first
          _scans.sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
        }
        _isLoading = false;
      });
    }
  }

  int get _totalPages => (_scans.length / _itemsPerPage).ceil();

  List<dynamic> get _currentScans {
    final int startIndex = (_currentPage - 1) * _itemsPerPage;
    final int endIndex = startIndex + _itemsPerPage;
    if (startIndex >= _scans.length) return [];
    return _scans.sublist(startIndex, endIndex > _scans.length ? _scans.length : endIndex);
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
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
      backgroundColor: creamBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Reports",
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: deepPurple, strokeWidth: 3))
          : _scans.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: _currentScans.length,
                        itemBuilder: (context, index) {
                          return _buildPremiumScanCard(_currentScans[index], index);
                        },
                      ),
                    ),
                    _buildPaginationControls(),
                  ],
                ),
    );
  }

  Widget _buildPaginationControls() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _pageButton(
              icon: Icons.chevron_left_rounded,
              label: 'Prev',
              onTap: _currentPage > 1 ? _prevPage : null,
              isActive: _currentPage > 1,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: creamBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Page $_currentPage of $_totalPages',
                style: const TextStyle(fontWeight: FontWeight.bold, color: deepPurple, fontSize: 13),
              ),
            ),
            _pageButton(
              icon: Icons.chevron_right_rounded,
              label: 'Next',
              onTap: _currentPage < _totalPages ? _nextPage : null,
              isActive: _currentPage < _totalPages,
              isRight: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageButton({required IconData icon, required String label, required VoidCallback? onTap, required bool isActive, bool isRight = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? deepPurple : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isRight) Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 18),
            if (!isRight) const SizedBox(width: 4),
            Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
            if (isRight) const SizedBox(width: 4),
            if (isRight) Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: softPurple.withOpacity(0.2), blurRadius: 20)]),
            child: const Icon(Icons.description_outlined, size: 48, color: cyan),
          ),
          const SizedBox(height: 24),
          const Text("No Premium Reports", style: TextStyle(color: textDark, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text("Complete your first AI analysis to\ngenerate a clinical report.", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildPremiumScanCard(dynamic scan, int index) {
    final date = DateTime.parse(scan['timestamp']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);
    final formattedTime = DateFormat('hh:mm a').format(date);
    final confidence = (scan['confidence'] ?? 0.0).toDouble();
    final prediction = scan['prediction'] ?? "Unknown";

    final confColor = _confidenceColor(confidence);
    
    // Gradient accent logic based on the provided colors
    final gradients = [
      [cyan, const Color(0xFF90B9BF)],
      [softPurple, const Color(0xFFA58CB8)],
      [deepPurple, const Color(0xFF8172AD)],
    ];
    final gradient = gradients[index % gradients.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left color tab
              Container(
                width: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              prediction,
                              style: const TextStyle(
                                color: textDark,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _generatePdf(scan),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: creamBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: cyan.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.download_rounded, size: 12, color: deepPurple),
                                  SizedBox(width: 4),
                                  Text("PDF", style: TextStyle(color: deepPurple, fontWeight: FontWeight.w800, fontSize: 10.5)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(color: creamBg, borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.event_note_rounded, size: 13, color: gradient[0]),
                          ),
                          const SizedBox(width: 8),
                          Text('$formattedDate  •  $formattedTime', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: confColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.verified_rounded, size: 13, color: confColor),
                                const SizedBox(width: 4),
                                Text(
                                  '${confidence.toStringAsFixed(1)}% Confidence',
                                  style: TextStyle(color: confColor, fontWeight: FontWeight.w800, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
