import 'package:flutter/material.dart';
import 'dart:io';

class SkinResultsScreen extends StatelessWidget {
  final Map<String, dynamic> results;
  final File? image;

  const SkinResultsScreen({super.key, required this.results, this.image});

  @override
  Widget build(BuildContext context) {
    final String prediction = results['prediction'] ?? 'Analysis Complete';
    final double confidence = (results['confidence'] ?? 0.0).toDouble();
    final String status = results['status'] ?? 'success';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Skin Analysis Result', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w800)),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (image != null) _buildImagePreview(image!),
            const SizedBox(height: 24),
            _buildResultCard(prediction, confidence, status),
            const SizedBox(height: 24),
            _buildActionButtons(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(File file) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
    );
  }

  Widget _buildResultCard(String prediction, double confidence, String status) {
    bool isWarning = prediction.toLowerCase().contains('severe') || prediction.toLowerCase().contains('acne');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isWarning ? const Color(0xFFE76F51) : const Color(0xFF2A9D8F)).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isWarning ? Icons.analytics_outlined : Icons.check_circle_outline_rounded,
              color: isWarning ? const Color(0xFFE76F51) : const Color(0xFF2A9D8F),
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'DETECTION RESULT',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Text(
            prediction,
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text('Confidence Score', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${confidence.toStringAsFixed(1)}%', style: const TextStyle(color: Color(0xFF2A9D8F), fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              color: const Color(0xFF2A9D8F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          label: 'Book Dermatologist',
          icon: Icons.calendar_month_rounded,
          color: const Color(0xFF6A4C93),
          onTap: () => Navigator.pushNamed(context, '/appointment'),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          label: 'AI Chatbot Consultation',
          icon: Icons.smart_toy_rounded,
          color: const Color(0xFF264653),
          onTap: () => Navigator.pushReplacementNamed(context, '/chatbot'),
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
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
