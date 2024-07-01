part of 'feed.page.dart';

enum _PopUpMenu {
  report(label: '신고하기', iconData: Icons.report_gmailerrorred),
  delete(label: '삭제하기', iconData: Icons.delete_outline_outlined),
  modify(label: '수정하기', iconData: Icons.edit);

  final String label;
  final IconData iconData;

  const _PopUpMenu({required this.label, required this.iconData});
}

class FeedItemWidget extends StatefulWidget {
  const FeedItemWidget(this._feed, {super.key});

  final FeedEntity _feed;

  @override
  State<FeedItemWidget> createState() => _FeedItemWidgetState();
}

class _FeedItemWidgetState extends State<FeedItemWidget> {
  late StreamSubscription<Iterable<String>> _subscription;
  late AccountEntity _currentUser;
  late List<_PopUpMenu> _menus;

  bool _isLike = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _currentUser = (context.read<UserBloc>().state as UserLoadedState).account;
    _menus = [
      _PopUpMenu.report,
      if (_currentUser.id == widget._feed.author?.id) ...[
        _PopUpMenu.delete,
        _PopUpMenu.modify
      ]
    ];
    _subscription = context.read<DisplayFeedBloc>().likeStream.listen((event) {
      setState(() {
        _isLike = event.contains(widget._feed.id);
      });
    });
  }

  @override
  dispose() {
    super.dispose();
    _subscription.cancel();
  }

  _handleClickMoreButton(_PopUpMenu menu) {
    switch (menu) {
      // TODO : 신고하기 / 수정하기 기능 구현하기
      case _PopUpMenu.report:
      case _PopUpMenu.modify:
        return;
      case _PopUpMenu.delete:
        context
            .read<DisplayFeedBloc>()
            .add(DeleteDisplayFeedEvent(widget._feed));
        setState(() {
          _disposed = true;
        });
        return;
    }
  }

  _handleClickFavorite() {
    try {
      context.read<DisplayFeedBloc>().add(_isLike
          ? DeleteLikeOnFeedEvent(widget._feed)
          : SendLikeOnFeedEvent(widget._feed));
    } catch (error) {
      log(error.toString());
    }
  }

  _handleClickComment() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: FeedCommentPage(widget._feed)));
  }

  _handleClickShare() {}

  @override
  Widget build(BuildContext context) {
    return _disposed
        ? const SizedBox()
        : Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      // 프로필 사진
                      AvatarWidget(widget._feed.author!.profileUrl!),
                      const SizedBox(width: 8),

                      // 닉네임
                      Text(widget._feed.author?.nickname ?? 'Unknown'),
                      const Spacer(),

                      // 더보기 버튼
                      PopupMenuButton<_PopUpMenu>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: _handleClickMoreButton,
                          itemBuilder: (context) => _menus
                              .map((menu) => PopupMenuItem<_PopUpMenu>(
                                    value: menu,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(menu.iconData, size: 15),
                                        const SizedBox(width: 5),
                                        Text(menu.label),
                                      ],
                                    ),
                                  ))
                              .toList())
                    ]),

                    // Image
                    if (widget._feed.type == MediaType.image &&
                        widget._feed.media != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child:
                              CachedNetworkImage(imageUrl: widget._feed.media!),
                        ),
                      ),

                    // Video
                    if (widget._feed.type == MediaType.video &&
                        widget._feed.media != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: VideoPreviewItemWidget(widget._feed.media!),
                        ),
                      ),

                    // 본문
                    if (widget._feed.content != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        child: Text(widget._feed.content ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                      ),

                    // 해시태그
                    if (widget._feed.hashtags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        child: Wrap(
                          children: widget._feed.hashtags
                              .map((text) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.tag, size: 20),
                                      const SizedBox(width: 5),
                                      Text(text,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSecondaryContainer)),
                                    ],
                                  )))
                              .toList(),
                        ),
                      ),

                    // 아이콘 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: IconButton(
                              onPressed: _handleClickFavorite,
                              icon: _isLike
                                  ? Icon(Icons.favorite,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer)
                                  : Icon(Icons.favorite_border,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiaryContainer)),
                        ),
                        // 댓글버튼
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: IconButton(
                              onPressed: _handleClickComment,
                              icon: const Icon(Icons.mode_comment_outlined)),
                        ),
                        // 공유하기 버튼
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: IconButton(
                              onPressed: _handleClickShare,
                              icon: const Icon(Icons.share_rounded)),
                        )
                      ],
                    )
                  ],
                ),
              ),

              // Separator
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Divider(),
              )
            ],
          );
  }
}
