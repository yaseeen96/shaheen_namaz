import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final userAuthProvider =
    StreamProvider<User?>((ref) => FirebaseAuth.instance.userChanges());
