import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:my_app/core/exception/failure.dart';

abstract interface class AuthRepository {
  User? get currentUser;

  Stream<User?> get authStream;

  Future<Either<Failure, User>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();
}
