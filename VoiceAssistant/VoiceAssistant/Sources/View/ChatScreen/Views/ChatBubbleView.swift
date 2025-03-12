//
//  ChatBubbleView.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 11/03/25.
//

import SwiftUI

struct ChatBubbleView: View {
    var message: ChatMessageModel
    var cornerRadius: CGFloat = 12
    var assistantName: String?
    @Binding var didSentMessage: Bool
    @State private var isMediaViewerPresented = false
    
    let minSize: CGFloat = 100
    let maxWidthRatio: CGFloat = 2
    let maxHeightRatio: CGFloat = 3
    @State private var imageSize: CGSize = .zero
    
    var messageTheme: ChatTheme

    var body: some View {
        HStack {
            if message.isSentByUser { Spacer() }
            
            VStack(alignment: .leading, spacing: 5) {
                
                // Assistant Name (Only for received messages)
                if let assistantName = assistantName, !assistantName.isEmpty && !message.isSentByUser {
                    Text(assistantName)
                        .font(.custom("WorkSans-Medium", size: 14))
                        .foregroundColor(.gray)
                }

                // Image Message
                if message.type == .image, let mediaURL = message.mediaURL {
                    if #available(iOS 15.0, *) {
                        AsyncImage(url: mediaURL) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: calculateWidth(), height: calculateHeight())
                                .cornerRadius(cornerRadius)
                                .onTapGesture {
                                    isMediaViewerPresented.toggle()
                                }
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        // Fallback for older iOS versions
                        ImageView(urlString: mediaURL.absoluteString)
                            .frame(width: calculateWidth(), height: calculateHeight())
                            .cornerRadius(cornerRadius)
                            .onTapGesture {
                                isMediaViewerPresented.toggle()
                            }
                    }
                }

                // Video Message
                else if message.type == .video, let thumbnailURL = message.thumbnailURL {
                    ZStack {
                        if #available(iOS 15.0, *) {
                            AsyncImage(url: thumbnailURL)
                                .frame(width: 200, height: 150)
                                .cornerRadius(cornerRadius)
                        } else {
                            // Fallback on earlier versions
                        }

                        VStack {
                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white.opacity(0.8))
                            if let duration = message.duration {
                                Text("\(duration)s")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.top, 5)
                            }
                        }
                    }
                    .onTapGesture {
                        isMediaViewerPresented.toggle()
                    }
                }

                // Show text below media (if exists)
                if let text = message.text, !text.isEmpty {
                    Text(text)
                    // TODO: Instead of hardcoded font style, accept font from backend
                        .font(message.isSentByUser ?
                            .custom(messageTheme.user.fontStyle, size: CGFloat(messageTheme.user.fontSize)) :
                                .custom(messageTheme.bot.fontStyle, size: CGFloat(messageTheme.bot.fontSize)))
                        .foregroundColor(message.isSentByUser ?
                                         Color(hex: messageTheme.user.textColor) :
                                            Color(hex: messageTheme.bot.textColor))
                        .padding(.init(top: 10, leading: 15, bottom: 10, trailing: 15))
                        .background(message.isSentByUser ?
                                    Color(hex: messageTheme.user.messageBgcolor) :
                                        Color(hex: messageTheme.bot.messageBgcolor))
                        .cornerRadius(cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                            // TODO: Backend Need to add A border colour too
                                .stroke(message.isSentByUser ?
                                        Color(hex: messageTheme.user.messageBgcolor) ?? Color.clear :
                                            Color.clear,
                                        lineWidth: 1)
                        )
                        .frame(minWidth: 50, maxWidth: UIScreen.main.bounds.width * 0.65, alignment: message.isSentByUser ? .trailing : .leading)
                }

                // Time Label
                HStack {
                    if !message.isSentByUser {
                        Text(message.formattedTime)
                        // TODO: Instead of font style .caption, provide custom fontStyle and size
                            .font(.caption)
                            .foregroundColor(Color(hex: messageTheme.timeColor))
                    }
                    Spacer()
                    if message.isSentByUser {
                        Text(didSentMessage ? "Sent . \(message.formattedTime)" : "Sending...")
                            .font(.caption)
                            .foregroundColor(Color(hex: messageTheme.timeColor))
                    }
                }
            }
            .frame(minWidth: 50, maxWidth: UIScreen.main.bounds.width * 0.65, alignment: message.isSentByUser ? .trailing : .leading)

            if !message.isSentByUser { Spacer() }
        }
        .onAppear {
            if message.type == .image || message.type == .video {
                fetchImageSize()
            }
        }
        .padding(.horizontal)
        .fullScreenCover(isPresented: $isMediaViewerPresented) {
            if let mediaURL = message.mediaURL /*URL(string: "https://fastly.picsum.photos/id/526/600/800.jpg?hmac=Kwx76AhyfCTBwZ3nMAONgOGFfTfnOE-Fzljedz3Z8Do")*/ {
                if #available(iOS 15.0, *) {
                    MediaViewerView(mediaURL: mediaURL)
//                    FullScreenImageView(imageURL: mediaURL)
                } else {
                    // Fallback on earlier versions
                    Text("Fallback on earlier versions")
                }
            } else {
                Text("Error loading image")
            }
        }
    }
    
    // Fetch the image size asynchronously
     private func fetchImageSize() {
         // Use URLSession to download the image data asynchronously
         let task = URLSession.shared.dataTask(with: message.mediaURL!) { data, response, error in
             guard let data = data, error == nil else {
                 print("Error fetching image data: \(String(describing: error))")
                 return
             }
             
             // Create a UIImage from the fetched data
             if let uiImage = UIImage(data: data) {
                 DispatchQueue.main.async {
                     self.imageSize = uiImage.size
                 }
             }
         }
         
         // Start the download task
         task.resume()
     }
    
    // Calculate dynamic width with constraints
    private func calculateWidth() -> CGFloat {
        let aspectRatio = imageSize.width / imageSize.height
        let maxWidth = UIScreen.main.bounds.width * maxWidthRatio / (maxWidthRatio + maxHeightRatio)
        var calculatedWidth = min(max(imageSize.width, minSize), maxWidth)
        return calculatedWidth
    }
    
    // Calculate dynamic height with constraints
    private func calculateHeight() -> CGFloat {
        let aspectRatio = imageSize.width / imageSize.height
        let calculatedHeight = calculateWidth() / aspectRatio
        let maxHeight = UIScreen.main.bounds.height * maxHeightRatio / (maxWidthRatio + maxHeightRatio)
        return min(max(calculatedHeight, minSize), maxHeight)
    }
}

