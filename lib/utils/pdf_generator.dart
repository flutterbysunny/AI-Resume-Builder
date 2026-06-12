import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/resume_model.dart';

class PdfGenerator {
  static const _primary = PdfColor.fromInt(0xFF2563EB);
  static const _lightBlue = PdfColor.fromInt(0xFFEFF6FF);
  static const _dark = PdfColor.fromInt(0xFF1E293B);
  static const _grey = PdfColor.fromInt(0xFF64748B);
  static const _white = PdfColors.white;
  static const _divider = PdfColor.fromInt(0xFFDBEAFE);

  // ─── Public: Preview ───────────────────────────────────────────────────────
  static Future<void> generateAndPreview(ResumeModel resume) async {
    await Printing.layoutPdf(
      onLayout: (format) => generateBytes(resume),
      name: '${resume.name}_Resume.pdf',
    );
  }

  // ─── Public: Bytes ─────────────────────────────────────────────────────────
  static Future<Uint8List> generateBytes(ResumeModel resume) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => [
          _header(resume),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Summary
                if (resume.aiSummary.isNotEmpty) ...[
                  _section('PROFILE', _summaryBody(resume.aiSummary)),
                  _gap(),
                ],

                // Skills
                if (resume.skills.isNotEmpty) ...[
                  _section('SKILLS', _skillsBody(resume.skills)),
                  _gap(),
                ],

                // Work Experience
                if (resume.workExperiences.isNotEmpty) ...[
                  _section('WORK HISTORY', _workBody(resume.workExperiences)),
                  _gap(),
                ],

                // Projects
                if (resume.projects.isNotEmpty) ...[
                  _section('PROJECTS', _projectsBody(resume.projects)),
                  _gap(),
                ],

                // Education
                if (resume.educations.isNotEmpty) ...[
                  _section('EDUCATION', _educationBody(resume.educations)),
                  _gap(),
                ],

                // Tech Stack
                if (resume.techStack.isNotEmpty) ...[
                  _section('TECH STACK', _techStackBody(resume.techStack)),
                ],

                pw.SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
    final bytes = await pdf.save();
    return Uint8List.fromList(bytes);
  }

