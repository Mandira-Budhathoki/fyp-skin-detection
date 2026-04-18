import 'package:flutter/material.dart';

class FaqCategory {
  final String title;
  final IconData icon; // Main category icon
  final List<Color> gradient; // Background gradient
  final List<FaqItem> items;

  FaqCategory({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.items,
  });
}

class FaqItem {
  final String question;
  final String answer;
  final IconData icon; // Relevant symbol for the question

  FaqItem({
    required this.question, 
    required this.answer,
    required this.icon,
  });
}

final List<FaqCategory> skinFaqData = [
  // ... existing skinFaqData ...
  FaqCategory(
    title: "Acne & Blemishes",
    icon: Icons.face_retouching_natural_rounded,
    gradient: [const Color(0xFFFF9A9E), const Color(0xFFFECFEF)],
    items: [
      FaqItem(
        question: "What causes acne?",
        answer: "Acne develops when sebum (oil), dead skin cells, and bacteria clog hair follicles. Hormonal changes, diet, stress, and genetics also play significant roles.",
        icon: Icons.science_outlined,
      ),
      FaqItem(
        question: "Prevention tips?",
        answer: "Maintain a consistent cleansing routine (twice daily), avoid touching your face, change pillowcases regularly, and use non-comedogenic (pore-friendly) makeup and skincare products.",
        icon: Icons.shield_outlined,
      ),
      FaqItem(
        question: "Should I pop pimples?",
        answer: "No! Popping pushes bacteria deeper into the skin, increasing inflammation and the risk of permanent scarring.",
        icon: Icons.warning_amber_rounded,
      ),
       FaqItem(
        question: "Hormonal acne?",
        answer: "Hormonal acne often appears along the jawline and chin. It's common during puberty, menstruation, or times of hormonal fluctuation.",
        icon: Icons.female_rounded,
      ),
    ],
  ),
  FaqCategory(
    title: "Skincare 101",
    icon: Icons.spa_rounded,
    gradient: [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)],
    items: [
      FaqItem(
        question: "Routine Order",
        answer: "Cleanser -> Toner (Optional) -> Serum -> Eye Cream -> Moisturizer -> Sunscreen (AM) / Face Oil (PM).",
        icon: Icons.list_alt_rounded,
      ),
      FaqItem(
        question: "Exfoliation frequency?",
        answer: "For most skin types, 1-2 times a week is sufficient. Over-exfoliating can damage your skin barrier and cause irritation.",
        icon: Icons.calendar_today_rounded,
      ),
      FaqItem(
        question: "Sunscreen indoors?",
        answer: "Yes! UVA rays can penetrate glass windows. Wearing SPF 30+ daily is the #1 anti-aging step you can take.",
        icon: Icons.wb_sunny_outlined,
      ),
    ],
  ),
  FaqCategory(
    title: "Skin Types",
    icon: Icons.fingerprint_rounded,
    gradient: [const Color(0xFF84FAB0), const Color(0xFF8FD3F4)],
    items: [
      FaqItem(
        question: "Find my skin type",
        answer: "Wash face & wait 30 mins. Tight = Dry. Shiny all over = Oily. Shiny T-zone only = Combination.",
        icon: Icons.search_rounded,
      ),
      FaqItem(
        question: "Oily Skin Care",
        answer: "Use gel-based cleansers and oil-free moisturizers. Look for ingredients like Salicylic Acid and Niacinamide to control sebum.",
        icon: Icons.water_drop_outlined,
      ),
      FaqItem(
        question: "Dry Skin Care",
        answer: "Look for cream-based cleansers and rich moisturizers containing Hyaluronic Acid, Ceramides, and Glycerin.",
        icon: Icons.opacity_rounded,
      ),
    ],
  ),
  FaqCategory(
    title: "Anti-Aging",
    icon: Icons.auto_awesome_rounded,
    gradient: [const Color(0xFFE0C3FC), const Color(0xFF8EC5FC)],
    items: [
      FaqItem(
        question: "When to start?",
        answer: "Prevention is key. Most dermatologists recommend starting a basic anti-aging routine (like daily sunscreen and antioxidants) in your mid-20s.",
        icon: Icons.access_time_rounded,
      ),
      FaqItem(
        question: "Lifestyle factors",
        answer: "Hydration, sleep quality, and diet are crucial. Sugar and processed foods can trigger inflammation, while antioxidant-rich foods support skin health.",
        icon: Icons.restaurant_rounded,
      ),
      FaqItem(
        question: "Stress effects",
        answer: "Yes, stress releases cortisol, which can increase oil production and inflammation, leading to breakouts and sensitivity.",
        icon: Icons.psychology_outlined,
      ),
    ],
  ),
   FaqCategory(
    title: "Products",
    icon: Icons.shopping_bag_outlined,
    gradient: [const Color(0xFFfccb90), const Color(0xFFd57eeb)],
    items: [
      FaqItem(
        question: "What is a serum?",
        answer: "Serums are concentrated formulations targeting specific concerns (like Vitamin C for brightening or Retinol for anti-aging).",
        icon: Icons.science_outlined,
      ),
      FaqItem(
        question: "Natural vs Synthetic",
        answer: "Both can be safe and effective. 'Natural' doesn't always mean better or safer; poison ivy is natural! Focus on formulations that suit your skin type.",
        icon: Icons.eco_outlined,
      ),
    ],
  ),
  FaqCategory(
    title: "Melanoma & Moles",
    icon: Icons.biotech_rounded,
    gradient: [const Color(0xFF334d50), const Color(0xFFcbcaa5)],
    items: [
      FaqItem(
        question: "What is the ABCDE rule?",
        answer: "A: Asymmetry (two halves don't match), B: Border (irregular or scalloped), C: Color (multiple shades), D: Diameter (>6mm), E: Evolution (changing fast).",
        icon: Icons.rule_rounded,
      ),
      FaqItem(
        question: "Is melanoma curable?",
        answer: "Yes, when detected early (Stage 1), the 5-year survival rate is 99%. Early detection through monthly self-exams and AI screening is critical.",
        icon: Icons.health_and_safety_rounded,
      ),
      FaqItem(
        question: "Sunscreen vs Melanoma?",
        answer: "Consistent use of SPF 30+ broad-spectrum sunscreen reduces the risk of melanoma by approximately 50% by blocking harmful UV radiation.",
        icon: Icons.wb_sunny_rounded,
      ),
      FaqItem(
        question: "Risk factors for moles?",
        answer: "Genetics, having over 50 moles, history of severe sunburns, and frequent tanning bed use significantly increase melanoma risk.",
        icon: Icons.warning_rounded,
      ),
    ],
  ),
  FaqCategory(
    title: "Wound Care & First Aid",
    icon: Icons.healing_rounded,
    gradient: [const Color(0xFF6A11CB), const Color(0xFF2575FC)],
    items: [
      FaqItem(
        question: "Signs of infection?",
        answer: "Watch for increased redness (erythema), spreading warmth, swelling (edema), pus/drainage, and systemic symptoms like fever or chills.",
        icon: Icons.contact_emergency_rounded,
      ),
      FaqItem(
        question: "Proper cleaning steps?",
        answer: "Wash hands first. Rinse with clean water or saline. Do not use hydrogen peroxide or alcohol on open wounds as they damage healthy tissue.",
        icon: Icons.clean_hands_rounded,
      ),
      FaqItem(
        question: "Dry vs Moist healing?",
        answer: "Modern clinical practice favors moist wound healing. Using an antibacterial ointment and a bandage keeps the area hydrated and speeds up cell repair.",
        icon: Icons.water_drop_rounded,
      ),
      FaqItem(
        question: "When to get stitches?",
        answer: "Seek professional help if the wound is deeper than 1/4 inch, has gaping edges, shows fat/muscle, or won't stop bleeding after 15 mins of pressure.",
        icon: Icons.straighten_rounded,
      ),
      FaqItem(
        question: "Preventing scar tissue?",
        answer: "Keep the wound covered and moist. Once healed, use silicone gel sheets and protect the area from SUNLIGHT (UV) for at least 6 months using SPF.",
        icon: Icons.history_edu_rounded,
      ),
      FaqItem(
        question: "Burn first aid?",
        answer: "Immediately run cool (not cold) tap water over the burn for 20 mins. Never use ice, butter, or ointments on a fresh, blistering burn.",
        icon: Icons.whatshot_rounded,
      ),
      FaqItem(
        question: "Tetanus shots?",
        answer: "For dirty or deep wounds, a tetanus booster is recommended if your last shot was more than 5 years ago. For clean minor wounds, 10 years is standard.",
        icon: Icons.vaccines_rounded,
      ),
    ],
  ),
];


