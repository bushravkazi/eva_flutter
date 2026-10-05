import 'package:flutter/foundation.dart';

/// Offline Translation Service providing Hindi translations for game prompts,
/// profile narratives, relationships, and UI feedback strings.
class TranslationService {
  static final Map<String, String> _phraseMap = {
    "Who is shown in this picture?": "इस चित्र में कौन दिखाई दे रहा है?",
    "Recall: Who was shown in the study card earlier?": "याद कीजिए: पहले अध्ययन कार्ड में कौन दिखाया गया था?",
    "Which person matches this description?": "कौन सा व्यक्ति इस विवरण से मेल खाता है?",
    "Take your time to study this narrative.": "इस विवरण को ध्यान से पढ़ें।",
    "Hard Level Study: Read the description below (Image & name hidden).":
        "कठिन स्तर का अध्ययन: नीचे दिए गए विवरण को पढ़ें।",
    "Target description:": "लक्ष्य विवरण:",
    "Target Description": "लक्ष्य विवरण",
    "Relationship:": "संबंध:",
    "Relationship Hint:": "संबंध संकेत:",
    "This person is a": "यह व्यक्ति हैं",
    "Correct! That is": "सही! यह",
    "Not quite. Please try again!": "बिल्कुल नहीं। कृपया पुनः प्रयास करें!",

    // Demo profile narratives & notes
    "Loves gardening and bakes every Sunday morning.":
        "बागबानी पसंद है और हर रविवार सुबह बेकिंग करती हैं।",
    "Enjoys listening to classical music.": "शास्त्रीय संगीत सुनना पसंद है।",
    "Graduated bachelors program in Commerce.":
        "वाणिज्य (कॉमर्स) में स्नातक की पढ़ाई पूरी की है।",
    "Loves playing chess.": "शतरंज खेलना पसंद है।",
    "Enjoys strawberry ice cream after school.":
        "स्कूल के बाद स्ट्रॉबेरी आइसक्रीम खाना पसंद है।",
    "Painting and coloring landscapes.":
        "प्राकृतिक दृश्यों की चित्रकारी और रंग भरना पसंद है।",
    "Brings over fresh morning tea every Tuesday.":
        "हर मंगलवार सुबह ताज़ी चाय लेकर आते हैं।",
    "WorkS as a professor and loves talking about astronomy.":
        "प्रोफेसर के रूप में काम करते हैं और खगोल विज्ञान के बारे में बात करना पसंद करते हैं।",
    "Works as a professor and loves talking about astronomy.":
        "प्रोफेसर के रूप में काम करते हैं और खगोल विज्ञान के बारे में बात करना पसंद करते हैं।",
    "Visits every morning to help with walking exercises and breakfast.":
        "हर सुबह टहलने के व्यायाम और नाश्ते में मदद करने आती हैं।",
    "Loves singing morning folk songs and bringing flower bouquets.":
        "सुबह के लोकगीत गाना और फूलों के गुलदस्ते लाना पसंद करती हैं।",
    "Loves gardening and bakes every Sunday morning. Enjoys listening to classical music.":
        "बागबानी पसंद है और हर रविवार सुबह बेकिंग करती हैं। शास्त्रीय संगीत सुनना पसंद है।",
    "Graduated bachelors program in Commerce. Loves playing chess.":
        "वाणिज्य में स्नातक की पढ़ाई पूरी की है। शतरंज खेलना पसंद है।",
    "Enjoys strawberry ice cream after school. Painting and coloring landscapes.":
        "स्कूल के बाद स्ट्रॉबेरी आइसक्रीम खाना पसंद है। प्राकृतिक दृश्यों की चित्रकारी और रंग भरना पसंद है।",
    "Brings over fresh morning tea every Tuesday. WorkS as a professor and loves talking about astronomy.":
        "हर मंगलवार सुबह ताज़ी चाय लेकर आते हैं। प्रोफेसर के रूप में काम करते हैं और खगोल विज्ञान के बारे में बात करना पसंद करते हैं।",
    "Visits every morning to help with walking exercises and breakfast. Loves singing morning folk songs and bringing flower bouquets.":
        "हर सुबह टहलने के व्यायाम और नाश्ते में मदद करने आती हैं। सुबह के लोकगीत गाना और फूलों के गुलदस्ते लाना पसंद करती हैं।",
  };

