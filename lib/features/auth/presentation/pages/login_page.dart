import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tdddemo/features/auth/domain/usecases/login_usecase.dart';
import 'package:tdddemo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:tdddemo/features/auth/presentation/widgets/login_widget.dart';
import 'package:tdddemo/injection_container.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AuthBloc(
          loginUseCase: sl<LoginUseCase>(),
        ),
        child: Stack(
          children: [
            // Background SVG
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: SvgPicture.asset(
                  'assets/images/wave.svg', // You'll need to add this asset
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const LoginForm(),
          ],
        ),
      ),
    );
  }
}