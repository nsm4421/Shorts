import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_app/domain/usecase/module/like/like.usecase.dart';

import '../../../../core/exception/custom_exception.dart';
import '../../../../data/entity/feed/base/feed.entity.dart';
import '../../../../domain/usecase/module/feed/feed.usecase.dart';

part 'display_feed.event.dart';

part 'display_feed.state.dart';

class DisplayFeedBloc extends Bloc<DisplayFeedEvent, DisplayFeedState> {
  final FeedUseCase _feedUseCase;
  final LikeUseCase _likeUseCase;

  DateTime _beforeAt = DateTime.now();
  int _page = 0;
  bool _isEnd = false;
  static const int _pageSize = 10;
  late Stream<Iterable<String>> _likeStream;

  DisplayFeedBloc(
      {required FeedUseCase feedUseCase, required LikeUseCase likeUseCase})
      : _feedUseCase = feedUseCase,
        _likeUseCase = likeUseCase,
        super(InitialDisplayFeedState()) {
    _likeStream = _likeUseCase.likeOnFeedStream();
    on<InitDisplayFeedEvent>(_onInit);
    on<FetchDisplayFeedEvent>(_onFetch);
    on<DeleteDisplayFeedEvent>(_onDelete);
    on<LikeOnFeedEvent>(_onLike);
  }

  bool get isEnd => _isEnd;

  Stream<Iterable<String>> get likeStream => _likeStream;

  Future<void> _onInit(
      InitDisplayFeedEvent event, Emitter<DisplayFeedState> emit) async {
    try {
      _beforeAt = DateTime.now();
      _page = 0;
      _isEnd = false;
      emit(InitialDisplayFeedState());
    } catch (error) {
      log(error.toString());
      emit(DisplayFeedFailureState(
          (error is CustomException) ? error.message : '알 수 없는 오류 발생'));
    }
  }

  Future<void> _onFetch(
      FetchDisplayFeedEvent event, Emitter<DisplayFeedState> emit) async {
    try {
      if (_isEnd) {
        emit(FeedFetchedState(fetched: const [], isEnd: true));
        return;
      } else {
        emit(DisplayFeedLoadingState());
        _page += 1;
        final from = (_page - 1) * _pageSize;
        final to = _page * _pageSize - 1;
        final res = await _feedUseCase.fetchFeeds(
            beforeAt: _beforeAt, from: from, to: to);
        res.fold((l) => throw l.toCustomException(message: '피드 목록 조회 실패'), (r) {
          _isEnd = r.length < _pageSize;
          emit(FeedFetchedState(fetched: r, isEnd: true));
        });
      }
    } catch (error) {
      log(error.toString());
      emit(DisplayFeedFailureState(
          (error is CustomException) ? error.message : '알 수 없는 오류 발생'));
    }
  }

  Future<void> _onDelete(
      DeleteDisplayFeedEvent event, Emitter<DisplayFeedState> emit) async {
    try {
      emit(DisplayFeedLoadingState());
      await _feedUseCase.delete(event.feed).then((res) => res.fold(
          (l) => l.toCustomException(message: '피드 삭제 실패'),
          (r) => emit(DisplayFeedSuccessState())));
    } catch (error) {
      log(error.toString());
      emit(DisplayFeedFailureState(
          (error is CustomException) ? error.message : '알 수 없는 오류 발생'));
    }
  }

  Future<void> _onLike(
      LikeOnFeedEvent event, Emitter<DisplayFeedState> emit) async {
    try {
      if (event is SendLikeOnFeedEvent) {
        await _likeUseCase.sendLikeOnFeed(event.feed.id!);
      } else if (event is DeleteLikeOnFeedEvent) {
        await _likeUseCase.cancelLikeOnFeed(event.feed.id!);
      } else {
        throw ArgumentError('Invalid Args');
      }
    } catch (error) {
      log(error.toString());
      emit(DisplayFeedFailureState(
          (error is CustomException) ? error.message : '알 수 없는 오류 발생'));
    }
  }
}
