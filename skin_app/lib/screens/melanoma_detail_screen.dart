import 'package:flutter/material.dart';
import 'melanoma_info_provider.dart';

class MelanomaDetailScreen extends StatelessWidget {
  final String conditionName;
  final bool isHighRisk;

  const MelanomaDetailScreen({
    super.key,
    required this.conditionName,
    required this.isHighRisk,
  });

  @override
  Widget build(BuildContext context) {
    final info = MelanomaInfoProvider.getInfoForClass(conditionName);
    final Color primaryColor = isHighRisk ? const Color(0xFFE63946) : const Color(0xFF2A9D8F);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                conditionName.split(' (').first,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 10)],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    isHighRisk ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isHighRisk)
                    _buildUrgentWarning(),
                  
                  const SizedBox(height: 24),
                  
                  if (info != null) ...[
                    _buildDetailSection('Medical Type', info['Type']!, Icons.biotech_rounded),
                    _buildDetailSection('Common Causes', info['Cause']!, Icons.wb_sunny_rounded),
                    _buildDetailSection('Common Symptoms', info['Symptoms']!, Icons.search_rounded),
                    _buildDetailSection('Melanoma Risk & Association', info['Prone to Melanoma?']!, Icons.warning_rounded, isWarning: true),
                    _buildDetailSection('Standard Treatment Options', info['Treatment']!, Icons.medical_services_rounded),
                  ] else
                    const Center(child: Text('No detailed information available for this condition.')),
                  
                  const SizedBox(height: 40),
                  _buildFinalRecommendation(isHighRisk),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentWarning() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE63946).withOpacity(0.3)),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              Icon(Icons.notification_important_rounded, color: Color(0xFFE63946)),
              SizedBox(width: 12),
              Text(
                'URGENT MEDICAL NOTICE',
                style: TextStyle(
                  color: Color(0xFFE63946),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'The parameters for this lesion indicate a serious risk. While this AI analysis is NOT a medical diagnosis, we strongly advise you to contact a board-certified dermatologist immediately. DO NOT PANIC, but take immediate action to ensure your safety.',
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: isWarning ? const Color(0xFFE63946) : const Color(0xFF457B9D)),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: isWarning ? const Color(0xFFE63946) : const Color(0xFF1D3557),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              content,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalRecommendation(bool isHighRisk) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1D3557),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            'Final Recommendation',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isHighRisk
                ? 'Your skin health is the priority. Please schedule a biopsy or physical examination with a professional dermatologist as soon as possible.'
                : 'While this lesion appears benign according to the AI, you should continue to monitor it. If you notice any itching, bleeding, or rapid growth, consult a doctor.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Action to find a doctor or save report
            },
            icon: const Icon(Icons.location_on_rounded),
            label: const Text('Find Near Dermatologists'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF457B9D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
