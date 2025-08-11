class WelcomeModel {
  final String title;
  final String subtitle;
  final String image;

  WelcomeModel({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  factory WelcomeModel.fromJson(Map<String, dynamic> json) {
    return WelcomeModel(
      title: json['title'],
      subtitle: json['subtitle'],
      image: json['image'],
    );
  }
}
