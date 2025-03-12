//
//  AssistantConfigModel.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 10/03/25.
//

import Foundation

public struct AssistantConfig: Codable {
    let statusCode: Int
    let status: String
    let message: String
    let response: ThemeResponse
}

// TODO: Make them optional, all of them.
struct ThemeResponse: Codable {
    let configJson: ConfigJson
}

struct ConfigJson: Codable {
    let themes: Themes
    let config: Config
}

struct Themes: Codable {
    let defaultTheme: String
    let light: Theme
    let dark: Theme
    
    enum CodingKeys: String, CodingKey {
        case defaultTheme = "default_theme"
        case light, dark
    }
}

struct Theme: Codable {
    let call: CallTheme
    let chat: ChatTheme
}

// MARK: - Call Theme and Config Models
struct CallTheme: Codable {
    let backgroundColor: String
    
    /// Assistant Name colour
    let titleColor: String?
    
    /// Coluld be transcript colour
    let subtitleColor: String
    
    /// Transcript Colour
    let transcriptColor: String?
    
    /// Call Time colour
    let timeColor: String?
    
    let fontStyle: FontStyle
    let fontSize: FontSize
    
    enum CodingKeys: String, CodingKey {
        case backgroundColor = "background_color"
        case titleColor = "title_color"
        case subtitleColor = "subtitle_color"
        case transcriptColor = "transcript_color"
        case timeColor = "time_color"
        case fontStyle = "font_style"
        case fontSize = "font_size"
    }
}

struct FontStyle: Codable {
    let title: String
    let subtitle: String
    let transcript: String
    let timeFontStyle: String
    
    enum CodingKeys: String, CodingKey {
        case title, subtitle, transcript
        case timeFontStyle = "time_font_style"
    }
}

struct FontSize: Codable {
    let title: Int?
    let subtitle: Int
    let transcript: Int
    let timeFontSize: Int?
    
    enum CodingKeys: String, CodingKey {
        case title, subtitle, transcript
        case timeFontSize = "time_font_size"
    }
}

// MARK: - Chat Theme and Config Models

struct ChatTheme: Codable {
    let backgroundColor: String
    let padding: Int
    let justify: String
    let timeColor: String
    let timeFontSize: Int
    let timeFontStyle: String
    let bot: ChatParticipant
    let user: ChatParticipant
    let inputBox: InputBox
    
    enum CodingKeys: String, CodingKey {
        case backgroundColor = "background_color"
        case padding, justify
        case timeColor = "time_color"
        case timeFontSize = "time_font_size"
        case timeFontStyle = "time_font_style"
        case bot, user
        case inputBox = "input_box"
    }
}

struct ChatParticipant: Codable {
    let messageBgcolor: String
    let textColor: String
    let imagePosition: String
    let timePosition: String
    let fontStyle: String
    let fontSize: Int
    
    enum CodingKeys: String, CodingKey {
        case messageBgcolor = "message_bgcolor"
        case textColor = "text_color"
        case imagePosition = "image_position"
        case timePosition = "time_position"
        case fontStyle = "font_style"
        case fontSize = "font_size"
    }
}

struct InputBox: Codable {
    let borderColor: String
    let bgcolor: String
    let padding: Int
    let placeholderText: String?
    let textColor: String
    
    enum CodingKeys: String, CodingKey {
        case borderColor = "border_color"
        case bgcolor, padding
        case placeholderText = "placeholder_text"
        case textColor = "text_color"
    }
}

// MARK: - Config and Logging Models
struct Config: Codable {
    let call: ConfigUrl
    let chat: ConfigUrl
    let didShowCallout: Bool
    let logging: Logging
    
    enum CodingKeys: String, CodingKey {
        case call, chat
        case didShowCallout = "didShowCallout"
        case logging
    }
}

struct ConfigUrl: Codable {
    let url: String
}

// MARK: - Logging
public struct Logging: Codable {
    let topic: String
    let apiEndpoint: String
    let logLevel: LogLevel
}

struct LogLevel: Codable {
    let warning: Bool
    let info: Bool
    let error: Bool
}
