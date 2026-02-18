import 'package:flutter/material.dart';
import 'faq_data.dart'; // Import models

final List<FaqCategory> woundFaqData = [
  FaqCategory(
    title: "Wound Basics",
    icon: Icons.healing_rounded,
    gradient: [const Color(0xFF334155), const Color(0xFF475569)], // Slate Medical
    items: [
      FaqItem(
        question: "What is an acute wound?",
        answer: "An acute wound is a sudden injury to the skin that usually heals within a predictable timeframe (typically 2-4 weeks) through the standard healing stages.",
        icon: Icons.timer_outlined,
      ),
      FaqItem(
        question: "What is a chronic wound?",
        answer: "A chronic wound is one that fails to progress through the normal stages of healing, often remaining open for more than 4-6 weeks.",
        icon: Icons.history_rounded,
      ),
      FaqItem(
        question: "Types of skin wounds?",
        answer: "Common types include abrasions (scrapes), lacerations (cuts), punctures (deep holes), and avulsions (skin tearing away).",
        icon: Icons.category_outlined,
      ),
      FaqItem(
        question: "How deep is too deep?",
        answer: "If you can see fat, muscle, or bone, or if the wound is deeper than 1/4 inch, it requires professional medical attention and likely stitches.",
        icon: Icons.straighten_rounded,
      ),
    ],
  ),
  FaqCategory(
    title: "Healing Journey",
    icon: Icons.trending_up_rounded,
    gradient: [const Color(0xFF0D9488), const Color(0xFF0F766E)], // Professional Teal
    items: [
      FaqItem(
        question: "Stages of healing?",
        answer: "Healing occurs in 4 phases: 1. Hemostasis (clotting), 2. Inflammation (swelling/cleaning), 3. Proliferation (new tissue), 4. Remodeling (strengthening).",
        icon: Icons.layers_outlined,
      ),
      FaqItem(
        question: "Why is it itching?",
        answer: "Itching is often a sign of healing! As new cells grow and nerves are stimulated, the body releases histamines that cause that tingly, itchy sensation.",
        icon: Icons.bug_report_outlined,
      ),
      FaqItem(
        question: "What is the yellow stuff?",
        answer: "Thin, clear or slightly yellow fluid is 'serous exudate' and is normal. However, thick, cloudy yellow/green fluid may be pus, indicating infection.",
        icon: Icons.info_outline,
      ),
      FaqItem(
        question: "How long to heal?",
        answer: "Minor scrapes take 7-10 days. Deeper cuts take 2-4 weeks. Factors like age, nutrition, and blood flow significantly impact this timeline.",
        icon: Icons.shutter_speed_rounded,
      ),
    ],
  ),
  FaqCategory(
    title: "Infection Alerts",
    icon: Icons.warning_rounded,
    gradient: [const Color(0xFF991B1B), const Color(0xFF7F1D1D)], // Medical Alert Red
    items: [
      FaqItem(
        question: "Signs of infection?",
        answer: "Look for increasing pain, swelling, expanding redness (streaking), warmth, pus, or if you develop a fever.",
        icon: Icons.report_problem_outlined,
      ),
      FaqItem(
        question: "What are red streaks?",
        answer: "Red streaks spreading away from the wound can indicate lymphangitis, a serious infection that requires immediate medical attention.",
        icon: Icons.timeline_rounded,
      ),
      FaqItem(
        question: "When to see a doctor?",
        answer: "See a professional if the wound won't stop bleeding, is very deep, contains debris you can't remove, or shows signs of infection.",
        icon: Icons.local_hospital_rounded,
      ),
    ],
  ),
  FaqCategory(
    title: "First Aid Essentials",
    icon: Icons.medical_services_rounded,
    gradient: [const Color(0xFF2563EB), const Color(0xFF1D4ED8)], // Hospital Blue
    items: [
      FaqItem(
        question: "How to clean a wound?",
        answer: "Rinse with cool, clean water. Use mild soap around the edges, but avoid getting soap directly in the wound. Pat dry with sterile gauze.",
        icon: Icons.opacity_rounded,
      ),
      FaqItem(
        question: "Use Hydrogen Peroxide?",
        answer: "Actually, most doctors advise against it! Peroxide can damage healthy tissue and slow healing. Plain water or saline is usually best.",
        icon: Icons.cancel_outlined,
      ),
      FaqItem(
        question: "Covered or Uncovered?",
        answer: "Keep it covered! Exposure to air can dry out cells and slow healing. A moist environment (under a bandage) is actually better for new cell growth.",
        icon: Icons.home_repair_service_rounded,
      ),
      FaqItem(
        question: "Changing bandages?",
        answer: "Change the dressing daily, or sooner if it becomes wet or dirty. Always wash your hands before and after touching the wound area.",
        icon: Icons.refresh_rounded,
      ),
    ],
  ),
  FaqCategory(
    title: "Scar Management",
    icon: Icons.auto_fix_high_rounded,
    gradient: [const Color(0xFF4B5563), const Color(0xFF374151)], // Neutral Slate
    items: [
      FaqItem(
        question: "Preventing scars?",
        answer: "Keep the wound moist with petroleum jelly, keep it covered, and most importantly, protect the healing skin from the sun (UV rays darken scars).",
        icon: Icons.wb_sunny_rounded,
      ),
      FaqItem(
        question: "What are Keloids?",
        answer: "Keloids are raised, thickened scars that grow larger than the original injury. They are caused by an overproduction of collagen during healing.",
        icon: Icons.add_circle_outline_rounded,
      ),
      FaqItem(
        question: "Do scar creams work?",
        answer: "Silicone gels or sheets are the most evidence-based options for reducing scar appearance. Start using them once the wound has fully closed.",
        icon: Icons.clean_hands_rounded,
      ),
    ],
  ),
  FaqCategory(
    title: "Nutrition & Recovery",
    icon: Icons.restaurant_rounded,
    gradient: [const Color(0xFF15803D), const Color(0xFF166534)], // Wellness Green
    items: [
      FaqItem(
        question: "Protein for healing?",
        answer: "Protein is the building block of new tissue. Ensure you're getting enough lean protein to support the repair process.",
        icon: Icons.fitness_center_rounded,
      ),
      FaqItem(
        question: "Vitamin C & Zinc?",
        answer: "Vitamin C helps build collagen, and Zinc is essential for cell division. Both are critical for efficient wound recovery.",
        icon: Icons.apple_rounded,
      ),
      FaqItem(
        question: "Hydration importance?",
        answer: "Water transports nutrients to the wound and removes waste. Proper hydration keeps the skin elastic and supports the inflammatory process.",
        icon: Icons.water_drop_rounded,
      ),
      FaqItem(
        question: "Does smoking affect it?",
        answer: "Yes, significantly. Smoking constricts blood vessels, reducing oxygen delivery to the wound, which can double the time it takes to heal.",
        icon: Icons.smoke_free_rounded,
      ),
    ],
  ),
];

