part of 'chat.datasource_impl.dart';

abstract interface class ChatDataSource {}

abstract interface class LocalChatDataSource implements ChatDataSource {}

abstract interface class RemoteChatDataSource implements ChatDataSource {
  Stream<Iterable<ChatModel>> getChatStream();

  Future<void> saveChat(ChatModel model);

  Future<void> updateLastMessage(ChatMessageModel model);

  Future<void> deleteChat(ChatModel model);
}