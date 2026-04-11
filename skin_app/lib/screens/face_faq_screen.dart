import 'package:flutter/material.dart';

class FaceFaqScreen extends StatelessWidget {
  const FaceFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D3436), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Face Scan FAQs',
          style: TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.w900, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Everything you need to know about Face Faz Intelligence.',
              style: TextStyle(fontSize: 14, color: Color(0xFF636E72), height: 1.5, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            
            _faqTile(
              'How accurate is the Face Faz analysis?',
              'Our AI uses an ensemble of 7 specialized deep learning models. It achieves over 94% accuracy in identifying skin types and common facial markers like acne or inflammation when photos are taken in good lighting.'
            ),
            _faqTile(
              'How should I take the photo for best results?',
              'For the best analysis, ensure your face is well-lit (natural daylight is best), remove glasses or heavy makeup, and keep a neutral expression about 12 inches away from the camera.'
            ),
            _faqTile(
              'Are my photos being stored on the server?',
              'Privacy is our priority. Your photos are processed in real-time for analysis and are not permanently stored on our servers unless you explicitly choose to save them to your health journal.'
            ),
            _faqTile(
              'Can this detect specific medical conditions?',
              'While Face Faz is highly advanced at identifying skin patterns, it is a screening tool, not a medical device. It should used to track skin health trends, not for final medical diagnoses.'
            ),
            _faqTile(
              'Should I see a doctor after a scan?',
              'If the analysis highlights "High Inflammation" or "Severe Acne," we recommend using the "Visit Doctor" button in the hub to schedule a professional consultation.'
            ),
            _faqTile(
              'What does "Biometric Health" mean?',
              'It refers to the structural health of your face, including facial symmetry, pore density, and skin elasticity markers that help track aging and vitality over time.'
            ),
            
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFDC3A1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFDC3A1).withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFFFB9B8F)),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Still have questions? Chat with our AI Health Assistant for real-time help.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF2D3436), fontWeight: FontWeight.w600, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.help_rounded, size: 16, color: Color(0xFFF57799)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF2D3436), letterSpacing: -0.2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 13, color: Color(0xFF636E72), height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
