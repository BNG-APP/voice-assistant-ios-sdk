//
//  SocketService.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 11/03/25.
//

import Foundation
import Combine
import SocketIO

struct CallMessage {
    let chunk: String /// transcript of the audio to display as text
    let isEndChunk: Bool /// Let us know if this is end of message
    let transcript: String /// Encoded audio file
}

enum EmitEventType: String {
    case startCall = "call_start"
    case endCall = "call_end"
    case sendMessage = "call_message"
    case utterance = "call_message_utterance"
    case keepAlive = "change_call_state"
    
    // MARK: - New Interaction methods for chat
    case startChat = "conversation_start"
    case chatMessage = "conversation_message"
    case chatEnd = "conversation_end"
}

enum ChatMode: String {
    case call = "call"
    case chat = "chat"
}

class SocketService: NSObject {

    static let shared = SocketService()

    private var manager: SocketManager!
    private var socket: SocketIOClient!
    
    let userID: String = UserDefaults.standard.string(forKey: "keyUserID")!
    private var countMessageId = 0
    
    @Published var isConnected: Bool = false
    var callMessagePublisher = PassthroughSubject<CallMessage, Never>()
    
    private override init() {
        super.init()
        
        let config: SocketIOClientConfiguration = [
//            .log(true),
            .reconnects(false),
            .connectParams(["auth_key": "Soogggoooo", "cc_id": "5"])
        ]
        manager = SocketManager(socketURL: URL(string: "https://eva-sandbox.bngrenew.com")!, config: config)
        socket = manager.defaultSocket
        
        setupHandlers()
    }

    // Setup event handlers
    private func setupHandlers() {
        
        socket.on(clientEvent: .connect) { data, ack in
            self.isConnected = true
            self.callStartEvent(interactionMode: .chat)
        }
        
        socket.on(clientEvent: .disconnect) { data, ack in
            self.isConnected = false
        }
        
        socket.on(clientEvent: .error) { data, _ in
            if let error = data[0] as? String {
                debugPrint("Socket error: \(error)")
            }
        }
        
        socket.on(EmitEventType.sendMessage.rawValue) { data, ack in
            guard let response = data.first as? [String: Any] else { return }
            
            if let chunk = response["chunk"] as? String,
               let transcript = response["transcript"] as? String,
               let isEndChunk = response["isEndChunk"] as? Bool {
                let received = CallMessage(chunk: chunk, isEndChunk: isEndChunk, transcript: transcript)
                self.callMessagePublisher.send(received)
            }
        }
        
        // MARK: New Event Jusr for chat.
        socket.on(EmitEventType.chatMessage.rawValue) { data, ack in
            guard let response = data.first as? [String: Any] else { return }
            
            if let chunk = response["chunk"] as? String,
               let isEndChunk = response["is_end"] as? Bool {
                let received = CallMessage(chunk: chunk, isEndChunk: isEndChunk, transcript: "not required on chat")
                debugPrint("Data Received on socket: \(chunk) || isEndChunk: \(isEndChunk)")
                self.callMessagePublisher.send(received)
            }
        }
    }
    
    /// Emit call Stage changes
    func emitChangeCallState(with state: EmitEventType) {
        let startCallRequest: [String: Any] = [
            "callId": userID
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: startCallRequest, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            socket.emit(state.rawValue, jsonString)
        }
    }

    /// Emit Costom Call/Chat Events
    func emitCustomEvent(eventName: EmitEventType, data: [String: Any], completion: ((Bool) -> Void)? = nil) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Emit Event Type: \(eventName.rawValue)")
            print("Emiting Event String: \(jsonString)")
            socket.emit(eventName.rawValue, jsonString) // Old method: Emit without receiving ack.
        } else {
            // JSON conversion failed
            completion?(false)
        }
    }

    func connect() {
        socket.connect()
    }

    func disconnect() {
        chatStopEvent()
        socket.disconnect()
    }
}

// MARK: - Working
extension SocketService {
    
    func callStartEvent(interactionMode: ChatMode) {
        switch interactionMode {
        case .call:
            let startCallRequest: [String: Any] = [
                "callId": userID,
                "assistantId": UserDefaults.standard.string(forKey: "keyAssistantId")!,
                "gender": "female",
                "languageCode": "en-IN",
                "voiceName": "en-IN-NeerjaNeural",
                "ttsModel": "Azure",
                "llmModel": "gpt-4o-mini",
                "isTranslate": false,
                "additionalInfo": "",
                "email_id": "abc@xyz.com",
                "country_code": "IN",
            ]
            self.emitCustomEvent(eventName: .startCall, data: startCallRequest)
        case .chat:
            let startChatRequest: [String: Any] = [
                "conversation_id": userID,
                "start_time": AssistantUtils.currentTimeMillis,
                "gender": "female",
                "interface_type": "IOS",
                "call_type": "Chat",
                "language_id": "en-IN",
                "language_name": "English (India)",
                "llm_model": "gpt-4o-mini",
                "tenant_id": "IN_JIO_EVA",
                "user_id": userID,
                "user_name": "GOD",
                "email": "shivansh.gaur@blackngreen.com",
                "name": "10x Engineer",
                "phone_no": "1234567890",
                "auth_token": "Soogggoooo_5",
                "assistant_id": "2",
                "ip_address": "172.16.11.222",
                "os": "iOS",
                "browser": "Chrome",
                "device_type": "Desktop",
                "platform": "browser",
                "timezone": "IN/NDLS",
                "location": "IN"
            ]
            self.emitCustomEvent(eventName: .startChat, data: startChatRequest)
        }
    }
    
    func chatStopEvent() {
        let stopChatRequest: [String: Any] = [
            "conversation_id": userID,
            "user_id": userID,
            "timestamp": AssistantUtils.currentTimeMillis,
            "reason": "Call end initiated by user"
        ]
        self.emitCustomEvent(eventName: .chatEnd, data: stopChatRequest)
    }
    
    /// Emit Event from to Socket
    func sendCustomEvent(of type: ChatMode,
                         with encodedAudio: String,
                         at startTime: Int64,
                         completion: @escaping (Bool) -> Void) {
        countMessageId += 1 /// Increase message id count to keep track
        switch type {
        case .call:
            let startCallRequest: [String: Any] = [
                "callId": userID,
                "transcript": encodedAudio,
                "gender": "female",
                "startTime": startTime,
                "endTime" : Int64(Date().timeIntervalSince1970 * 1000),
                "messageId": String(countMessageId),
                "languageCode": "en-IN",
                "voiceName": "en-IN-NeerjaNeural",
                "isTranslate": false,
                "eventType": type.rawValue
            ]
            UserDefaults.standard.set(countMessageId, forKey: "keyMessageCount")
            self.emitCustomEvent(eventName: .sendMessage, data: startCallRequest, completion: completion)
            
        case .chat:
            let startChatRequest: [String: Any] = [
                "conversation_id": userID,
                "user_id": userID,
                "transcript": encodedAudio,
                "timestamp": AssistantUtils.currentTimeMillis,
                "message_id": String(countMessageId),
                "language_id": "en-IN",
                "language_name": "English (India)"
            ]
            UserDefaults.standard.set(countMessageId, forKey: "keyMessageCount")
            print("Chat Message: \(startChatRequest)")
            self.emitCustomEvent(eventName: .chatMessage, data: startChatRequest, completion: completion)
        }
    }
}
