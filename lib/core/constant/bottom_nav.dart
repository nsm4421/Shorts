part of 'package:my_app/presentation/bloc/bottom_nav/bottm_nav.cubit.dart';

enum BottomNav {
  home(label: '홈', iconData: Icons.home_outlined, activeIconData: Icons.home),
  feed(label: '피드', iconData: Icons.feed_outlined, activeIconData: Icons.feed),
  chat(
      label: '채팅',
      iconData: Icons.chat_bubble_outline,
      activeIconData: Icons.chat_bubble),
  setting(
      label: '세팅',
      iconData: Icons.settings_outlined,
      activeIconData: Icons.settings);

  final String label;
  final IconData iconData;
  final IconData activeIconData;

  const BottomNav({
    required this.label,
    required this.iconData,
    required this.activeIconData,
  });
}
