enum OtpType {
  register, //Đăng ký tài khoản
  changePassword, //Quên mật khẩu
  updatePassword //Đổi mật khẩu
}

enum Role {
  student,
  teacher,
}

class OtpArgument {
  final OtpType otpType;
  final String? email;
  final String? password;
  final String? fullname;
  final Role? role;
  final String? major;

  OtpArgument({required this.otpType,required this.role, this.email, this.major, this.password, this.fullname});
}
