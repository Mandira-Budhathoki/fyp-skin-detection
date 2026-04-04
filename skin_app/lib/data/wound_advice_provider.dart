import 'package:flutter/material.dart';

class WoundAdviceProvider {
  static Map<String, dynamic> getAdviceForWound(String label) {
    String cleanLabel = label.toLowerCase().trim();
    
    if (cleanLabel.contains('diabetic')) {
      return {
        'title': 'Diabetic Wound Care',
        'color': Colors.red,
        'timeline': [
          {'day': 'D1', 'task': 'Scan'},
          {'day': 'D3', 'task': 'Check Pus'},
          {'day': 'D7', 'task': 'Specialist'}
        ],
        'steps': [
          'Inspect daily for signs of infection (pus, redness).',
          'Avoid walking barefoot to prevent further injury.',
          'Control blood sugar levels (vital for healing).',
          'Consult a podiatrist or wound specialist immediately.'
        ],
        'warning': 'Diabetic ulcers have a high risk of infection and slow healing.'
      };
    } else if (cleanLabel.contains('pressure')) {
      return {
        'title': 'Pressure Ulcer Care',
        'color': Colors.orange,
        'timeline': [
          {'day': 'D1', 'task': 'Relief'},
          {'day': 'D2', 'task': 'Dressing'},
          {'day': 'D5', 'task': 'Review'}
        ],
        'steps': [
          'Relieve pressure from the area immediately.',
          'Keep the area clean and protected with a dressing.',
          'Change position every 2 hours if immobile.',
          'Use specialized cushions or mattresses.'
        ],
        'warning': 'If not managed, pressure sores can reach muscle or bone.'
      };
    } else if (cleanLabel.contains('burn')) {
      return {
        'title': 'Burn Management',
        'color': Colors.deepOrange,
        'timeline': [
          {'day': 'D1', 'task': 'Cooling'},
          {'day': 'D3', 'task': 'Bandage'},
          {'day': 'D7', 'task': 'Skin Check'}
        ],
        'steps': [
          'Run cool (not cold) water over the burn for 10-20 min.',
          'Do NOT apply ice, butter, or ointments to a fresh burn.',
          'Cover loosely with a sterile, non-stick bandage.',
          'See a doctor for blistering or deep tissue damage.'
        ],
        'warning': 'Infection and dehydration are risks for large burns.'
      };
    } else if (cleanLabel.contains('venous')) {
      return {
        'title': 'Venous Ulcer Care',
        'color': Colors.blue,
        'timeline': [
          {'day': 'D1', 'task': 'Elevate'},
          {'day': 'D7', 'task': 'Stocking'},
          {'day': 'D14', 'task': 'Circulation'}
        ],
        'steps': [
          'Elevate your legs above heart level whenever possible.',
          'Use compression stockings (if advised by a doctor).',
          'Keep the surrounding skin moisturized.',
          'Maintain a healthy weight to reduce leg pressure.'
        ],
        'warning': 'Poor circulation is the cause; long-term treatment is needed.'
      };
    } else if (cleanLabel.contains('surgical')) {
      return {
        'title': 'Post-Surgical Care',
        'color': Colors.indigo,
        'timeline': [
          {'day': 'D1', 'task': 'Dry site'},
          {'day': 'D5', 'task': 'Sutures'},
          {'day': 'D10', 'task': 'Activity'}
        ],
        'steps': [
          'Keep the incision site dry for the first 24-48 hours.',
          'Only change dressings as instructed by your surgeon.',
          'Do not pick at scabs or surgical glue.',
          'Monitor for fever or opening of the incision (dehiscence).'
        ],
        'warning': 'Call your surgeon immediately if internal stitches feel loose.'
      };
    } else if (cleanLabel.contains('abrasion') || cleanLabel.contains('cut') || cleanLabel.contains('laseration')) {
      return {
        'title': 'Acute Wound First Aid',
        'color': Colors.green,
        'timeline': [
          {'day': 'D1', 'task': 'Cleanse'},
          {'day': 'D3', 'task': 'Antibiotic'},
          {'day': 'D7', 'task': 'Healing'}
        ],
        'steps': [
          'Clean with mild soap and clean water.',
          'Apply gentle pressure to stop any bleeding.',
          'Apply a thin layer of antibiotic ointment (like Neosporin).',
          'Cover with a clean dressing to keep it moist and protected.'
        ],
        'warning': 'Tetanus shots should be up to date (every 10 years).'
      };
    } else if (cleanLabel.contains('bruise')) {
      return {
        'title': 'Bruise Recovery',
        'color': Colors.purple,
        'timeline': [
          {'day': 'D1', 'task': 'Ice'},
          {'day': 'D2', 'task': 'Elevate'},
          {'day': 'D3', 'task': 'Heat'}
        ],
        'steps': [
          'Apply a cold pack (wrapped in cloth) for 15 min.',
          'Elevate the bruised area to reduce swelling.',
          'Rest the area to allow internal healing.',
          'Warm compresses after 48 hours can help clear the blood.'
        ],
        'warning': 'Sudden, unexplained bruising may need a blood test.'
      };
    } else if (cleanLabel.contains('normal')) {
      return {
        'title': 'Healthy Skin Maintenance',
        'color': Colors.teal,
        'timeline': [
          {'day': 'W1', 'task': 'Daily Hydration'},
          {'day': 'W2', 'task': 'Protection'},
          {'day': 'W4', 'task': 'Full Check'}
        ],
        'steps': [
          'Keep skin hydrated with quality moisturizer.',
          'Use SPF 30+ sunscreen when outdoors.',
          'Maintain a balanced diet rich in Vitamin C and Zinc.',
          'Perform a full-body skin check once a month.'
        ],
        'warning': 'Even healthy skin should be monitored for new moles or changes.'
      };
    }

    return {
      'title': 'General Wound Care',
      'color': Colors.blueGrey,
      'timeline': [
        {'day': 'D1', 'task': 'Clean'},
        {'day': 'D3', 'task': 'Observe'},
        {'day': 'D7', 'task': 'Recovery'}
      ],
      'steps': [
        'Keep the area clean and dry.',
        'Avoid touching the wound with unwashed hands.',
        'Monitor for signs of infection (heat, redness, pus).',
        'Consult a healthcare provider for any concerns.'
      ],
      'warning': 'This AI is a tool, not a replacement for clinical diagnosis.'
    };
  }
}
