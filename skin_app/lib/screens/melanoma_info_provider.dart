import 'package:flutter/material.dart';

class MelanomaInfoProvider {
  static const Map<String, Map<String, String>> classInfo = {
    // New ISIC Binary Labels
    'Melanoma Detected': {
      'Type': 'Malignant Melanocytic Neoplasm (High-Risk Skin Cancer)',
      'Cause': 'Pathological mutations triggered by acute, intense ultraviolet (UV) radiation, severe blistering sunburns, genetic predisposition (CDKN2A mutations), and a high mole count.',
      'Symptoms': 'Rapidly evolving lesions. Demonstrates the ABCDE criteria: Asymmetry, Border irregularity (scalloped/poorly defined), Color variations (shades of black, brown, red, white, or blue), Diameter >6mm, and Evolution (changing fast in size, shape, or elevating). Pruritus (itching) or bleeding may occur in advanced stages.',
      'Prone to Melanoma?': 'This IS Melanoma. Requires immediate biopsy. Highly metastatic if left untreated, but 99% curable if excised early.',
      'Treatment': 'Urgent wide local surgical excision. Depending on Breslow depth and lymph node involvement, adjuvant therapies may include Immunotherapy (Keytruda/Opdivo), targeted BRAF/MEK inhibitors, or radiation therapy. Baseline full-body skin mapping is mandated.'
    },
    'Non-Melanoma (Safe)': {
      'Type': 'Benign Cutaneous Lesion (Non-Cancerous)',
      'Cause': 'Normal melanocyte clustering, age-related epidermal thickening, genetic baseline, or standard chronic sun exposure without pathological mutation.',
      'Symptoms': 'Uniform pigmentation, sharp and regular borders, symmetrical architecture. Stable over time with no rapid morphological changes, ulceration, or bleeding.',
      'Prone to Melanoma?': 'Currently assessed as safe and benign. However, clinical monitoring should continue as standard practice.',
      'Treatment': 'No medical intervention required. Continue daily application of broad-spectrum SPF 30+ sunscreen. Schedule clinical re-evaluation if the lesion begins to grow, itch, or change shape.'
    },
    // New ISIC Multi-Class Labels
    'Melanoma': {
      'Type': 'Malignant Melanocytic Neoplasm (High-Risk Skin Cancer)',
      'Cause': 'Pathological mutations triggered by acute, intense ultraviolet (UV) radiation, severe blistering sunburns, genetic predisposition (CDKN2A mutations), and a high mole count.',
      'Symptoms': 'Rapidly evolving lesions. Demonstrates the ABCDE criteria: Asymmetry, Border irregularity (scalloped/poorly defined), Color variations (shades of black, brown, red, white, or blue), Diameter >6mm, and Evolution (changing fast in size, shape, or elevating). Pruritus (itching) or bleeding may occur in advanced stages.',
      'Prone to Melanoma?': 'This IS Melanoma. Requires immediate biopsy. Highly metastatic if left untreated, but 99% curable if excised early.',
      'Treatment': 'Urgent wide local surgical excision. Depending on Breslow depth and lymph node involvement, adjuvant therapies may include Immunotherapy (Keytruda/Opdivo), targeted BRAF/MEK inhibitors, or radiation therapy. Baseline full-body skin mapping is mandated.'
    },
    'Benign': {
      'Type': 'Benign Melanocytic Nevus (Normal Mole)',
      'Cause': 'Normal physiological proliferation of melanocytes. Influenced by genetics, hormones, and childhood sun exposure.',
      'Symptoms': 'Sharply demarcated borders, uniform color (usually soft brown or tan), symmetrical shape, and small diameter. Feels smooth to the touch and remains static for years without spontaneous bleeding.',
      'Prone to Melanoma?': 'Almost entirely harmless. Very low probability of malignant transformation.',
      'Treatment': 'No dermatological treatment required. Routine photographic monitoring is suggested. Cosmetic laser or surgical shave excision is available if it causes friction against clothing.'
    },
    'Keratosis': {
      'Type': 'Epidermal Hyperproliferation (Includes Seborrheic and Actinic Keratosis)',
      'Cause': 'Cumulative, long-term ultraviolet (UV) exposure over decades. Often correlated with aging, lighter skin phototypes (Fitzpatrick I-II), and localized immunosuppression.',
      'Symptoms': 'Presents as rough, dry, scaly plaques or warty, "pasted-on" macroscopic lesions. Can range from flesh-colored to hyperpigmented dark brown. Often has a sandpaper-like texture that may occasionally flake off and reform.',
      'Prone to Melanoma?': 'These are distinct from melanocytes. However, Actinic Keratosis is precancerous and unmonitored lesions have a 10% chance of progressing into Squamous Cell Carcinoma (SCC).',
      'Treatment': 'If Seborrheic: Purely cosmetic; treatable via liquid nitrogen cryotherapy. If Actinic: Requires field-directed topical therapies (5-Fluorouracil, Imiquimod creams), Photodynamic Therapy (PDT), or targeted cryosurgery to prevent SCC progression.'
    },
    // Legacy HAM10000 Labels (keep for backward compatibility)
    'Melanoma (MEL)': {
      'Type': 'Malignant skin cancer (most dangerous form)',
      'Cause': 'Intense, intermittent sun exposure, genetics, many moles, fair skin',
      'Symptoms': 'New or unusual growth, changes in an existing mole (ABCDE rule)',
      'Prone to Melanoma?': 'This IS Melanoma. Early detection is critical for a high survival rate.',
      'Treatment': 'Surgical excision, immunotherapy, targeted therapy, radiation or chemotherapy depending on stage.'
    },
    'Actinic Keratoses and Intraepithelial Carcinoma (AKIEC)': {
      'Type': 'Precancerous lesion (can progress to squamous cell carcinoma if untreated)',
      'Cause': 'Long-term sun exposure (UV damage), fair skin, aging',
      'Symptoms': 'Rough, scaly, reddish or brown patches on sun-exposed areas (face, scalp, hands)',
      'Prone to Melanoma?': 'Not melanoma, but can develop into squamous cell carcinoma (different skin cancer)',
      'Treatment': 'Cryotherapy (freezing), topical 5-fluorouracil, photodynamic therapy, surgical removal if needed'
    },
    'Basal Cell Carcinoma (BCC)': {
      'Type': 'Slow-growing skin cancer (most common non-melanoma skin cancer)',
      'Cause': 'UV exposure, fair skin, genetics',
      'Symptoms': 'Pearly bumps, flesh-colored nodules, sometimes ulcerated, bleeding or crusting',
      'Prone to Melanoma?': 'Not melanoma; rarely metastasizes, but local tissue destruction is possible',
      'Treatment': 'Surgical excision, Mohs surgery, topical treatments (imiquimod), cryotherapy'
    },
    'Benign Keratosis-like Lesions (BKL)': {
      'Type': 'Benign skin growths (seborrheic keratoses, solar lentigines)',
      'Cause': 'Sun exposure, aging, genetic factors',
      'Symptoms': 'Waxy, wart-like, or pigmented spots; usually painless',
      'Prone to Melanoma?': 'Generally harmless; monitor for irregular changes',
      'Treatment': 'Usually none needed; cosmetic removal (cryotherapy, curettage) if desired'
    },
    'Dermatofibroma (DF)': {
      'Type': 'Benign fibrous skin nodule',
      'Cause': 'Often develops after minor skin injury, insect bite, or trauma',
      'Symptoms': 'Firm, small, dome-shaped nodules; usually brown or reddish; dimple sign on pinching',
      'Prone to Melanoma?': 'Not melanoma; completely benign',
      'Treatment': 'Usually none; surgical removal if uncomfortable or for cosmetic reasons'
    },
    'Melanocytic Nevi (NV)': {
      'Type': 'Common moles (benign melanocyte growths)',
      'Cause': 'Genetic factors, sun exposure',
      'Symptoms': 'Brown/black spots or small raised bumps; stable in size and shape',
      'Prone to Melanoma?': 'Can transform into melanoma rarely; important to monitor changes using ABCDE',
      'Treatment': 'Usually none; surgical removal if suspicious or cosmetic'
    },
    'Vascular Lesions (VASC)': {
      'Type': 'Benign lesions of blood vessels (hemangiomas, telangiectasia, cherry angiomas)',
      'Cause': 'Abnormal growth of blood vessels, genetics, aging',
      'Symptoms': 'Red, purple, or blue spots; may blanch when pressed',
      'Prone to Melanoma?': 'Not melanoma; purely vascular, but monitor unusual bleeding or growth',
      'Treatment': 'Usually none; laser therapy or removal if cosmetic or bleeding'
    }
  };

  static Map<String, String>? getInfoForClass(String className) {
    // Exact match first
    if (classInfo.containsKey(className)) {
      return classInfo[className];
    }
    // Then partial/case-insensitive match
    String lower = className.toLowerCase();
    for (var key in classInfo.keys) {
      if (lower.contains(key.toLowerCase()) || key.toLowerCase().contains(lower)) {
        return classInfo[key];
      }
    }
    return null;
  }
}
