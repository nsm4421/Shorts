part of 'open_chat_message.datasource_impl.dart';

abstract interface class OpenChatMessageDataSource {}

abstract interface class LocalOpenChatMessageDataSource
    implements OpenChatMessageDataSource {}

abstract interface class RemoteOpenChatMessageDataSource
    implements OpenChatMessageDataSource {
  RealtimeChannel getMessageChannel(
      {required String chatId,
      required void Function(PostgresChangePayload) onInsert});

  Future<void> saveChatMessage(OpenChatMessageModel model);

  Future<void> deleteMessageById(String messageId);
}
