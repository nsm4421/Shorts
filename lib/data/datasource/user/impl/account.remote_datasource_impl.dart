import 'dart:io';

import 'package:logger/logger.dart';
import 'package:my_app/core/constant/database.constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/exception/custom_exception.dart';
import '../../../../domain/model/user/account.dto.dart';

part '../abstract/account.remote_datasource.dart';

class RemoteAccountDataSourceImpl implements RemoteAccountDataSource {
  final SupabaseClient _client;
  final Logger _logger;

  RemoteAccountDataSourceImpl(
      {required SupabaseClient client, required Logger logger})
      : _client = client,
        _logger = logger;

  @override
  Future<AccountDto> getCurrentUser() async {
    return await findByUserId(_getCurrentUidOrElseThrow);
  }

  @override
  Future<AccountDto> findByUserId(String userId) async {
    try {
      final fetched = await _client.rest
          .from(TableName.user.name)
          .select("*")
          .eq('id', userId)
          .limit(1);
      if (fetched.isEmpty) {
        throw const PostgrestException(message: 'user not found from database');
      } else {
        return AccountDto.fromJson(fetched[0]);
      }
    } catch (error) {
      throw CustomException.from(error, logger: _logger);
    }
  }

  @override
  Future<void> upsertUser(AccountDto user) async {
    try {
      await _client.rest.from(TableName.user.name).upsert(user.toJson());
    } catch (error) {
      throw CustomException.from(error, logger: _logger);
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      await _client.rest
          .from(TableName.user.name)
          .delete()
          .eq("id", _getCurrentUidOrElseThrow);
    } catch (error) {
      throw CustomException.from(error, logger: _logger);
    }
  }

  @override
  Future<bool> isDuplicatedNickname(String nickname) async {
    try {
      final count = await _client.rest
          .from(TableName.user.name)
          .count()
          .eq("id", _getCurrentUidOrElseThrow)
          .limit(1);
      return count > 0;
    } catch (error) {
      throw CustomException.from(error, logger: _logger);
    }
  }

  @override
  String get profileImageUrl {
    try {
      return _client.storage
          .from(BucketName.user.name)
          .getPublicUrl(_profileImagePath);
    } catch (error) {
      throw CustomException.from(error, logger: _logger);
    }
  }

  @override
  Future<void> saveProfileImage(File image) async {
    try {
      await _client.storage.from(BucketName.user.name).upload(
          _profileImagePath, image,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true));
    } catch (error) {
      throw CustomException.from(error, logger: _logger);
    }
  }

  // 프로필 이미지 저장 경로
  String get _profileImagePath =>
      '$_getCurrentUidOrElseThrow/profile_image.jpg';

  // 현재 로그인 유저의 id
  String get _getCurrentUidOrElseThrow {
    final currentUid = _client.auth.currentUser?.id;
    if (currentUid == null) {
      throw const AuthException('NOT LOGIN');
    }
    return currentUid;
  }
}
