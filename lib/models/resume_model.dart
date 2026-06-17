class WorkExperience {
  String jobTitle;
  String company;
  String location;
  String startDate;
  String endDate;
  List<String> bullets;

  WorkExperience({
    this.jobTitle = '',
    this.company = '',
    this.location = '',
    this.startDate = '',
    this.endDate = '',
    this.bullets = const [],
  });
}

class Project {
  String name;
  String role;
  String description;
  List<String> techStack;

  Project({
    this.name = '',
    this.role = '',
    this.description = '',
    this.techStack = const [],
  });
}

class Education {
  String degree;
  String institution;
  String startDate;
  String endDate;

  Education({
    this.degree = '',
    this.institution = '',
    this.startDate = '',
    this.endDate = '',
  });
}

class ResumeModel {
  // Personal
  String name;
  String email;
  String phone;
  String jobTitle;
  String city;
  String country;
  String linkedin;
  String github;
  String portfolio;
  String website;

  // Content
  String aiSummary;
  List<String> skills;
  List<WorkExperience> workExperiences;
  List<Education> educations;
  List<Project> projects;
  String techStack;

  ResumeModel({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.jobTitle = '',
    this.city = '',
    this.country = '',
    this.linkedin = '',
    this.github = '',
    this.portfolio = '',
    this.website = '',
    this.aiSummary = '',
    this.skills = const [],
    this.workExperiences = const [],
    this.educations = const [],
    this.projects = const [],
    this.techStack = '',
  });

  bool get isValid =>
      name.isNotEmpty &&
          email.isNotEmpty &&
          phone.isNotEmpty &&
          jobTitle.isNotEmpty;

  bool get hasAISummary => aiSummary.isNotEmpty;
  bool get hasSkills => skills.isNotEmpty;
  // ─── Convert Gemini's JSON response into ResumeModel ──────────────────────
  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      linkedin: json['linkedin'] ?? '',
      github: json['github'] ?? '',
      website: json['website'] ?? '',
      aiSummary: json['summary'] ?? '',
      skills: (json['skills'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      techStack: json['techStack'] ?? '',
      workExperiences: (json['workExperiences'] as List<dynamic>?)
          ?.map((e) => WorkExperience(
        jobTitle: e['jobTitle'] ?? '',
        company: e['company'] ?? '',
        location: e['location'] ?? '',
        startDate: e['startDate'] ?? '',
        endDate: e['endDate'] ?? '',
        bullets: (e['bullets'] as List<dynamic>?)
            ?.map((b) => b.toString())
            .toList() ??
            [],
      ))
          .toList() ??
          [],
      educations: (json['educations'] as List<dynamic>?)
          ?.map((e) => Education(
        degree: e['degree'] ?? '',
        institution: e['institution'] ?? '',
        startDate: e['startDate'] ?? '',
        endDate: e['endDate'] ?? '',
      ))
          .toList() ??
          [],
      projects: (json['projects'] as List<dynamic>?)
          ?.map((e) => Project(
        name: e['name'] ?? '',
        role: e['role'] ?? '',
        description: e['description'] ?? '',
        techStack: (e['techStack'] as List<dynamic>?)
            ?.map((t) => t.toString())
            .toList() ??
            [],
      ))
          .toList() ??
          [],
    );
  }
}