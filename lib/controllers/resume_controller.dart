import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/resume_model.dart';
import '../services/gemini_service.dart';

class ResumeController extends GetxController {
  // ─── Text Editing Controllers ──────────────────────────────────────────────
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final jobTitleController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final linkedinController = TextEditingController();
  final githubController = TextEditingController();
  final websiteController = TextEditingController();

  // ─── Observables ───────────────────────────────────────────────────────────
  var resume = ResumeModel().obs;
  var isLoadingSummary = false.obs;
  var isLoadingSkills = false.obs;
  var suggestedSkills = <String>[].obs;
  var selectedSkills = <String>[].obs;
  var currentStep = 0.obs;

  // ─── Init ──────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    // preFillSunnyData();
  }

  // ─── Dispose ───────────────────────────────────────────────────────────────
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    jobTitleController.dispose();
    cityController.dispose();
    countryController.dispose();
    linkedinController.dispose();
    githubController.dispose();
    websiteController.dispose();
    super.onClose();
  }

  // ─── Form Update Methods ───────────────────────────────────────────────────
  void updateName(String val) => resume.update((r) => r?.name = val);
  void updateEmail(String val) => resume.update((r) => r?.email = val);
  void updatePhone(String val) => resume.update((r) => r?.phone = val);
  void updateJobTitle(String val) => resume.update((r) => r?.jobTitle = val);
  void updateCity(String val) => resume.update((r) => r?.city = val);
  void updateCountry(String val) => resume.update((r) => r?.country = val);
  void updateLinkedin(String val) => resume.update((r) => r?.linkedin = val);
  void updateGithub(String val) => resume.update((r) => r?.github = val);
  void updateWebsite(String val) => resume.update((r) => r?.website = val);
  void updateTechStack(String val) => resume.update((r) => r?.techStack = val);

  // ─── Skills Logic ──────────────────────────────────────────────────────────
  void toggleSkill(String skill) {
    if (selectedSkills.contains(skill)) {
      selectedSkills.remove(skill);
    } else {
      if (selectedSkills.length >= 10) {
        Get.snackbar(
          'Limit Reached',
          'Maximum 10 skills select kar sakte ho',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      selectedSkills.add(skill);
    }
    resume.update((r) => r?.skills = selectedSkills.toList());
  }

  bool isSkillSelected(String skill) => selectedSkills.contains(skill);

  // ─── Work Experience CRUD ──────────────────────────────────────────────────
  void addWorkExperience(WorkExperience exp) {
    final list = [...resume.value.workExperiences, exp];
    resume.update((r) => r?.workExperiences = list);
  }

  void updateWorkExperience(int index, WorkExperience exp) {
    final list = [...resume.value.workExperiences];
    list[index] = exp;
    resume.update((r) => r?.workExperiences = list);
  }

  void removeWorkExperience(int index) {
    final list = [...resume.value.workExperiences];
    list.removeAt(index);
    resume.update((r) => r?.workExperiences = list);
  }

  // ─── Education CRUD ────────────────────────────────────────────────────────
  void addEducation(Education edu) {
    final list = [...resume.value.educations, edu];
    resume.update((r) => r?.educations = list);
  }

  void updateEducation(int index, Education edu) {
    final list = [...resume.value.educations];
    list[index] = edu;
    resume.update((r) => r?.educations = list);
  }

  void removeEducation(int index) {
    final list = [...resume.value.educations];
    list.removeAt(index);
    resume.update((r) => r?.educations = list);
  }

  // ─── Project CRUD ──────────────────────────────────────────────────────────
  void addProject(Project project) {
    final list = [...resume.value.projects, project];
    resume.update((r) => r?.projects = list);
  }

  void updateProject(int index, Project project) {
    final list = [...resume.value.projects];
    list[index] = project;
    resume.update((r) => r?.projects = list);
  }

  void removeProject(int index) {
    final list = [...resume.value.projects];
    list.removeAt(index);
    resume.update((r) => r?.projects = list);
  }

  // ─── AI Skills Suggest ─────────────────────────────────────────────────────
  Future<void> loadSkillSuggestions() async {
    final jobTitle = resume.value.jobTitle.trim();
    if (jobTitle.isEmpty) {
      Get.snackbar('Job Title Required', 'Pehle job title fill karo',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoadingSkills.value = true;
    suggestedSkills.clear();

    final skills = await GeminiService.suggestSkills(jobTitle);

    if (skills.isNotEmpty) {
      suggestedSkills.assignAll(skills);
    } else {
      Get.snackbar(
        '⚠️ Server Busy',
        'Gemini abhi busy hai, 10 seconds baad dobara try karo',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.orange.shade100,
      );
    }
    isLoadingSkills.value = false;
  }

  // ─── AI Summary Generate ───────────────────────────────────────────────────
  Future<void> generateAISummary() async {
    if (selectedSkills.isEmpty) {
      Get.snackbar('Skills Required', 'Kam se kam 1 skill select karo',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (!resume.value.isValid) {
      Get.snackbar('Form Incomplete', 'Pehle saari details fill karo',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoadingSummary.value = true;

    // Work experience string banao summary ke liye
    final expText = resume.value.workExperiences
        .map((e) => '${e.jobTitle} at ${e.company} (${e.startDate} - ${e.endDate})')
        .join(', ');

    final eduText = resume.value.educations
        .map((e) => '${e.degree} from ${e.institution}')
        .join(', ');

    final summary = await GeminiService.generateSummary(
      name: resume.value.name,
      jobTitle: resume.value.jobTitle,
      experience: expText,
      education: eduText,
      skills: selectedSkills,
    );

    resume.update((r) => r?.aiSummary = summary);
    isLoadingSummary.value = false;

    if (!summary.startsWith('Error') && !summary.startsWith('Network')) {
      Get.snackbar(
        '✅ Summary Ready!',
        'AI ne tumhara resume summary generate kar diya',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ─── Step Navigation ───────────────────────────────────────────────────────
  void nextStep() { if (currentStep.value < 3) currentStep.value++; }
  void prevStep() { if (currentStep.value > 0) currentStep.value--; }
  void goToStep(int step) => currentStep.value = step;

  // ─── Validation ────────────────────────────────────────────────────────────
  bool isStepValid(int step) {
    switch (step) {
      case 0:
        return resume.value.name.isNotEmpty &&
            resume.value.email.isNotEmpty &&
            resume.value.phone.isNotEmpty;
      case 1:
        return resume.value.jobTitle.isNotEmpty &&
            resume.value.workExperiences.isNotEmpty;
      case 2:
        return selectedSkills.isNotEmpty;
      case 3:
        return resume.value.hasAISummary;
      default:
        return false;
    }
  }

  // ─── Reset ─────────────────────────────────────────────────────────────────
  void resetAll() {
    resume.value = ResumeModel();
    selectedSkills.clear();
    suggestedSkills.clear();
    currentStep.value = 0;
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    jobTitleController.clear();
    cityController.clear();
    countryController.clear();
    linkedinController.clear();
    githubController.clear();
    websiteController.clear();
  }

  // ─── Pre Fill Data ─────────────────────────────────────────────────────────
  void preFillSunnyData() {
    nameController.text = 'Sunny Singh';
    emailController.text = 'ns613017@gmail.com';
    phoneController.text = '+91 9725020716';
    jobTitleController.text = 'Sr Flutter Developer';
    cityController.text = 'Ahmedabad';
    countryController.text = 'Gujarat';
    linkedinController.text = 'Sunny Singh';
    githubController.text = 'Github';
    websiteController.text = 'Codes With Sunny';

    resume.update((r) {
      if (r == null) return;
      r.name = 'Sunny Singh';
      r.email = 'ns613017@gmail.com';
      r.phone = '+91 9725020716';
      r.jobTitle = 'Sr Flutter Developer';
      r.city = 'Ahmedabad';
      r.country = 'Gujarat';
      r.linkedin = 'Sunny Singh';
      r.github = 'Github';
      r.website = 'Codes With Sunny';

      r.workExperiences = [
        WorkExperience(
          jobTitle: 'Sr. Flutter Developer',
          company: 'TechupR',
          location: 'Ahmedabad',
          startDate: '01/2024',
          endDate: '05/2026',
          bullets: [
            'Developed high-performance Flutter apps for Android & iOS.',
            'Integrated REST APIs and local databases (SQLite/Hive).',
            'Optimized app performance and fixed critical bugs.',
            'Managed app releases and updates on Play Store.',
            'Followed Agile methodology and Git version control.',
          ],
        ),
        WorkExperience(
          jobTitle: 'Flutter Developer',
          company: 'Appuno It Solutions',
          location: 'Ahmedabad',
          startDate: '05/2023',
          endDate: '12/2023',
          bullets: [],
        ),
        WorkExperience(
          jobTitle: 'Flutter Developer',
          company: 'Devkrushna Infotech Pvt Ltd',
          location: 'Ahmedabad',
          startDate: '01/2022',
          endDate: '04/2023',
          bullets: [],
        ),
        WorkExperience(
          jobTitle: 'Flutter Developer',
          company: 'Tristate Technology',
          location: 'Ahmedabad',
          startDate: '01/2021',
          endDate: '01/2022',
          bullets: [],
        ),
      ];

      r.educations = [
        Education(
          degree: 'Bachelor of Engineering: Computer Engineering Technology',
          institution: 'Gujarat Technological University - Ahmedabad',
          startDate: '08/2018',
          endDate: '06/2021',
        ),
        Education(
          degree: 'Diploma: Computer Engineer',
          institution: 'Gujarat Technological University - Ahmedabad',
          startDate: '08/2015',
          endDate: '06/2018',
        ),
        Education(
          degree: 'SSC',
          institution: 'Shree Amrita Academy - Ankleshwar, GIDC',
          startDate: '01/2007',
          endDate: '03/2015',
        ),
      ];

      r.projects = [
        Project(
          name: 'Volpi',
          role: 'Senior Flutter Developer',
          description:
          'Storytelling/Multimedia App. Built complete app from scratch using Flutter & GetX. Implemented m3u8 video streaming, subtitles, audio switching, AirPlay/Chromecast, offline downloads, background playback, mini player, push notifications.',
          techStack: ['Flutter', 'GetX', 'm3u8', 'AirPlay', 'Chromecast'],
        ),
        Project(
          name: 'Finance Jobs Int',
          role: 'Senior Flutter Developer',
          description:
          'Job Portal Application. Developed complete application from scratch using Flutter & GetX. Integrated REST APIs, handled app optimisation, bug fixing, and managed iOS/App Store releases.',
          techStack: ['Flutter', 'GetX', 'REST APIs'],
        ),
        Project(
          name: 'Universal EV',
          role: 'Senior Flutter Developer',
          description:
          'EV Charging Application. Integrated Google Maps, REST APIs, real-time charging station data, and improved app performance across devices.',
          techStack: ['Flutter', 'Google Maps', 'REST APIs'],
        ),
        Project(
          name: 'DateNite',
          role: 'Flutter Developer',
          description:
          'Dating & Social Networking App. Built from scratch with swipe-based UI, Firebase authentication, real-time chat, push notifications.',
          techStack: ['Flutter', 'Firebase', 'REST APIs'],
        ),
        Project(
          name: 'Blkem',
          role: 'Senior Flutter Developer',
          description:
          'Social Networking Platform. Implemented new social features, album screens, bug fixing, and collaborated with backend teams.',
          techStack: ['Flutter', 'Firebase'],
        ),
      ];

      r.skills = [
        'Flutter', 'Dart', 'Java', 'Kotlin',
        'GetX', 'Bloc',
        'Firebase', 'SQFLite',
        'REST APIs', 'Dio', 'GraphQL',
        'Google Maps', 'Git', 'Agile',
      ];

      r.techStack =
      'Flutter, Dart, Java, GetX, Bloc, Firebase, REST APIs, Google Maps, m3u8 Streaming, AirPlay, Chromecast, SQFLite, GitHub, GitLab, Agile Methodology';

      r.aiSummary =
      'A Flutter Application Developer with 5+ years of experience in Flutter Application Development. Well-versed in Software Development Life cycles with expertise in Agile and Waterfall methodologies. Proficient in Java, Dart, GetX, Bloc, Firebase, REST APIs, and SQFLite. Strong debugging skills with hands-on experience in GitLab and GitHub version control.';
    });

    selectedSkills.assignAll([
      'Flutter', 'Dart', 'GetX', 'Bloc',
      'Firebase', 'REST APIs', 'Google Maps',
      'SQFLite', 'Java', 'Git',
    ]);
  }
}