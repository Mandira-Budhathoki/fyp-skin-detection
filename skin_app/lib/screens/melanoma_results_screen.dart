import 'package:flutter/material.dart';
import 'melanoma_info_provider.dart';
import 'melanoma_detail_screen.dart'; // Import the new screen

class MelanomaResultsScreen extends StatelessWidget {
  final Map<String, dynamic> results;

  const MelanomaResultsScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    // Top-Level Data
    final String prediction = results['prediction'] ?? 'Unknown';
    final double confidence = (results['confidence'] ?? 0.0).toDouble();
    final bool isMelanoma = results['is_melanoma'] ?? false;
    final String rawClass = results['raw_class'] ?? '';
    
    // Fallbacks if data is missing
    final List<dynamic> top3 = results['top3_classes'] ?? [];

    // Correcting risk logic
    bool isHighRisk = isMelanoma || (prediction.toLowerCase().contains('melanoma') && !prediction.toLowerCase().contains('non-melanoma'));
    if(prediction.contains("Unclear Image")){
        isHighRisk = true; 
    }

    final Color primaryColor = isHighRisk ? const Color(0xFFE63946) : const Color(0xFF2A9D8F);
    final Color bgColor = const Color(0xFFF8F9FB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Analysis Results', style: TextStyle(color: Color(0xFF1D3557), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1D3557)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Column(
                children: [
                   Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isHighRisk ? Icons.health_and_safety_rounded : Icons.verified_user_rounded,
                      color: primaryColor,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('PRIMARY DIAGNOSIS', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text(
                    prediction,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: primaryColor, fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  _buildConfidenceBadge(confidence, primaryColor),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breakdown Section
                  if (top3.isNotEmpty) ...[
                    const Text('PROBABILITY BREAKDOWN', style: TextStyle(color: Color(0xFF1D3557), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    ...top3.map((item) {
                      String label = item['label'] ?? 'Unknown';
                      double val = (item['confidence'] ?? 0.0).toDouble();
                      return _buildProbabilityBar(label, val, primaryColor);
                    }),
                  ],
                  
                  const SizedBox(height: 32),

                  // Information Card logic
                  if(prediction != "Unclear Image / Not a Skin Lesion" && rawClass.isNotEmpty) ...[
                     _buildDetailedInfoCard(rawClass, isHighRisk),
                     const SizedBox(height: 20),
                     // NEW: Navigate to Detail Page
                     SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MelanomaDetailScreen(
                                  conditionName: rawClass,
                                  isHighRisk: isHighRisk,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.info_outline_rounded),
                          label: const Text('Read Detailed Medical Report', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                     ),
                  ],

                  if(prediction == "Unclear Image / Not a Skin Lesion")
                    _buildUnclearWarning(),

                  const SizedBox(height: 32),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/appointment'),
                      icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
                      label: const Text('Book Expert Appointment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A4C93),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D3557),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('New Analysis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.analytics_outlined, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '${confidence.toStringAsFixed(1)}% Confidence',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildProbabilityBar(String label, double val, Color themeColor) {
    // Shorten long labels for better UI
    String shortLabel = label.split(' (').first;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(shortLabel, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF457B9D)), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text('${val.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D3557))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: val / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>((val > 50) ? themeColor : const Color(0xFF457B9D).withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInfoCard(String rawClass, bool isHighRisk) {
     Map<String, String>? info = MelanomaInfoProvider.getInfoForClass(rawClass);
     
     if (info == null) {
       return const SizedBox(); // Hide if no data found
     }

     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         const Text('MEDICAL INSIGHTS', style: TextStyle(color: Color(0xFF1D3557), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
         const SizedBox(height: 16),
         Container(
           width: double.infinity,
           padding: const EdgeInsets.all(24),
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(24),
             border: Border.all(color: isHighRisk ? Colors.red.withOpacity(0.3) : Colors.transparent),
             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
           ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               _buildInfoRow(Icons.biotech_rounded, 'Type', info['Type']!),
               const Divider(height: 30),
               _buildInfoRow(Icons.wb_sunny_rounded, 'Common Causes', info['Cause']!),
               const Divider(height: 30),
               _buildInfoRow(Icons.search_rounded, 'Symptoms', info['Symptoms']!),
               const Divider(height: 30),
               _buildInfoRow(Icons.warning_rounded, 'Melanoma Risk', info['Prone to Melanoma?']!, isHighlight: true),
               const Divider(height: 30),
               _buildInfoRow(Icons.medical_services_rounded, 'Treatment', info['Treatment']!),
             ],
           ),
         ),
         const SizedBox(height: 24),
         // Disclaimer Card
         Container(
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
             color: const Color(0xFFFFF9E6),
             borderRadius: BorderRadius.circular(16),
             border: const Border(left: BorderSide(width: 4, color: Color(0xFFFFB703))),
           ),
           child: Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Icon(Icons.info_outline_rounded, color: Color(0xFFFFB703)),
               const SizedBox(width: 12),
               Expanded(
                 child: Text(
                   isHighRisk 
                     ? 'Please consult a Dermatologist as soon as possible for a professional examination. Do not panic, but take early action.'
                     : 'This appears to be benign. However, monitor your skin for changes and consult a doctor if it bleeds, grows, or changes shape.',
                   style: const TextStyle(color: Color(0xFF1D3557), fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
                 ),
               ),
             ],
           ),
         )
       ],
     );
  }

  Widget _buildUnclearWarning() {
     return Container(
       padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(
         color: Colors.orange.withOpacity(0.1),
         borderRadius: BorderRadius.circular(20),
         border: Border.all(color: Colors.orange.withOpacity(0.5)),
       ),
       child: const Row(
         children: [
           Icon(Icons.camera_alt_outlined, color: Colors.orange, size: 30),
           SizedBox(width: 16),
           Expanded(
             child: Text(
               'Image is too blurry or unclear for an accurate medical reading. Please ensure the lesion is centered, focused, and well-lit.',
               style: TextStyle(color: Colors.brown, fontSize: 14, height: 1.5),
             ),
           ),
         ],
       ),
     );
  }

  Widget _buildInfoRow(IconData icon, String title, String content, {bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF457B9D), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1D3557))),
              const SizedBox(height: 6),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14, 
                  height: 1.5, 
                  color: isHighlight ? const Color(0xFFE63946) : Colors.grey[700],
                  fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
