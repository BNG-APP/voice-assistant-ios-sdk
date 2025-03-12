//
//  ChatHeaderView.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 11/03/25.
//

import SwiftUI

struct ChatHeaderView: View {
    var assistantImage: String
    var assistantName: String
    var onBackButtonTapped: () -> Void // Closure for back button action
    let headerTheme: Themes
    
    var body: some View {
        HStack(spacing: 20) {
            // Back button
            Button(action: onBackButtonTapped) {
                Image(systemName: "arrow.backward")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .font(.title)
                    .foregroundColor(.black) // You can change the color as needed
            }
            
            Image(assistantImage) // Replace with dynamic image loading
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            Text(assistantName)
                .font(.custom(headerTheme.light.chat.timeFontStyle, size: 18))
            
            Spacer()
        }
        .background(Color(hex: headerTheme.light.chat.backgroundColor))
    }
}
