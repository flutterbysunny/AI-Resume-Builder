import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/resume_controller.dart';
import '../models/resume_model.dart';
import 'preview_screen.dart';

class FormScreen extends StatelessWidget {
  const FormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResumeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        title: Text(
          'AI Resume Builder',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepIndicator(controller),
          Obx(() => controller.currentStep.value == 0
              ? _buildUploadCard(controller)
              : const SizedBox.shrink()),
          Expanded(
            child: Obx(() {
              switch (controller.currentStep.value) {
                case 0:
                  return _buildPersonalInfoStep(controller);
                case 1:
                  return _buildJobInfoStep(controller);
                case 2:
                  return _buildSkillsStep(controller);
                case 3:
                  return _buildSummaryStep(controller);
                default:
                  return _buildPersonalInfoStep(controller);
              }
            }),
          ),
          _buildBottomNavigation(controller),
        ],
      ),
    );
  }

  // ─── Step Indicator ────────────────────────────────────────────────────────
  Widget _buildStepIndicator(ResumeController controller) {
    final steps = ['Personal', 'Job Info', 'Skills', 'Summary'];

    return Container(
      color: const Color(0xFF2563EB),
      padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      child: Obx(() => Row(
        children: List.generate(steps.length, (index) {
          final isActive = controller.currentStep.value == index;
          final isDone = controller.currentStep.value > index;

          return Expanded(
            child: GestureDetector(
              onTap: () => controller.goToStep(index),
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDone
                          ? Colors.green
                          : isActive
                          ? Colors.white
                          : Colors.white30,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF2563EB)
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[index],
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white60,
                      fontSize: 11,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      )),
    );
  }

  // ─── Step 1: Personal Info ─────────────────────────────────────────────────
  Widget _buildPersonalInfoStep(ResumeController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Personal Information', Icons.person),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Full Name',
            hint: 'e.g. Rahul Sharma',
            icon: Icons.badge,
            controller: controller.nameController,      // ← ADD
            onChanged: controller.updateName,
          ),
          _buildTextField(
            label: 'Email Address',
            hint: 'e.g. rahul@gmail.com',
            icon: Icons.email,
            controller: controller.emailController,     // ← ADD
            keyboardType: TextInputType.emailAddress,
            onChanged: controller.updateEmail,
          ),
          _buildTextField(
            label: 'Phone Number',
            hint: 'e.g. +91 9876543210',
            icon: Icons.phone,
            controller: controller.phoneController,     // ← ADD
            keyboardType: TextInputType.phone,
            onChanged: controller.updatePhone,
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'City',
                  hint: 'e.g. Mumbai',
                  icon: Icons.location_city,
                  controller: controller.cityController,      // ← ADD
                  onChanged: controller.updateCity,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Country',
                  hint: 'e.g. India',
                  icon: Icons.flag,
                  controller: controller.countryController,   // ← ADD
                  onChanged: controller.updateCountry,
                ),
              ),
            ],
          ),
          _buildTextField(
            label: 'LinkedIn (Optional)',
            hint: 'linkedin.com/in/rahul',
            icon: Icons.link,
            controller: controller.linkedinController,  // ← ADD
            onChanged: controller.updateLinkedin,
          ),
          _buildTextField(
            label: 'GitHub (Optional)',
            hint: 'github.com/rahul',
            icon: Icons.code,
            controller: controller.githubController,    // ← ADD
            onChanged: controller.updateGithub,
          ),
        ],
      ),
    );
  }

  // ─── Step 2: Job Info ──────────────────────────────────────────────────────
  Widget _buildJobInfoStep(ResumeController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Job Information', Icons.work),
          const SizedBox(height: 16),

          // Job Title
          _buildTextField(
            label: 'Job Title',
            hint: 'e.g. Flutter Developer',
            icon: Icons.title,
            controller: controller.jobTitleController,
            onChanged: controller.updateJobTitle,
          ),

          const SizedBox(height: 8),

          // ─── Work Experience Section ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Work Experience',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              TextButton.icon(
                onPressed: () => _showAddWorkDialog(controller),
                icon: const Icon(Icons.add, size: 18),
                label: Text('Add', style: GoogleFonts.poppins(fontSize: 13)),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB)),
              ),
            ],
          ),

          Obx(() {
            final list = controller.resume.value.workExperiences;
            if (list.isEmpty) {
              return _emptyCard('No work experience added yet');
            }
            return Column(
              children: list.asMap().entries.map((entry) {
                final i = entry.key;
                final exp = entry.value;
                return _workExpCard(exp, i, controller);
              }).toList(),
            );
          }),

          const SizedBox(height: 16),

          // ─── Education Section ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Education',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              TextButton.icon(
                onPressed: () => _showAddEducationDialog(controller),
                icon: const Icon(Icons.add, size: 18),
                label: Text('Add', style: GoogleFonts.poppins(fontSize: 13)),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB)),
              ),
            ],
          ),

          Obx(() {
            final list = controller.resume.value.educations;
            if (list.isEmpty) {
              return _emptyCard('No education added yet');
            }
            return Column(
              children: list.asMap().entries.map((entry) {
                final i = entry.key;
                final edu = entry.value;
                return _educationCard(edu, i, controller);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

// ─── Work Exp Card ─────────────────────────────────────────────────────────
  Widget _workExpCard(WorkExperience exp, int index, ResumeController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.business_center,
              color: Color(0xFF2563EB), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${exp.jobTitle} — ${exp.company}',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text('${exp.startDate} - ${exp.endDate} | ${exp.location}',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[600])),
                if (exp.bullets.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ...exp.bullets.map((b) => Text('• $b',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.grey[700]))),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 20),
            onPressed: () => controller.removeWorkExperience(index),
          ),
        ],
      ),
    );
  }

