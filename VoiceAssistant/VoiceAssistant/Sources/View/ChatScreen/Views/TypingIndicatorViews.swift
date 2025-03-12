//
//  TypingIndicatorViews.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 11/03/25.
//

import SwiftUI

struct TypingIndicatorViews: View {
    @State private var scale1: CGFloat = 1.0
    @State private var scale2: CGFloat = 1.0
    @State private var scale3: CGFloat = 1.0

    var body: some View {
        HStack {
            Circle()
                .fill(Color.gray.opacity(0.8))
                .frame(width: 8, height: 8)
                .scaleEffect(scale1)
                .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: scale1)

            Circle()
                .fill(Color.gray.opacity(0.8))
                .frame(width: 8, height: 8)
                .scaleEffect(scale2)
                .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(0.2), value: scale2)

            Circle()
                .fill(Color.gray.opacity(0.8))
                .frame(width: 8, height: 8)
                .scaleEffect(scale3)
                .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(0.4), value: scale3)
        }
        .padding(10)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        scale1 = 1.2
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            scale2 = 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            scale3 = 1.2
        }
    }
}

