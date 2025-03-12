//
//  MediaViewerView.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 11/03/25.
//

import SwiftUI
import AVKit

@available(iOS 15.0, *)
struct MediaViewerView: View {
    var mediaURL: URL
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            if mediaURL.pathExtension == "mp4" { // Video Preview
                VideoPlayer(player: AVPlayer(url: mediaURL))
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        let player = AVPlayer(url: mediaURL)
                        player.play()
                    }
            } else { // Image Preview
                AsyncImage(url: mediaURL) { image in
                    image
                        .resizable()
                        .scaledToFit() // Scale the image while maintaining its aspect ratio
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.9, maxHeight: UIScreen.main.bounds.height * 0.9) // Dynamic frame size
                        .cornerRadius(20)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = value
                                }
                                .onEnded { _ in
                                    if scale < 1 { scale = 1 }
                                }
                        )
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    if value.translation.height > 100 {
                                        dismiss()
                                    }
                                }
                        )
                        .onAppear {
                            print("Media URL: \(mediaURL)")
                        }
                } placeholder: {
                    ProgressView() // Show a loading indicator while the image loads
                }
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

