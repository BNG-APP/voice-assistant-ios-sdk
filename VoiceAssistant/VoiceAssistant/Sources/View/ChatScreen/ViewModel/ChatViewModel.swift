//
//  ChatViewModel.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 11/03/25.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessageModel] = []
    private var cancellables = Set<AnyCancellable>()
    
    @Published var lastMessageID: UUID?
    @Published var isTyping: Bool = false
    @Published var didSentMessage: Bool = false // TODO: Need backend handeling for status sent.
    
    let socketManager = SocketService.shared
    var currentMessageChunk: String = ""
    
    /// Provide didConnect to true for connecting socket
    func socketConfig(didConnect: Bool) {
        if didConnect {
            socketManager.connect()
            print("Chat socket connection started")
            
            socketConnectionState()
            // Start listening for incoming messages after socket connects
            receiveMessage()
        } else {
            socketManager.disconnect()
            print("Chat Socket DISCONNECTED")
        }
    }
    
    private func socketConnectionState() {
        socketManager.$isConnected
            .sink { [weak self] isConnected in
                if isConnected {
                    self?.isTyping = true
                } else {
                    // TODO: Show error
                }
            }
            .store(in: &cancellables)
    }
    
    func sendMessage(_ message: ChatMessageModel) {
        if let text = message.text {
            DispatchQueue.main.async {
                self.messages.append(message)
                self.lastMessageID = message.id  // Scroll to last message
            }
            socketManager.sendCustomEvent(of: .chat,
                                          with: text,
                                          at: Int64(Date().timeIntervalSince1970 * 1000)) { success in
                if success {
                    // Message sent
                    self.didSentMessage = true
                } else {
                    // Message sent error
                    self.didSentMessage = false
                }
            }
        }
        
        // Show Typing Indicator After Sending a Message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isTyping = true
        }
    }

    func receiveMessage() {
        socketManager.callMessagePublisher
            .sink { [weak self] message in
                guard let self = self else { return }
                
                if !message.chunk.isEmpty {
                    self.currentMessageChunk += message.chunk + " "
                }
                
                if message.isEndChunk {
                    DispatchQueue.main.async {
                        let newMessage = ChatMessageModel(
                            id: UUID(),
                            text: self.currentMessageChunk,
                            mediaURL: nil,
                            thumbnailURL: nil,
                            type: .text,
                            timestamp: Date(),
                            isSentByUser: false,
                            duration: nil
                        )
                        
                        print("Received message: \(self.currentMessageChunk)")
                        
                        // Delay message reception for testing scroll behavior
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.isTyping = false  // Hide Typing Indicator
                            self.messages.append(newMessage)
                            self.lastMessageID = newMessage.id  // Scroll to last message
                            self.currentMessageChunk = ""
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }

    // Helper method to get current time
    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: Date())
    }
}
