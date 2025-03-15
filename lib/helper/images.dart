class Images {
  static const String logo = 'assets/logo/pensilLogo.png';
  static const String logoText = 'assets/logo_text.png';
  static const String back = 'assets/icons/back.png';
  static const String cross = 'assets/icons/cross.png';
  static const String announcements = 'assets/icons/announcement.png';
  static const String megaphone = 'assets/icons/megaphone.png';
  static const String peopleWhite = 'assets/icons/people_white.png';
  static const String peopleBlack = 'assets/icons/people_black.png';
  static const String calender = 'assets/icons/calender.png';
  static const String uploadVideo = 'assets/icons/upload.png';
  static const String edit = 'assets/icons/edit.png';
  static const String link = 'assets/icons/link.png';
  static const String upload = 'assets/icons/upload_ios.png';
  static const String pdf = 'assets/icons/pdf.png';
  static const String image = 'assets/icons/image.png';
  static const String epub = 'assets/icons/epub.png';
  static const String doc = 'assets/icons/doc.png';
  static const String audio = 'assets/icons/audio.png';
  static const String quiz = 'assets/icons/quiz.png';
  static const String question = 'assets/icons/question.png';
  static const String timer = 'assets/icons/timer.png';
  static const String dropdown = 'assets/icons/drop_down.png';
  static const String scoreBack = 'assets/icons/score_back.png';
  static const String correct = 'assets/icons/correct.png';
  static const String wrong = 'assets/icons/wrong.png';
  static const String skipped = 'assets/icons/skipped.png';
  static const String videoPlay = 'assets/icons/video_play.jpeg';

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