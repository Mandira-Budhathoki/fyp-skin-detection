import 'package:flutter/material.dart';

class MelanomaResultsScreen extends StatelessWidget {
  final Map<String, dynamic> results;

  const MelanomaResultsScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final String prediction = results['prediction'] ?? 'Unknown';
    final double confidence = (results['confidence'] ?? 0.0).toDouble();
    final String status = results['status'] ?? 'unknown';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Analysis Results', style: TextStyle(color: Color(0xFF264653), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF264653)),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildResultCard(prediction, confidence, status),
            const SizedBox(height: 32),
            _buildRecommendationCard(prediction),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A9D8F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Back to Gallery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String prediction, double confidence, String status) {
    bool isHighRisk = prediction.toLowerCase().contains('melanoma') || prediction.toLowerCase().contains('carcinoma');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (isHighRisk ? Colors.red : Colors.green).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHighRisk ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
              color: isHighRisk ? Colors.red : Colors.green,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Primary Prediction',
            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            prediction,
            style: TextStyle(
              color: isHighRisk ? Colors.red : const Color(0xFF264653),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Confidence: ',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              Text(
                '${confidence.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Color(0xFF2A9D8F),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              color: const Color(0xFF2A9D8F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(String prediction) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF264653),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.tealAccent, size: 28),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Steps',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'We recommend saving this result and showing it to a qualified dermatologist for a thorough physical examination.',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
