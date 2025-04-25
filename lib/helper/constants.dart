class Constants {
  static const String productionBaseUrl = "http://10.0.2.2:3000/api/";
  static const String developmentBaseUrl = "http://10.0.2.2:3000/api/";
  static const String batch = "batch";
  static const String announcement = 'announcement';
  static const String assignment = 'assignment';
  static const String login = 'login';
  static const String profile = 'profile';
  static const String googleAuth = 'auth/google';
  static const String register = 'register';
  static const String forgotPassword = 'auth/reset-password';
  static const String verifyOtp = 'verify-otp';
  static const String poll = 'poll';
  static const String video = 'video';
  static const String material = 'material';
  static const String subjects = 'subjects';
  static const String student = 'student';
  static const String getAllStudentList = "get-all-student-list";
  static const String studentNotificationList = "student/my-notifications";
  static const String studentNotificationUnreadCount = "student/notifications/unread-count";
  static const String studentMarkAllNotificationsAsRead = "student/notifications/read-all";

  static const String defaultUploadEndpoint = 'upload'; // Add this line


  static const String studentBatch = "$student/my-batches";
  static const String studentAnnouncements = "$student/my-announcements";
  static const String studentPolls = "$student/my-polls";

  static getMyBatches(bool isStudent) {
    return isStudent ? studentBatch : Constants.batch;
  }

  static String getBatchDetails(String batchId) {
    print("Constructing batch details URL for batchId: $batchId");
    final url = "$batch/$batchId";
    print("Final URL: $url");
    return url;
  }

  static String getMyAnnouncement(bool isStudent) {
    return isStudent ? studentAnnouncements : announcement;
  }

  static String getMyBatchDetailTimeLine(bool isStudent, String batchId) {
    return isStudent
        ? "$student/$batch/$batchId/timeline"
        : "$batch/$batchId/timeline";
  }

  static String getBatchMaterialList(String batchId) {
    return "$batch/$batchId/$material";
  }

  static String getBatchVideoList(String batchId) {
    return "$batch/$batchId/$video";
  }

  static String getBatchAnnouncementList(String batchId) {
    return "$batch/$batchId/$announcement";
  }

  static String uploadDocInAnnouncement(String announcementId) {
    return "$announcement/$announcementId/doc/upload";
  }

  static String uploadImageInAnnouncement(String announcementId) {
    return "$announcement/$announcementId/upload";
  }

  static String getBatchAssignmentList(String batchId, bool isStudent) {
    return isStudent
        ? "student/$batch/$batchId/$assignment"
        : "$batch/$batchId/$assignment";
  }

  static String getBatchAssignmentDetail(
      String batchId, String assignmentId, bool isStudent) {
    return isStudent
        ? "$student/$batch/$batchId/$assignment/$assignmentId"
        : "$batch/$batchId/$assignment/$assignmentId";
  }

  static String castStudentVoteOnPoll(String pollId) {
    return "student/poll/$pollId/vote";
  }

  static String editBatchDetail(String batchId) {
    return "$batch/$batchId";
  }

  static String deleteBatch(String batchId) {
    return "$batch/$batchId";
  }

  static String crudePoll(String pollId) {
    return "$poll/$pollId";
  }

  static String crudVideo(String id) {
    return "$video/$id";
  }

  static String crudAnnouncement(String id) {
    return "$announcement/$id";
  }

  static String crudMaterial(String id) {
    return "$material/$id";
  }

  static String uploadMaterialFile(String id) {
    return "$material/$id/upload";
  }

  static String crudAssignment(String id) {
    return "$assignment/$id";
  }

  static String deleteAnnouncement(String announcementId) {
    return "$announcement/$announcementId";
  }

  // Add these methods for notification endpoints
  static String markNotificationAsRead(String notificationId) {
    return "student/notifications/$notificationId/read";
  }
  
  // Chat related constants
  static const String chat = "chat";
  static const String conversation = "conversation";
  static const String message = "message";
  static const String messages = "messages";
  
  // Chat endpoint methods
  static String createConversation() {
    return "$chat/$conversation";
  }
  
  static String listConversations() {
    return "$chat/conversations";
  }
  
  static String getConversationMessages(String conversationId) {
    return "$chat/$conversation/$conversationId/$messages";
  }
  
  static String sendMessage(String conversationId) {
    return "$chat/$conversation/$conversationId/$message";
  }
  
  // Direct message endpoints
  static String createMessage() {
    return "$message";
  }
  
  static String getMessage(String messageId) {
    return "$message/$messageId";
  }
  
  static String updateMessage(String messageId) {
    return "$message/$messageId";
  }
  
  static String deleteMessage(String messageId) {
    return "$message/$messageId";
  }
}