  static final Map<String, String> _wordMap = {
    "Grandmother": "दादी",
    "Son": "बेटा",
    "Granddaughter": "पोती",
    "Neighbor": "पड़ोसी",
    "Caregiver": "देखभाल करने वाली",
    "Daughter": "बेटी",
    "Father": "पिता",
    "Mother": "मां",
    "Grandfather": "दादा",
    "Grandchild": "पोता या पोती",
    "Family member": "परिवार का सदस्य",
    "Uncle": "अंकल",
    "Aunt": "आंटी",
    "Friend": "मित्र",
    "Sister": "बहन",
    "Brother": "भाई",
    "Rekha": "रेखा",
    "Rishabh": "ऋषभ",
    "Siya": "सिया",
    "Mr. Patel": "मिस्टर पटेल",
    "Anna": "अन्ना",
    "Sarah Miller": "सराह मिलर",
    "Robert Chen": "रॉबर्ट चेन",
    "Maya Lin": "माया लिन",
    "David Thorne": "डेविड थोर्न",
    "Emma Vance": "एम्मा वेंस",
    "Grandma Rose": "ग्रैंडमा रोज़",
    "Uncle Tom": "अंकल टॉम",
    "Sana Patel": "सनाव पटेल",
    "Neighbor Julia": "नेबर जूलिया",
  };

  /// Translates English text into Hindi for TTS speech output.
  static String toHindi(String text) {
    if (text.trim().isEmpty) return text;
    final trimmed = text.trim();

    // 1. Direct exact match
    if (_phraseMap.containsKey(trimmed)) {
      return _phraseMap[trimmed]!;
    }

    // 2. Pattern match for hard level description prompt:
    // e.g. "Which person matches this description?\n\"...\""
    if (trimmed.startsWith("Which person matches this description?")) {
      String desc = trimmed.replaceFirst("Which person matches this description?", "").trim();
      desc = desc.replaceAll(RegExp(r'^[\n"\s]+|[\n"\s]+$'), '');
      final translatedDesc = toHindi(desc);
      return "कौन सा व्यक्ति इस विवरण से मेल खाता है? $translatedDesc";
    }

    // 3. Pattern match for hard level study card: "Target description: ..."
    if (trimmed.startsWith("Target description:")) {
      final content = trimmed.substring("Target description:".length).trim();
      return "लक्ष्य विवरण: ${toHindi(content)}";
    }

    // 4. Pattern match for hint: "Relationship Hint: ..."
    if (trimmed.startsWith("Relationship Hint:")) {
      final rel = trimmed.substring("Relationship Hint:".length).trim();
      return "संबंध संकेत: ${toHindi(rel)}";
    }

    // 5. Compound substitution logic
    String result = trimmed;

    // Substitute pre-translated phrases within the string
    _phraseMap.forEach((key, val) {
      if (result.contains(key)) {
        result = result.replaceAll(key, val);
      }
    });

    // Substitute words (relationships, names)
    _wordMap.forEach((key, val) {
      final pattern = RegExp(r'\b' + RegExp.escape(key) + r'\b', caseSensitive: false);
      result = result.replaceAll(pattern, val);
    });

    // Replace structural labels
    result = result
        .replaceAll("Relationship:", "संबंध:")
        .replaceAll("Target description:", "लक्ष्य विवरण:")
        .replaceAll("This person is a", "यह व्यक्ति हैं");

    if (kDebugMode) {
      print("Original Text: $text => Hindi TTS: $result");
    }

    return result;
  }
}

