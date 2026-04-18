import 'package:flutter/material.dart';
import 'faq_data.dart'; // Import models

// ═══════════════════════════════════════════════════════════════════════════
// PREMIUM CLINICAL FACE DATA — Targeted Facial Health Intelligence
// ═══════════════════════════════════════════════════════════════════════════

final List<FaqCategory> faceFaqData = [
  FaqCategory(
    title: "Facial Skin Types",
    icon: Icons.fingerprint_rounded,
    gradient: [const Color(0xFFA8BBA3), const Color(0xFFC4A484)], // Sage to Sand
    items: [
      FaqItem(
        question: "How does AI detect skin type?",
        answer: "The Face Intelligence engine analyzes sebaceous gland activity, pore density, and light reflection to differentiate between Oily, Dry, Combination, and Normal skin indices.",
        icon: Icons.biotech_rounded,
      ),
      FaqItem(
        question: "Combination skin patterns?",
        answer: "Typically characterized by an oily 'T-Zone' (forehead, nose, chin) and dry or normal 'U-Zone' (cheeks and jawline).",
        icon: Icons.face_rounded,
      ),
      FaqItem(
        question: "Sensitive face indicators?",
        answer: "AI looks for capillary dilation (redness) and uneven texture. If your skin reacts to temperature changes, you likely have a sensitive barrier.",
        icon: Icons.waves_rounded,
      ),
    ],
  ),
  FaqCategory(
    title: "Acne & Pore Health",
    icon: Icons.face_retouching_natural_rounded,
    gradient: [const Color(0xFFB87C4C), const Color(0xFFA8BBA3)], // Cognac to Sage
    items: [
      FaqItem(
        question: "Acne vs High Inflammation?",
        answer: "Active acne presents as specific pustules. High inflammation refers to broader skin irritation, often related to barrier damage.",
        icon: Icons.query_stats_rounded,
      ),
      FaqItem(
        question: "What are 'clogged' pores?",
        answer: "Known as comedones, these occur when dead skin and sebum trap bacteria. AI helps identify these early.",
        icon: Icons.filter_tilt_shift_rounded,
      ),
      FaqItem(
        question: "Adult acne causes?",
        answer: "Often triggered by cortisol (stress) or hormonal fluctuations. It typically appears lower on the face along the jawline.",
        icon: Icons.psychology_rounded,
      ),
    ],
  ),
  FaqCategory(
    title: "Anti-Aging & Vitality",
    icon: Icons.auto_awesome_rounded,
    gradient: [const Color(0xFFC4A484), const Color(0xFFF7F1DE)], // Sand to Parchment
    items: [
      FaqItem(
        question: "Early signs of aging?",
        answer: "Loss of elasticity around the nasolabial folds and fine lines around the eyes are the first indicators.",
        icon: Icons.hourglass_bottom_rounded,
      ),
      FaqItem(
        question: "Collagen & Elastin?",
        answer: "These proteins keep skin firm. Scan trends can show if your current routine is effectively supporting them.",
        icon: Icons.layers_rounded,
      ),
      FaqItem(
        question: "Sun damage (UV) impact?",
        answer: "UV exposure causes photo-aging, appearing as hyperpigmentation. Daily SPF 50+ is mandatory.",
        icon: Icons.wb_sunny_rounded,
      ),
    ],
  ),
  FaqCategory(
    title: "Hydration & Barrier",
    icon: Icons.water_drop_rounded,
    gradient: [const Color(0xFFA8BBA3), const Color(0xFFB87C4C)], // Sage to Cognac
    items: [
      FaqItem(
        question: "What is Trans-Epidermal Water Loss?",
        answer: "Known as TEWL, it's the process where water evaporates from the skin. A high index suggests a compromised barrier.",
        icon: Icons.opacity_rounded,
      ),
      FaqItem(
        question: "Signs of dehydration?",
        answer: "Dehydrated skin is a condition, not a type. It often presents with 'crepe-like' fine lines.",
        icon: Icons.umbrella_rounded,
      ),
      FaqItem(
        question: "Barrier repair ingredients?",
        answer: "Look for Ceramides, Fatty Acids, and Cholesterol. These mimic the skin's natural lipids.",
        icon: Icons.shield_rounded,
      ),
    ],
  ),
  FaqCategory(
    title: "Scan Accuracy & Privacy",
    icon: Icons.security_rounded,
    gradient: [const Color(0xFFB87C4C), const Color(0xFFC4A484)], // Cognac to Sand
    items: [
      FaqItem(
        question: "Privacy of Face Data?",
        answer: "Your facial biometric data is processed using local-first protocols and end-to-end encryption.",
        icon: Icons.lock_rounded,
      ),
      FaqItem(
        question: "Improvement tracking?",
        answer: "We recommend scanning every 14 days to accurately measure routine effectiveness.",
        icon: Icons.history_rounded,
      ),
    ],
  ),
];