// ─── Education Card ────────────────────────────────────────────────────────
  Widget _educationCard(Education edu, int index, ResumeController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.school, color: Color(0xFF2563EB), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(edu.degree,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(edu.institution,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[600])),
                Text('${edu.startDate} – ${edu.endDate}',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 20),
            onPressed: () => controller.removeEducation(index),
          ),
        ],
      ),
    );
  }

// ─── Empty Card ────────────────────────────────────────────────────────────
  Widget _emptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
      ),
      child: Text(message,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13)),
    );
  }

// ─── Add Work Dialog ───────────────────────────────────────────────────────
  void _showAddWorkDialog(ResumeController controller) {
    final jobTitleC = TextEditingController();
    final companyC = TextEditingController();
    final locationC = TextEditingController();
    final startC = TextEditingController();
    final endC = TextEditingController();
    final bulletsC = TextEditingController();

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Work Experience',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 16),
              _simpleField('Job Title', 'e.g. Flutter Developer', jobTitleC),
              _simpleField('Company', 'e.g. TechupR', companyC),
              _simpleField('Location', 'e.g. Ahmedabad', locationC),
              Row(children: [
                Expanded(child: _simpleField('Start', 'MM/YYYY', startC)),
                const SizedBox(width: 10),
                Expanded(child: _simpleField('End', 'MM/YYYY or Present', endC)),
              ]),
              _simpleField('Bullets (one per line)', 'Built Flutter apps...',
                  bulletsC, maxLines: 4),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final bullets = bulletsC.text
                        .split('\n')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();
                    controller.addWorkExperience(WorkExperience(
                      jobTitle: jobTitleC.text,
                      company: companyC.text,
                      location: locationC.text,
                      startDate: startC.text,
                      endDate: endC.text,
                      bullets: bullets,
                    ));
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Add Experience',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// ─── Add Education Dialog ──────────────────────────────────────────────────
  void _showAddEducationDialog(ResumeController controller) {
    final degreeC = TextEditingController();
    final institutionC = TextEditingController();
    final startC = TextEditingController();
    final endC = TextEditingController();

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Education',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 16),
              _simpleField('Degree', 'e.g. B.Tech Computer Science', degreeC),
              _simpleField('Institution', 'e.g. GTU Ahmedabad', institutionC),
              Row(children: [
                Expanded(child: _simpleField('Start', 'MM/YYYY', startC)),
                const SizedBox(width: 10),
                Expanded(child: _simpleField('End', 'MM/YYYY', endC)),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.addEducation(Education(
                      degree: degreeC.text,
                      institution: institutionC.text,
                      startDate: startC.text,
                      endDate: endC.text,
                    ));
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Add Education',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// ─── Simple Field Helper ───────────────────────────────────────────────────
  Widget _simpleField(String label, String hint, TextEditingController c,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TextFormField(
            controller: c,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
              GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12),
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 12, vertical: maxLines > 1 ? 12 : 0),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 3: Skills ────────────────────────────────────────────────────────
  Widget _buildSkillsStep(ResumeController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Skills', Icons.psychology),
          const SizedBox(height: 8),
          Text(
            'AI tumhare job title ke basis pe skills suggest karega',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          // Suggest Button
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton.icon(
              onPressed: controller.isLoadingSkills.value
                  ? null
                  : controller.loadSkillSuggestions,
              icon: controller.isLoadingSkills.value
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                controller.isLoadingSkills.value
                    ? 'Generating...'
                    : '✨ AI Se Skills Suggest Karo',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )),
          ),
          const SizedBox(height: 20),

          // Suggested Skills Chips
          Obx(() {
            if (controller.suggestedSkills.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Icon(Icons.lightbulb_outline,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Button press karo — AI skills suggest karega',
                      style: GoogleFonts.poppins(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tap karke select karo (max 10):',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.suggestedSkills.map((skill) {
                    return Obx(() {
                      final isSelected = controller.isSkillSelected(skill);
                      return FilterChip(
                        label: Text(
                          skill,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) => controller.toggleSkill(skill),
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF2563EB),
                        checkmarkColor: Colors.white,
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : Colors.grey.shade300,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      );
                    });
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Obx(() => Text(
                  '${controller.selectedSkills.length}/10 selected',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                  ),
                )),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── Step 4: AI Summary ────────────────────────────────────────────────────
  Widget _buildSummaryStep(ResumeController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('AI Summary', Icons.auto_awesome),
          const SizedBox(height: 8),
          Text(
            'AI tumhare liye ek professional summary likhega',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton.icon(
              onPressed: controller.isLoadingSummary.value
                  ? null
                  : controller.generateAISummary,
              icon: controller.isLoadingSummary.value
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                controller.isLoadingSummary.value
                    ? 'AI Likh Raha Hai...'
                    : '✨ AI Summary Generate Karo',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )),
          ),
          const SizedBox(height: 24),

          // Summary Output Box
          Obx(() {
            final summary = controller.resume.value.aiSummary;
            if (summary.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.description_outlined,
                        size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(
                      'Summary yahan dikhega',
                      style: GoogleFonts.poppins(color: Colors.grey[400]),
                    ),
                  ],
                ),
              );
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: Color(0xFF2563EB), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'AI Generated Summary',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    summary,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Regenerate Button
                  TextButton.icon(
                    onPressed: controller.generateAISummary,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(
                      'Regenerate',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Preview Resume Button
          Obx(() {
            if (!controller.resume.value.hasAISummary) {
              return const SizedBox.shrink();
            }
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.to(() => const PreviewScreen()),
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(
                  '📄 Resume Preview & Download',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Bottom Navigation ─────────────────────────────────────────────────────
  Widget _buildBottomNavigation(ResumeController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() => Row(
        children: [
          if (controller.currentStep.value > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '← Back',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (controller.currentStep.value > 0) const SizedBox(width: 12),
          if (controller.currentStep.value < 3)
            Expanded(
              child: ElevatedButton(
                onPressed: controller.nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Next →',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      )),
    );
  }

  // ─── Reusable Widgets ──────────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2563EB), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
    required TextEditingController controller, // ← ADD
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller, // ← ADD
            onChanged: onChanged,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 13,
              ),
              prefixIcon: Icon(icon, color: const Color(0xFF2563EB), size: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: maxLines > 1 ? 14 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Upload Resume Card ─────────────────────────────────────────────────────
  Widget _buildUploadCard(ResumeController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isUploadingResume.value) {
          return Row(
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'AI tumhara resume padh raha hai...',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.upload_file,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Already Resume Hai?',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'PDF upload karo — sab kuch auto-fill ho jayega',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _pickAndUploadResume(controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                'Upload',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

// ─── Pick PDF & Upload ───────────────────────────────────────────────────────
  Future<void> _pickAndUploadResume(ResumeController controller) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // bytes directly milte hain
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;

    if (bytes == null) {
      Get.snackbar(
        'Error',
        'File read nahi ho saki, dobara try karo',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await controller.uploadAndParseResume(bytes);
  }

}