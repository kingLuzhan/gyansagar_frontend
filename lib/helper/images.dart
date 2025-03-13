class Images {
  static const String logo = 'assets/images/logo/pensilLogo.png';
  static const String logoText = 'assets/images/logo_text.png';
  static const String back = 'assets/images/icons/back.png';
  static const String cross = 'assets/images/icons/cross.png';
  static const String announcements = 'assets/images/icons/announcement.png';
  static const String megaphone = 'assets/images/icons/megaphone.png';
  static const String peopleWhite = 'assets/images/icons/people_white.png';
  static const String peopleBlack = 'assets/images/icons/people_black.png';
  static const String calender = 'assets/images/icons/calender.png';
  static const String uploadVideo = 'assets/images/icons/upload.png';
  static const String edit = 'assets/images/icons/edit.png';
  static const String link = 'assets/images/icons/link.png';
  static const String upload = 'assets/images/icons/upload_ios.png';
  static const String pdf = 'assets/images/icons/pdf.png';
  static const String image = 'assets/images/icons/image.png';
  static const String epub = 'assets/images/icons/epub.png';
  static const String doc = 'assets/images/icons/doc.png';
  static const String audio = 'assets/images/icons/audio.png';
  static const String quiz = 'assets/images/icons/quiz.png';
  static const String question = 'assets/images/icons/question.png';
  static const String timer = 'assets/images/icons/timer.png';
  static const String dropdown = 'assets/images/icons/drop_down.png';
  static const String scoreBack = 'assets/images/icons/score_back.png';
  static const String correct = 'assets/images/icons/correct.png';
  static const String wrong = 'assets/images/icons/wrong.png';
  static const String skipped = 'assets/images/icons/skipped.png';
  static const String videoPlay = 'assets/images/icons/video_play.jpeg';

  static const Set<String> imageTypes = {"png", "jpg", "jpeg"};

  static String getFileTypeIcon(String type, {String? path}) {
    if (imageTypes.contains(type.toLowerCase())) return image;

    switch (type.toLowerCase()) {
      case "pdf":
        return pdf;
      case "doc":
      case "docx":
      case "xls":
        return doc;
      case "epub":
        return epub;
      case "mp3":
      case "mp4":
        return audio;
      case "link":
        return link;
      default:
        return path ?? doc;
    }
  }
}