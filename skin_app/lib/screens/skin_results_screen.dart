import 'package:flutter/material.dart';
import 'dart:io';
import '../services/api_service.dart';

class SkinResultsScreen extends StatelessWidget {
  final Map<String, dynamic> results;
  final File? image;

  const SkinResultsScreen({super.key, required this.results, this.image});

  String _buildFullUrl(String? path) {
    if (path == null) return '';
    if (path.startsWith('http')) return path;
    if (path.startsWith('/api')) {
      return ApiService.useTunnel
          ? "${ApiService.tunnelUrl}$path"
          : "http://${ApiService.serverIp}:8000$path";
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final String acneStatus = results['acne_status'] ?? results['prediction'] ?? 'Analysis Complete';
    final double acneConf = (results['acne_confidence'] ?? results['confidence'] ?? 0.0).toDouble();
    final String? processedUrl = results['processed_url'] != null ? _buildFullUrl(results['processed_url']) : null;
    final List<dynamic> otherConditions = results['other_conditions'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Skin Analysis Report', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image with Heatmap
            _buildImageDisplay(processedUrl, image),
            const SizedBox(height: 20),

            // 2. ACNE STATUS — Always shown first
            _buildAcneCard(acneStatus, acneConf),
            const SizedBox(height: 20),

            // 3. Heatmap explanation
            if (processedUrl != null) ...[
              _buildExplainabilityInfo(),
              const SizedBox(height: 20),
            ],

            // 4. Other Conditions — Only if genuinely detected
            if (otherConditions.isNotEmpty) ...[
              _buildOtherConditions(otherConditions),
              const SizedBox(height: 20),
            ],

            // 5. Action Buttons
            _buildActionButtons(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImageDisplay(String? processedUrl, File? originalFile) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (processedUrl != null)
              Image.network(processedUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) =>
                originalFile != null ? Image.file(originalFile, fit: BoxFit.cover) : Container(color: Colors.grey[200]))
            else if (originalFile != null)
              Image.file(originalFile, fit: BoxFit.cover)
            else
              Container(color: Colors.grey[200]),
            if (processedUrl != null)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 12),
                      SizedBox(width: 4),
                      Text('XAI HEATMAP', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ACNE STATUS CARD — The main hero card
  Widget _buildAcneCard(String acneStatus, double acneConf) {
    // Colors based on severity
    Color statusColor;
    IconData statusIcon;
    String statusDesc;

    if (acneStatus == 'Moderate Acne') {
      statusColor = const Color(0xFFE76F51); // Red-orange
      statusIcon = Icons.warning_rounded;
      statusDesc = 'Significant acne detected. Consider consulting a dermatologist.';
    } else if (acneStatus == 'Mild Acne') {
      statusColor = const Color(0xFFF4A261); // Warm orange
      statusIcon = Icons.info_rounded;
      statusDesc = 'Some signs of acne detected. Maintain good skincare routine.';
    } else {
      statusColor = const Color(0xFF2A9D8F); // Green-teal
      statusIcon = Icons.check_circle_rounded;
      statusDesc = 'No significant acne detected. Your skin looks clear!';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 36),
          ),
          const SizedBox(height: 14),
          // Label
          const Text('ACNE ASSESSMENT', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          // Status
          Text(
            acneStatus,
            style: TextStyle(color: statusColor, fontSize: 24, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          // Confidence
          Text(
            'AI Confidence: ${acneConf.toStringAsFixed(1)}%',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: double.infinity,
              child: LinearProgressIndicator(
                value: acneConf / 100,
                minHeight: 10,
                backgroundColor: const Color(0xFFF1F5F9),
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Description
          Text(
            statusDesc,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildExplainabilityInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.cyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.cyan.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.help_outline_rounded, color: Colors.cyan, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'The heatmap above shows where the AI focused to make this prediction.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  /// OTHER CONDITIONS — Only shown if genuinely detected
  Widget _buildOtherConditions(List<dynamic> conditions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OTHER CONDITIONS DETECTED',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1.5),
        ),
        const SizedBox(height: 10),
        ...conditions.map((c) {
          double conf = (c['confidence'] ?? 0.0).toDouble();
          String label = c['label'] ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2C3E50), fontSize: 13),
                  ),
                ),
                Text(
                  '${conf.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.orange, fontSize: 14),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          label: 'Book Skin Specialist',
          icon: Icons.calendar_month_rounded,
          color: const Color(0xFF6A4C93),
          onTap: () => Navigator.pushNamed(context, '/appointment'),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          label: 'Consult Skin AI',
          icon: Icons.smart_toy_rounded,
          color: const Color(0xFF264653),
          onTap: () => Navigator.pushNamed(context, '/chatbot'),
        ),
      ],
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
