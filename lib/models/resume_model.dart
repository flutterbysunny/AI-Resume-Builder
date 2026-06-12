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
}