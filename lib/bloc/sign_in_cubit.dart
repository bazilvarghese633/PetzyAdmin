import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInState {
  final bool isLoading;
  final String? error;

  SignInState({this.isLoading = false, this.error});

  SignInState copyWith({bool? isLoading, String? error}) {
    return SignInState(isLoading: isLoading ?? this.isLoading, error: error);
  }
}

class SignInCubit extends Cubit<SignInState> {
  SignInCubit() : super(SignInState());

  Future<void> signIn(String email, String password) async {
    emit(SignInState(isLoading: true, error: null));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      emit(SignInState(isLoading: false, error: null));
    } on FirebaseAuthException catch (e) {
      emit(SignInState(isLoading: false, error: e.message));
    }
  }
}
