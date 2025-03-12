//
//  ChatView.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 11/03/25.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @Environment(\.presentationMode) var presentationMode // To handle back navigation
    @State private var didSentMessage = true
    let themeConfig: ConfigJson
    
    let imageChatMessage = ChatMessageModel(id: UUID(),
                                            text: "Let me know if you need further improvements! in image",
                                            mediaURL: URL(string: "https://fastly.picsum.photos/id/526/600/800.jpg?hmac=Kwx76AhyfCTBwZ3nMAONgOGFfTfnOE-Fzljedz3Z8Do"),
                                            thumbnailURL: URL(string: "https://picsum.photos/200/300"),
                                            type: .image,
                                            timestamp: Date(),
                                            isSentByUser: false,
                                            duration: nil)
    
    let anotherImageChatMessage = ChatMessageModel(id: UUID(),
                                                   text: "Let me know if you need further improvements! in image",
                                                   mediaURL: URL(string: "https://fastly.picsum.photos/id/1/200/300.jpg?hmac=jH5bDkLr6Tgy3oAg5khKCHeunZMHq0ehBZr6vGifPLY"),
                                                   thumbnailURL: URL(string: "https://picsum.photos/200/300"),
                                                   type: .image,
                                                   timestamp: Date(),
                                                   isSentByUser: false,
                                                   duration: nil)
    
    let landscapeImageImageChatMessage = ChatMessageModel(id: UUID(),
                                                          text: "Let me know if you need further improvements! in image",
                                                          mediaURL: URL(string: "https://fastly.picsum.photos/id/548/400/150.jpg?hmac=jH_DNdOjLQ79pMezq23AS8J0WJzVtOAgfZBARCG6bPo"),
                                                          thumbnailURL: URL(string: "https://picsum.photos/200/300"),
                                                          type: .image,
                                                          timestamp: Date(),
                                                          isSentByUser: false,
                                                          duration: nil)
    
    let videoChatMessage = ChatMessageModel(id: UUID(),
                                            text: "Let me know if you need further improvements! in Video",
                                            mediaURL: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
                                            thumbnailURL: URL(string: "https://picsum.photos/200/300"),
                                            type: .video,
                                            timestamp: Date(),
                                            isSentByUser: false,
                                            duration: nil)
    
    let receivedTextChatMessage = ChatMessageModel(id: UUID(),
                                                   text: "Hi",
                                                   mediaURL: nil,
                                                   thumbnailURL: nil,
                                                   type: .text,
                                                   timestamp: Date(),
                                                   isSentByUser: false,
                                                   duration: nil)
    
    let sentTextChatMessage = ChatMessageModel(id: UUID(),
                                               text: "Hi",
                                               mediaURL: nil,
                                               thumbnailURL: nil,
                                               type: .text,
                                               timestamp: Date(),
                                               isSentByUser: true,
                                               duration: nil)
    
    let sentLongTextChatMessage = ChatMessageModel(id: UUID(),
                                                   text: "Let me know if you need further improvements! in image further improvements! in image further improvements! in image",
                                                   mediaURL: nil,
                                                   thumbnailURL: nil,
                                                   type: .text,
                                                   timestamp: Date(),
                                                   isSentByUser: true,
                                                   duration: nil)
    
    var body: some View {
        VStack {
            ChatHeaderView(assistantImage: UserDefaults.standard.string(forKey: "keyAssistantImage")!,
                           assistantName: UserDefaults.standard.string(forKey: "keyAssistantName")!,
                           onBackButtonTapped: {
                viewModel.socketConfig(didConnect: false)
                self.presentationMode.wrappedValue.dismiss()},
                           headerTheme: themeConfig.themes)
            
            ChatListView(messages: viewModel.messages /*[landscapeImageImageChatMessage, receivedTextChatMessage, anotherImageChatMessage, sentTextChatMessage, imageChatMessage, sentLongTextChatMessage, videoChatMessage]*/,
                         lastMessageID: $viewModel.lastMessageID,
                         isTyping: $viewModel.isTyping,
                         didSentMessage: $didSentMessage,
                         messageTheme: themeConfig.themes.light.chat)
            
            ChatInputView(viewModel: viewModel, inputBoxTheme: themeConfig.themes)
        }
        .navigationBarHidden(true)
        .padding()
        .background(Color(hex: themeConfig.themes.light.chat.backgroundColor))
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear {
            viewModel.socketConfig(didConnect: true)
        }
    }
}

//#Preview {
//    ChatView(themeConfig: AssistantConfig())
//}
