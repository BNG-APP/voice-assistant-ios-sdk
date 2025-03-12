//
//  VoiceAssistantButtonFactory.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 10/03/25.
//

import UIKit

class VoiceAssistantButtonFactory {
    
    static func createButton(with config: VoiceAssistantConfig, frame: CGRect) -> UIButton {
        
        let button = UIButton(type: .custom)
        button.frame = frame
        
        /// Either host can apply image or a text and image will be on priority
        if let buttonImage = config.buttonImage {
            button.setImage(UIImage(named: buttonImage), for: .normal)
            button.imageView?.contentMode = .scaleAspectFill
            button.backgroundColor = .clear
            button.imageView?.layer.cornerRadius = config.cornerRadius ?? 30.0 // Default corner radius
        } else {
            button.setTitle(config.setTitle ?? "Call", for: .normal)
            button.setTitleColor(config.setTitleColor ?? .black, for: .normal)
            button.backgroundColor = config.backgroundColor ?? .systemGray
            button.layer.cornerRadius = config.cornerRadius ?? 30.0
        }
        
        return button
    }
}
