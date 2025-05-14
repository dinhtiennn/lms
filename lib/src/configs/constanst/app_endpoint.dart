class AppEndpoint {
  AppEndpoint._();

  static const String baseUrl = "http://192.168.113.36:8080";

  static const String baseWebsocket = 'http://192.168.113.36:8080/lms/ws';

  static const String baseImageUrl = "http://192.168.113.36:8080";
  //
  // static const String baseUrl = "http://192.168.1.26:8080";
  //
  // static const String baseWebsocket = 'http://192.168.1.26:8080/lms/ws';
  //
  // static const String baseImageUrl = "http://192.168.1.26:8080";
  //
  // static const String baseUrl = "http://192.168.1.11:8080";
  //
  // static const String baseWebsocket = 'http://192.168.1.11:8080/lms/ws';
  //
  // static const String baseImageUrl = "http://192.168.1.11:8080";

  static const int connectionTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const String keyAuthorization = "Authorization";

  static const int success = 200;
  static const int errorToken = 401;
  static const int errorValidate = 422;
  static const int errorSever = 500;
  static const int errorDisconnect = -1;

  static const String TOKEN = '/lms/auth/token';
  static const String REFRESH = '/lms/auth/refresh';
  static const String LOGOUT = '/lms/auth/logout';
  static const String REFRESHPASSWORD = '/lms/email/forgotpassword';
  static const String NOTIFICATION = '/lms/notifications';

  //api email
  static const String SEND = '/lms/email/send';
  static const String VERIFYCODE = '/lms/email/verifycode';

  //api major
  static const String MAJOR = '/lms/major';

  //api student
  static const String MYINFO = '/lms/student/myinfo';
  static const String UPDATEAVATAR = '/lms/student/id/upload-photo';
  static const String CHANGERPASSWORD = '/lms/account/changePassword';
  static const String REGISTER = '/lms/student/create';
  static const String SEARCHSTUDENT = '/lms/student/search';
  static const String SEARCHSTUDENTNOTIN = '/lms/studentcourse/searchstudentnotin';
  static const String TESTSTUDENTDETAIL = '/lms/teststudentresult/gettestdetail';
  static const String STARTTEST = '/lms/teststudentresult/starttest';
  static const String SUBMITTEST = '/lms/teststudentresult/submitTest';

  //api course
  static const String CREATECOURSE = '/lms/course/create';
  static const String UPDATECOURSE = '/lms/course/update';
  static const String UPLOADIMAGE = '/lms/course/{id}/upload-photo';
  static const String MYCOURSE = '/lms/studentcourse/mycourse';
  static const String PUBLICCOURSE = '/lms/course';
  static const String SEARCHCOURSE = '/lms/course/search';
  static const String COURSEOFMAJORFIRST = '/lms/course/courseofmajorfirst';
  static const String COURSEDETAIL = '/lms/course/{id}';
  static const String PROGRESSLESSON = '/lms/lessonprogress/getprogress/{id}';
  static const String PROGRESSCHAPTER = '/lms/lessonchapterprogress/getprogress/{id}';
  static const String SAVEPROGRESSCHAPTER = '/lms/lessonchapterprogress/savechapterprogress/{id}';
  static const String COMPELTEPROGRESSCHAPTER = '/lms/lessonchapterprogress/completechapter/{id}';
  static const String SAVEPROGRESSLESSON = '/lms/lessonprogress/savelessonprogress/{id}';
  static const String COMPELTEPROGRESSLESSON = '/lms/lessonprogress/completelesson/{id}';
  static const String LISTREQUEST = '/lms/joinclass/courserequest';
  static const String LISTREQUESTTOCOURSE = '/lms/joinclass/studentrequest';
  static const String JOINCOURSE = '/lms/joinclass/pending';
  static const String CREATELESSON = '/lms/lesson/create';
  static const String ADDMATERIAL = '/lms/lessonmaterial/create';
  static const String ADDCHAPTER = '/lms/chapter/create';
  static const String CREATEQUIZ = '/lms/lessonquiz/{id}/create';
  static const String STUDENTSOFCOURSE = '/lms/studentcourse/studentofcourse';
  static const String DELETESTUDENTOFCOURSE = '/lms/studentcourse/delete';
  static const String ADDSTUDENT = '/lms/studentcourse/addstudents';
  static const String APPROVEDREQUEST = '/lms/joinclass/approved';
  static const String REJECTEDREQUEST = '/lms/joinclass/rejected';
  static const String STATUSJOIN = '/lms/joinclass/getstatus';

  //api comment
  static const String COMMENTS = '/lms/comments/unreadCommentsOfChapter/details';
  static const String REPLIES = '/lms/comments/unreadCommentsOfChapter/details/reply';

  //api teacher
  static const String PROFILETEACHER = '/lms/teacher/myinfo';
  static const String MYCOURSESBYTEACHER = '/lms/course/courseofteacher';
  static const String UPDATEAVATARTEACHER = '/lms/teacher/id/upload-photo';
  static const String REGISTERTEACHER = '/lms/teacher/create';


  //api group
  static const String CREATEGROUP = '/lms/group/create';
  static const String UPDATEGROUP = '/lms/group/update';
  static const String GROUPOFTEACHER = '/lms/group/groupofteacher';
  static const String CREATEPOST = '/lms/post/create';
  static const String CREATETEST = '/lms/testingroup/create';
  static const String POSTS = '/lms/post';
  static const String DELETEPOST = '/lms/post/delete';
  static const String TESTS = '/lms/testingroup/getalltest';
  static const String STUDENTSINGROUP = '/lms/studentgroup/getstudent';
  static const String TESTDETAIL = '/lms/testingroup/testdetails';
  static const String ALLTESTRESULT = '/lms/teststudentresult/getallresult';
  static const String TESTRESULTDETAIL = '/lms/teststudentresult/gettestresult';
  static const String STUDENTNOTINGROUP = '/lms/student/searchnotingroup';
  static const String ADDSTUDENTTOGROUP = '/lms/studentgroup/addstudent';
  static const String DELETESTUDENTOFGROUP = '/lms/studentgroup/delete';
  static const String GROUPSOFSTUDENT = '/lms/studentgroup/getgroup';
}
