//
//  ChatListView.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 11/03/25.
//

import SwiftUI

struct ChatListView: View {
    var messages: [ChatMessageModel]
    @Binding var lastMessageID: UUID?
    @Binding var isTyping: Bool  // Bind Typing Indicator
    @Binding var didSentMessage: Bool
    let messageTheme: ChatTheme
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(messages) { message in
                        ChatBubbleView(message: message,
                                       cornerRadius: 12,
                                       assistantName: UserDefaults.standard.string(forKey: "keyAssistantName")!,
                                       didSentMessage: $didSentMessage,
                                       messageTheme: messageTheme)
                            .id(message.id)
                    }
                    
                    // Typing Indicator for Assistant
                    if isTyping {
                        HStack {
                            TypingIndicatorViews()
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .id("TypingIndicator")  // Give it a unique ID
                    }
                }
            }
            .onAppear {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: lastMessageID) { _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            if let lastID = lastMessageID {
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo(lastID, anchor: .bottom)
                }
            } else if isTyping {
                // Scroll to Typing Indicator when it's visible
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo("TypingIndicator", anchor: .bottom)
                }
            }
        }
    }
}
