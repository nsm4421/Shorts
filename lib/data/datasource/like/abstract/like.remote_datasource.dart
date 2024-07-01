part of '../impl/like.remote_datasource_impl.dart';

abstract interface class RemoteLikeDataSource {
  Stream<Iterable<String>> get likeOnFeedStream;

  Future<void> saveLike(SaveLikeRequestDto dto);

  Future<void> deleteLike(DeleteLikeRequestDto dto);

  Future<void> deleteLikeById(String likeId);
}
