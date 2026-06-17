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

  // ─── Parse Resume PDF → Structured JSON ────────────────────────────────────
  static Future<Map<String, dynamic>?> parseResumePdf(List<int> pdfBytes) async {
    final base64Pdf = base64Encode(pdfBytes);

    final prompt = '''
You are a resume parser. Extract ALL information from this resume PDF and return ONLY valid JSON — no markdown, no explanation, no backticks.

Use EXACTLY this JSON structure:
{
  "name": "",
  "email": "",
  "phone": "",
  "jobTitle": "",
  "city": "",
  "country": "",
  "linkedin": "",
  "github": "",
  "website": "",
  "summary": "",
  "techStack": "comma separated string of all technologies mentioned",
  "skills": ["skill1", "skill2"],
  "workExperiences": [
    {
      "jobTitle": "",
      "company": "",
      "location": "",
      "startDate": "MM/YYYY",
      "endDate": "MM/YYYY or Present",
      "bullets": ["responsibility 1", "responsibility 2"]
    }
  ],
  "educations": [
    {
      "degree": "",
      "institution": "",
      "startDate": "MM/YYYY",
      "endDate": "MM/YYYY"
    }
  ],
  "projects": [
    {
      "name": "",
      "role": "",
      "description": "",
      "techStack": ["tech1", "tech2"]
    }
  ]
}

Rules:
- Extract every work experience and education entry found
- Extract every project mentioned, with its tech stack
- If a field is not found, use empty string "" or empty array []
- "summary" should be the existing profile/summary section if present, else leave empty
- Return ONLY the JSON object, nothing else
''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "inline_data": {
                    "mime_type": "application/pdf",
                    "data": base64Pdf,
                  }
                },
                {"text": prompt}
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.2,
            "maxOutputTokens": 4000,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['candidates'][0]['content']['parts'][0]['text'];

        // Clean markdown fences if Gemini adds them
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();

        return jsonDecode(text) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

}