//struct ChatBubbleView_Previews: PreviewProvider {
//    static var receiveShortTextChat = ChatMessageModel(
//        id: UUID(),
//        text: "Hello! This is a test message.",
//        mediaURL: nil,
//        thumbnailURL: nil,
//        type: .text,
//        timestamp: Date(),
//        isSentByUser: false,
//        duration: nil
//    )
//
//    static var previews: some View {
//            // Only preview if SocketIO is available, otherwise disable the preview
//            #if DEBUG
//            // Create a state variable to bind to `didSentMessage`
//            @State var didSentMessage = false
//
//            // Preview the view with the binding to didSentMessage
//            return ChatBubbleView(message: receiveShortTextChat,
//                                  cornerRadius: 12,
//                                  borderColour: "#3B864E",
//                                  assistantName: "Eva",
//                                  didSentMessage: $didSentMessage)
//                .previewLayout(.sizeThatFits)
//                .padding()
//            #else
//            return Text("Preview unavailable due to missing dependencies")
//            #endif
//        }
//}

// TODO: Remove if not needed
struct ImageView: View {
    @ObservedObject private var imageViewModel: ImageViewModel
    
    init(urlString: String?) {
        imageViewModel = ImageViewModel(urlString: urlString)
    }
    
    var body: some View {
        Group {
            if let image = imageViewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 200)
            } else {
                Color.gray
                    .frame(width: 300, height: 200)
                    .overlay(Text("Loading...").foregroundColor(.white))
            }
        }
    }
}
