//
//  FontManager.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 11/03/25.
//

import UIKit
import CoreText

public class FontManager {
    
    // MARK: - Method to Register Font
    public static func registerFont(named fontName: String, withExtension fontExtension: String, from bundle: Bundle) {
        // Locate the font file in the framework bundle
        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension) else {
            print("Failed to locate font file \(fontName).\(fontExtension) in bundle")
            return
        }
        
        // Load and register the font with CoreText
        guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider) else {
            print("Failed to load font data from \(fontURL)")
            return
        }
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            if let error = error?.takeRetainedValue() {
                print("Error registering font: \(error.localizedDescription)")
            }
        } else {
            print("Successfully registered font: \(fontName)")
        }
    }
    
    
    // MARK: - Make a list of Fonts and add them to tramework on run time
    public static func registerAllFonts() {
//        let fonts = [
//            "WorkSans-Bold",
//            "WorkSans-Italic",
//            "WorkSans-Light",
//            "WorkSans-LightItalic",
//            "WorkSans-Medium",
//            "WorkSans-Regular",
//            "WorkSans-SemiBold",
//        ]
        
        let fonts = ["Pacifico"]
        
        let frameworkBundle = Bundle(for: VoiceAssistant.self)
        
        for font in fonts {
            registerFont(named: font, withExtension: "ttf", from: frameworkBundle)
        }
    }
    
//#if DEBUG
//        for familyName in UIFont.familyNames {
//            print("Family: \(familyName)")
//            for fontName in UIFont.fontNames(forFamilyName: familyName) {
//                print("Font: \(fontName)")
//            }
//        }
//#endif
}
