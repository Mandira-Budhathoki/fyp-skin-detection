import 'package:flutter/material.dart';

class MelanomaInfoProvider {
  static const Map<String, Map<String, String>> classInfo = {
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
    // Exact match or partial match if string formats vary slightly
    for (var key in classInfo.keys) {
      if (className.contains(key) || key.contains(className)) {
        return classInfo[key];
      }
    }
    return null;
  }
}
