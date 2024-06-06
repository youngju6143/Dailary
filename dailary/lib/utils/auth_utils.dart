String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '사용자 이름을 입력해주세요.';
    }
    final RegExp nameExp = RegExp(r'^[a-zA-Z가-힣]{2,6}$');
    if (!nameExp.hasMatch(value)) {
      return '영문/한글로 2-6자만 입력 가능합니다.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    final RegExp passwordExp = RegExp(r'^(?=.*[!@#\$&*~]).{6,}$');
    if (!passwordExp.hasMatch(value)) {
      return '영문/특수문자 포함 6자 이상 입력 가능합니다.';
    }
    return null;
  }
