//
//  UIColor+Extensions.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 11/03/25.
//

import UIKit

extension UIColor {
    
    /// Initialize UIColor with a hex string
    /// - Parameters:
    ///   - hex: A hex color code string (e.g., "#RRGGBB" or "RRGGBBAA")
    ///   - alpha: Optional alpha value to override the one in the hex string (default: nil)
    convenience init?(hex: String, alpha: CGFloat? = nil) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            print("Invalid hex string")
            return nil // Invalid hex String
        }
        
        let length = hexSanitized.count
        switch length {
        case 6: // RGB (e.g., FF0000)
            let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgb & 0x0000FF) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: alpha ?? 1.0)
        case 8: // RGBA (e.g., FF0000FF)
            let red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            let green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            let blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            let a = CGFloat(rgb & 0x000000FF) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: alpha ?? a)
        default:
            print("Invalid hex string length")
            return nil
        }
    }
}

import SwiftUI

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        guard hexSanitized.count == 6, let rgbValue = Int32(hexSanitized, radix: 16) else { return nil }
        
        let red = Double((rgbValue >> 16) & 0xFF) / 255.0
        let green = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