  // ─── Header ────────────────────────────────────────────────────────────────
  static pw.Widget _header(ResumeModel resume) {
    return pw.Container(
      width: double.infinity,
      color: _primary,
      padding: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 28),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(resume.name.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 28, fontWeight: pw.FontWeight.bold,
                color: _white, letterSpacing: 2,
              )),
          pw.SizedBox(height: 4),
          pw.Text(resume.jobTitle,
              style: pw.TextStyle(
                fontSize: 14, color: const PdfColor.fromInt(0xFFBFDBFE),
                fontWeight: pw.FontWeight.bold,
              )),
          pw.SizedBox(height: 14),
          // Contact row
          pw.Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              if (resume.email.isNotEmpty) _contactChip('✉  ${resume.email}'),
              if (resume.phone.isNotEmpty) _contactChip('✆  ${resume.phone}'),
              if (resume.city.isNotEmpty) _contactChip('⌖  ${resume.city}, ${resume.country}'),
              if (resume.linkedin.isNotEmpty) _contactChip('in  ${resume.linkedin}'),
              if (resume.github.isNotEmpty) _contactChip('⌥  ${resume.github}'),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Section ───────────────────────────────────────────────────────────────
  static pw.Widget _section(String title, pw.Widget body) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(
              fontSize: 10, fontWeight: pw.FontWeight.bold,
              color: _primary, letterSpacing: 1.8,
            )),
        pw.SizedBox(height: 4),
        pw.Container(height: 1.5, color: _divider),
        pw.SizedBox(height: 10),
        body,
      ],
    );
  }

  // ─── Summary ───────────────────────────────────────────────────────────────
  static pw.Widget _summaryBody(String text) {
    return pw.Text(text,
        style: pw.TextStyle(fontSize: 10.5, color: _dark, lineSpacing: 4));
  }

  // ─── Skills ────────────────────────────────────────────────────────────────
  static pw.Widget _skillsBody(List<String> skills) {
    return pw.Wrap(
      spacing: 6, runSpacing: 6,
      children: skills.map((s) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: pw.BoxDecoration(
          color: _lightBlue,
          borderRadius: pw.BorderRadius.circular(20),
          border: pw.Border.all(color: const PdfColor.fromInt(0xFFBFDBFE)),
        ),
        child: pw.Text(s,
            style: pw.TextStyle(
                fontSize: 9, color: _primary, fontWeight: pw.FontWeight.bold)),
      )).toList(),
    );
  }

  // ─── Work Experience ───────────────────────────────────────────────────────
  static pw.Widget _workBody(List<WorkExperience> experiences) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: experiences.map((exp) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 12),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('${exp.jobTitle}, ${exp.company}',
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold, color: _dark)),
                pw.Text('${exp.startDate} - ${exp.endDate}',
                    style: pw.TextStyle(fontSize: 9.5, color: _grey)),
              ],
            ),
            if (exp.location.isNotEmpty)
              pw.Text(exp.location,
                  style: pw.TextStyle(fontSize: 9.5, color: _grey)),
            if (exp.bullets.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              ...exp.bullets.map((b) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2, left: 8),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('• ', style: pw.TextStyle(color: _primary, fontSize: 10)),
                    pw.Expanded(
                        child: pw.Text(b,
                            style: pw.TextStyle(fontSize: 10, color: _dark, lineSpacing: 2))),
                  ],
                ),
              )),
            ],
          ],
        ),
      )).toList(),
    );
  }

  // ─── Projects ──────────────────────────────────────────────────────────────
  static pw.Widget _projectsBody(List<Project> projects) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: projects.map((p) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 12),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Text(p.name,
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold, color: _dark)),
                pw.SizedBox(width: 8),
                pw.Text('— ${p.role}',
                    style: pw.TextStyle(fontSize: 10, color: _grey)),
              ],
            ),
            pw.SizedBox(height: 3),
            pw.Text(p.description,
                style: pw.TextStyle(fontSize: 10, color: _dark, lineSpacing: 2)),
            if (p.techStack.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Wrap(
                spacing: 4, runSpacing: 4,
                children: p.techStack.map((t) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFFF0FDF4),
                    borderRadius: pw.BorderRadius.circular(4),
                    border: pw.Border.all(
                        color: const PdfColor.fromInt(0xFFBBF7D0)),
                  ),
                  child: pw.Text(t,
                      style: pw.TextStyle(
                          fontSize: 8.5,
                          color: const PdfColor.fromInt(0xFF166534))),
                )).toList(),
              ),
            ],
          ],
        ),
      )).toList(),
    );
  }

  // ─── Education ─────────────────────────────────────────────────────────────
  static pw.Widget _educationBody(List<Education> educations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: educations.map((e) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(e.degree,
                      style: pw.TextStyle(
                          fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: _dark)),
                  pw.Text(e.institution,
                      style: pw.TextStyle(fontSize: 9.5, color: _grey)),
                ],
              ),
            ),
            pw.Text('${e.startDate} – ${e.endDate}',
                style: pw.TextStyle(fontSize: 9.5, color: _grey)),
          ],
        ),
      )).toList(),
    );
  }

  // ─── Tech Stack ────────────────────────────────────────────────────────────
  static pw.Widget _techStackBody(String techStack) {
    return pw.Text(techStack,
        style: pw.TextStyle(fontSize: 10, color: _dark, lineSpacing: 3));
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  static pw.Widget _contactChip(String text) {
    return pw.Text(text,
        style: pw.TextStyle(fontSize: 9.5, color: const PdfColor.fromInt(0xFFE0F2FE)));
  }

  static pw.Widget _gap() => pw.SizedBox(height: 18);
}