//
//  ChatMessageModel.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 11/03/25.
//

import Foundation
import SwiftUI
import CoreData

enum ChatMessageType: String, Codable {
    case text
    case image
    case video
}

struct ChatMessageModel: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var text: String?
    var mediaURL: URL?
    var thumbnailURL: URL?
    var type: ChatMessageType
    var timestamp: Date = Date()
    var isSentByUser: Bool
    var duration: Int?  // For video duration

    // Computed property for formatted time
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: timestamp)
    }
}
