import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/core/dependency_injection/dependency_injection.dart';
import 'package:my_app/core/util/time.util.dart';
import 'package:my_app/core/util/toast.util.dart';
import 'package:my_app/data/entity/chat/open_chat/open_chat.entity.dart';
import 'package:my_app/data/entity/user/presence.entity.dart';
import 'package:my_app/presentation/bloc/chat/chat.bloc.dart';
import 'package:my_app/presentation/bloc/chat/open_chat_message/display/display_open_chat_message.bloc.dart';
import 'package:my_app/presentation/bloc/chat/open_chat_message/create/send_open_chat_message.cubit.dart';
import 'package:my_app/presentation/bloc/chat/open_chat_message/create/send_open_chat_message.state.dart';
import 'package:my_app/presentation/bloc/user/user.bloc.dart';
import 'package:my_app/presentation/components/user/avatar.widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../../core/constant/status.dart';
import '../../../../../../data/entity/chat/chat_message/open_chat_message.entity.dart';

part 'open_chat_room.screen.dart';

part 'open_chat_text_field.widget.dart';

part 'open_chat_message_item.widget.dart';

part 'presences.fragment.dart';

class OpenChatRoomPage extends StatelessWidget {
  const OpenChatRoomPage(this._chat, {super.key});

  final OpenChatEntity _chat;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => getIt<ChatBloc>().displayOpenChatMessage(_chat)),
        BlocProvider(
            create: (_) => getIt<ChatBloc>().sendOpenChatMessage(_chat)),
      ],
      child: OpenChatRoomScreen(_chat),
    );
  }
}
