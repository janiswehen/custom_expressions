abstract class Expression {
  String token;

  Expression({required this.token});

  Expression copyWithToken({String? token});
}
