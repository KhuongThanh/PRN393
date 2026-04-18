import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color qBlue = Color(0xFF4255FF);
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);

  int step = 1;
  String selectedRole = 'r1';
  int goal = 10;
  bool loading = false;
  String? focusedKey;

  final Map<String, String> dob = {
    'm': '',
    'd': '',
    'y': '',
  };

  final TextEditingController emailController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode monthFocus = FocusNode();
  final FocusNode dayFocus = FocusNode();
  final FocusNode yearFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode userFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  final List<Map<String, dynamic>> roles = [
    {
      'roleId': 'r1',
      'roleName': 'Student',
      'emoji': '🎓',
      'title': 'Học sinh',
      'sub': 'Tiểu học đến THPT',
    },
    {
      'roleId': 'r2',
      'roleName': 'University',
      'emoji': '🏫',
      'title': 'Sinh viên Đại học',
      'sub': 'Cao đẳng, Đại học',
    },
    {
      'roleId': 'r3',
      'roleName': 'Teacher',
      'emoji': '👨‍🏫',
      'title': 'Giáo viên',
      'sub': 'Tạo lớp học của bạn',
    },
    {
      'roleId': 'r4',
      'roleName': 'Other',
      'emoji': '💼',
      'title': 'Đi làm / Khác',
      'sub': 'Tự học cá nhân',
    },
  ];

  final List<int> goals = [5, 10, 15, 20];

  @override
  void initState() {
    super.initState();

    _bindFocus(monthFocus, 'm');
    _bindFocus(dayFocus, 'd');
    _bindFocus(yearFocus, 'y');
    _bindFocus(emailFocus, 'email');
    _bindFocus(userFocus, 'user');
    _bindFocus(passwordFocus, 'pw');
  }

  void _bindFocus(FocusNode node, String key) {
    node.addListener(() {
      setState(() {
        focusedKey = node.hasFocus ? key : null;
      });
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    userController.dispose();
    passwordController.dispose();

    monthFocus.dispose();
    dayFocus.dispose();
    yearFocus.dispose();
    emailFocus.dispose();
    userFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  Future<void> handleNext() async {
    if (step < 3) {
      setState(() => step += 1);
      return;
    }

    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => loading = false);

    Navigator.pushReplacementNamed(context, '/home');
  }

  Map<String, dynamic> get selectedRoleData =>
      roles.firstWhere((r) => r['roleId'] == selectedRole);

  Color _borderColor(String key) {
    return focusedKey == key ? qBlue : const Color(0xFFD9DBE9);
  }

  Color _fillColor(String key) {
    return focusedKey == key
        ? const Color(0xFFF0F2FF)
        : const Color(0xFFFAFAFA);
  }

  String _goalDescription(int g) {
    if (g == 5) return 'Nhẹ nhàng';
    if (g == 10) return 'Bình thường';
    if (g == 15) return 'Chăm chỉ';
    return 'Cực đỉnh 🔥';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (step == 1) _buildStep1(),
                      if (step == 2) _buildStep2(),
                      if (step == 3) _buildStep3(),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading ? null : handleNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                loading ? const Color(0xFF9BA7FF) : qBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  step < 3 ? 'Tiếp theo' : 'Tạo tài khoản',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                      if (step == 1) ...[
                        const SizedBox(height: 12),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: qGray,
                              height: 1.6,
                            ),
                            children: [
                              TextSpan(
                                text: 'Bằng cách đăng ký, bạn đồng ý với ',
                              ),
                              TextSpan(
                                text: 'Điều khoản dịch vụ',
                                style: TextStyle(
                                  color: qBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(text: ' và '),
                              TextSpan(
                                text: 'Chính sách bảo mật',
                                style: TextStyle(
                                  color: qBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(text: ' của chúng tôi.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Đã có tài khoản?',
                              style: TextStyle(
                                fontSize: 13,
                                color: qGray,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: qBlue,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                minimumSize: const Size(0, 0),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (step > 1) {
                setState(() => step -= 1);
              } else {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 18,
                color: qDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: List.generate(3, (index) {
                final s = index + 1;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: s < 3 ? 8 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: s <= step
                          ? qBlue
                          : const Color(0xFFECEEF5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$step / 3',
            style: const TextStyle(
              fontSize: 12,
              color: qGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tạo tài khoản',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: qDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tham gia hàng triệu học sinh đang dùng Quizlet',
          style: TextStyle(
            fontSize: 13,
            color: qGray,
          ),
        ),
        const SizedBox(height: 24),
        const _FieldLabel('Ngày sinh'),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildSmallInput(
                controllerValue: dob['m']!,
                placeholder: 'Tháng',
                focusNode: monthFocus,
                fieldKey: 'm',
                maxLength: 2,
                onChanged: (value) {
                  setState(() => dob['m'] = value);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSmallInput(
                controllerValue: dob['d']!,
                placeholder: 'Ngày',
                focusNode: dayFocus,
                fieldKey: 'd',
                maxLength: 2,
                onChanged: (value) {
                  setState(() => dob['d'] = value);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _buildSmallInput(
                controllerValue: dob['y']!,
                placeholder: 'Năm',
                focusNode: yearFocus,
                fieldKey: 'y',
                maxLength: 4,
                onChanged: (value) {
                  setState(() => dob['y'] = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _FieldLabel('Địa chỉ email'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: emailController,
          focusNode: emailFocus,
          fieldKey: 'email',
          hintText: 'email@example.com',
          keyboardType: TextInputType.emailAddress,
          obscureText: false,
        ),
        const SizedBox(height: 16),
        const _FieldLabel('Tên người dùng'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: userController,
          focusNode: userFocus,
          fieldKey: 'user',
          hintText: 'tên_của_bạn',
          keyboardType: TextInputType.text,
          obscureText: false,
        ),
        const SizedBox(height: 16),
        const _FieldLabel('Mật khẩu'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: passwordController,
          focusNode: passwordFocus,
          fieldKey: 'pw',
          hintText: '6 ký tự trở lên',
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bạn là ai?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: qDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Chúng tôi sẽ tùy chỉnh trải nghiệm cho bạn',
          style: TextStyle(
            fontSize: 13,
            color: qGray,
          ),
        ),
        const SizedBox(height: 20),
        Column(
          children: roles.map((role) {
            final isSelected = selectedRole == role['roleId'];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() => selectedRole = role['roleId'] as String);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? const Color(0xFFF0F2FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? qBlue
                          : const Color(0xFFECEEF5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color.fromRGBO(66, 85, 255, 0.13)
                            : const Color.fromRGBO(46, 56, 86, 0.06),
                        blurRadius: isSelected ? 16 : 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color.fromRGBO(66, 85, 255, 0.12)
                              : const Color(0xFFF6F7FB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          role['emoji'] as String,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              role['title'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? qBlue : qDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              role['sub'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: qGray,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Role: ${role['roleName']}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? qBlue : qGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? qBlue
                              : const Color(0xFFECEEF5),
                          shape: BoxShape.circle,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 13,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đặt mục tiêu hằng ngày',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: qDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Bạn muốn học bao nhiêu từ mỗi ngày? (UserProfiles.TargetDailyWords)',
          style: TextStyle(
            fontSize: 13,
            color: qGray,
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: goals.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final g = goals[index];
            final isSelected = goal == g;

            return GestureDetector(
              onTap: () {
                setState(() => goal = g);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF0F2FF)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? qBlue : const Color(0xFFECEEF5),
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color.fromRGBO(66, 85, 255, 0.13),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$g',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? qBlue : qDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'từ / ngày',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? qBlue : qGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _goalDescription(g),
                      style: const TextStyle(
                        fontSize: 11,
                        color: qGray,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: qBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFCD1F),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '💡',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      color: qDark,
                      height: 1.6,
                    ),
                    children: [
                      const TextSpan(text: 'Học '),
                      TextSpan(
                        text: '$goal từ mỗi ngày',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' liên tục giúp bạn ghi nhớ tốt hơn học nhồi nhét một lần.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFC7CFFE),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Text(
                selectedRoleData['emoji'] as String,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vai trò đã chọn',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: qDark,
                      ),
                    ),
                    Text(
                      selectedRoleData['title'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: qBlue,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => step = 2);
                },
                style: TextButton.styleFrom(
                  foregroundColor: qBlue,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Thay đổi',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallInput({
    required String controllerValue,
    required String placeholder,
    required FocusNode focusNode,
    required String fieldKey,
    required int maxLength,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      focusNode: focusNode,
      onChanged: onChanged,
      maxLength: maxLength,
      keyboardType: TextInputType.number,
      buildCounter: (
        BuildContext context, {
        required int currentLength,
        required bool isFocused,
        required int? maxLength,
      }) {
        return null;
      },
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: const TextStyle(
          color: Color(0xFF98A1B3),
          fontSize: 14,
        ),
        filled: true,
        fillColor: _fillColor(fieldKey),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: _borderColor(fieldKey),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: qBlue,
            width: 2,
          ),
        ),
      ),
      controller: TextEditingController(text: controllerValue)
        ..selection = TextSelection.collapsed(offset: controllerValue.length),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: qDark,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String fieldKey,
    required String hintText,
    required TextInputType keyboardType,
    required bool obscureText,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF98A1B3),
          fontSize: 14,
        ),
        filled: true,
        fillColor: _fillColor(fieldKey),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: _borderColor(fieldKey),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: qBlue,
            width: 2,
          ),
        ),
      ),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: qDark,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _RegisterScreenState.qDark,
      ),
    );
  }
}