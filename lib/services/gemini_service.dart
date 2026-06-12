import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = 'YOUR_API_KEY';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  // ─── Resume Summary Generate ───────────────────────────────────────────────
  static Future<String> generateSummary({
    required String name,
    required String jobTitle,
    required String experience,
    required String education,
    required List<String> skills,
  }) async {
    final prompt = '''
You are a professional resume writer.
Write a compelling 3-4 line professional summary for a resume.

Candidate Details:
- Name: $name
- Job Title: $jobTitle
- Experience: $experience
- Education: $education
- Skills: ${skills.join(', ')}

Rules:
- Start with the job title
- Mention top 2-3 skills
- Sound confident and professional
- Do NOT use bullet points
- Return ONLY the summary paragraph, nothing else
''';

    return await _callGemini(prompt);
  }

  // ─── Skills Suggest ────────────────────────────────────────────────────────
  static Future<List<String>> suggestSkills(String jobTitle) async {
    final prompt = '''
List 12 relevant skills for a "$jobTitle" position.

Rules:
- Mix of technical and soft skills
- Return ONLY a comma-separated list
- No numbering, no bullets, no explanation
- Example format: Flutter, Dart, REST APIs, Git, Problem Solving

Return the list now:
''';

    final result = await _callGemini(prompt);

    // Error aaya to empty list return karo
    if (result.startsWith('Error') || result.startsWith('Network')) {
      return [];
    }

    return result
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length < 40) // ← long error text filter
        .toList();
  }
  // ─── Core API Call ─────────────────────────────────────────────────────────
  static Future<String> _callGemini(String prompt, {int retries = 3}) async {
    for (int i = 0; i < retries; i++) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl?key=$_apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "contents": [
              {
                "parts": [{"text": prompt}]
              }
            ],
            "generationConfig": {
              "temperature": 0.7,
              "maxOutputTokens": 500,
            }
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
          return text.trim();
        } else if (response.statusCode == 503 || response.statusCode == 429) {
          // High demand — thoda wait karo aur retry karo
          await Future.delayed(Duration(seconds: 2 * (i + 1)));
          continue;
        } else {
          final error = jsonDecode(response.body);
          return 'Error: ${error['error']['message']}';
        }
      } catch (e) {
        if (i == retries - 1) return 'Network Error: $e';
        await Future.delayed(Duration(seconds: 2 * (i + 1)));
      }
    }
    return 'Error: Server busy hai, thodi der baad try karo';
  }
}