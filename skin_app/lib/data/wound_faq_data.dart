import 'package:flutter/material.dart';
import 'faq_data.dart'; // Import models

final List<FaqCategory> woundFaqData = [
  FaqCategory(
    title: "Wound Basics",
    icon: Icons.history_edu_rounded,
    gradient: [const Color(0xFF8A7650), const Color(0xFFA98B76)], 
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
    icon: Icons.auto_awesome_motion_rounded,
    gradient: [const Color(0xFF8E977D), const Color(0xFFBABF94)], 
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
    icon: Icons.notification_important_rounded,
    gradient: [const Color(0xFFA98B76), const Color(0xFF8A7650)], 
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
      FaqItem(
        question: "Bacterial resistance?",
        answer: "Overuse of over-the-counter antibiotic ointments can sometimes lead to resistance. If a wound isn't improving, a doctor may need to swab it for specific cultures.",
        icon: Icons.biotech_rounded,
      ),
    ],
  ),
  FaqCategory(
    title: "First Aid Essentials",
    icon: Icons.medical_services_rounded,
    gradient: [const Color(0xFFDBCEA5), const Color(0xFFECE7D1)], 
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
        question: "Stopping the bleed?",
        answer: "Apply firm, steady pressure with a clean cloth or gauze for a full 5-10 minutes without lifting it to check. Elevate the area above heart level if possible.",
        icon: Icons.pan_tool_rounded,
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
    title: "Post-Surgical Care",
    icon: Icons.content_paste_search_rounded,
    gradient: [const Color(0xFFBFA28C), const Color(0xFFF3E4C9)], 
    items: [
      FaqItem(
        question: "Managing surgical sutures?",
        answer: "Keep sutures dry for the first 24-48 hours unless told otherwise. Don't pick at scabs around the stitches, as this can cause them to pull or scar.",
        icon: Icons.architecture_rounded,
      ),
      FaqItem(
        question: "What is wound dehiscence?",
        answer: "Dehiscence is when a surgical incision reopens. If you see the edges separating or abnormal fluid leaking, contact your surgeon immediately.",
        icon: Icons.open_in_full_rounded,
      ),
      FaqItem(
        question: "When to shower?",
        answer: "Most surgeons allow showering after 48 hours, but no soaking in tubs or pools until the stitches are removed and the skin is fully closed.",
        icon: Icons.shower_rounded,
      ),
    ],
  ),
  FaqCategory(
    title: "Specialty & Chronic Wounds",
    icon: Icons.biotech_rounded,
    gradient: [const Color(0xFF8A7650), const Color(0xFFBFA28C)], 
    items: [
      FaqItem(
        question: "Diabetic foot ulcers?",
        answer: "Diabetes can cause poor circulation and nerve damage (neuropathy), making foot wounds slow to heal and prone to severe infection. Daily foot checks are vital.",
        icon: Icons.wheelchair_pickup_rounded,
      ),
      FaqItem(
        question: "Pressure injuries (Sores)?",
        answer: "Caused by prolonged pressure on the skin, often over bony areas. Frequent repositioning (every 2 hours) and pressure-relieving cushions are key for prevention.",
        icon: Icons.airline_seat_recline_extra_rounded,
      ),
      FaqItem(
        question: "What is slough?",
        answer: "Slough is dead tissue that appears yellow/white/tan in a wound. It must often be removed (debrided) by a professional for healing to occur.",
        icon: Icons.layers_clear_rounded,
      ),
    ],
  ),
  FaqCategory(
    title: "Scar Management",
    icon: Icons.auto_fix_high_rounded,
    gradient: [const Color(0xFFBABF94), const Color(0xFF8E977D)], 
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
    gradient: [const Color(0xFFDBCEA5), const Color(0xFFF3E4C9)], 
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

