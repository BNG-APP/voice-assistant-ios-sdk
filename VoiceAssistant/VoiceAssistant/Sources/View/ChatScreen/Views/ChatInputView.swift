//
//  ChatInputView.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 11/03/25.
//

import SwiftUI

struct ChatInputView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var text: String = ""
    @State private var placeholder: String = "Type a message..."
    @State private var isEditing: Bool = false // Track active state
    let inputBoxTheme: Themes
    
    var body: some View {
        HStack(spacing: 10) {
            // TODO: Upcoming Feature 
//            Button(action: { /* Open file picker */ }) {
//                Image(systemName: "paperclip")
//                    .font(.system(size: 22))
//                    .foregroundColor(.gray)
//            }
            
                        if #available(iOS 16.0, *) {
                            TextField(inputBoxTheme.light.chat.inputBox.placeholderText ?? placeholder, text: $text, axis: .vertical)
                                .font(.custom("WorkSans-Regular", size: CGFloat(inputBoxTheme.light.chat.user.fontSize)))
                                .lineLimit(3)
                                .padding(.init(top: 10, leading: 15, bottom: 10, trailing: 15))
//                                .background(Color(hex: "#fcfcfa") ?? Color.gray.opacity(0.2))
                                .background(Color(hex: inputBoxTheme.light.chat.inputBox.bgcolor))
                                .cornerRadius(25.0)
                                .foregroundColor(Color(hex: inputBoxTheme.light.chat.inputBox.textColor) ?? Color.gray)  // Set text color here
                                .overlay {
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color(hex: inputBoxTheme.light.chat.inputBox.borderColor) ?? Color.gray, lineWidth: 1)
                                }
                        }
//            else {
//            if #available(iOS 15.0, *) {
//                MultilineTextView(text: $text, placeholder: placeholder, isEditing: $isEditing)
//                    .padding(.init(top: 10, leading: 15, bottom: 10, trailing: 15))
//                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, maxHeight: 60)
//                    .background(Color(hex: "#fcfcfa") ?? Color.gray.opacity(0.2))
//                    .cornerRadius(25.0)
//                    .foregroundColor(Color(hex: "#000000") ?? Color.gray)
//                    .overlay {
//                        RoundedRectangle(cornerRadius: 25)
//                            .stroke(Color.gray, lineWidth: 1)
//                    }
//            } else {
//                MultilineTextView(text: $text, placeholder: placeholder, isEditing: $isEditing)
//                    .padding(.init(top: 10, leading: 15, bottom: 10, trailing: 15))
//                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, maxHeight: 60)
//                    .background(Color(hex: "#fcfcfa") ?? Color.gray.opacity(0.2))
//                    .cornerRadius(25.0)
//                    .foregroundColor(Color(hex: "#000000") ?? Color.gray)
//            }
            
            Button(action: {
                sendMessage()
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 22))
                    .foregroundColor(text.isEmpty ? .gray : .blue)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(Color(hex: inputBoxTheme.light.chat.backgroundColor))
        .onTapGesture {
            dismissKeyboard()
        }
        .onChange(of: text) { newValue in
            isEditing = !newValue.isEmpty
        }
    }
    
    private func sendMessage() {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let newMessage = ChatMessageModel(text: trimmedText, type: .text, isSentByUser: true)
        viewModel.sendMessage(newMessage)
        text = ""
        isEditing = false
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        isEditing = false
    }
}

// MARK: - Text Field Wrapper is going to be used for replacing Text
import UIKit

struct MultilineTextView: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    @Binding var isEditing: Bool
    @State private var internalText: String = "" // New state variable

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MultilineTextView

        init(_ parent: MultilineTextView) {
            self.parent = parent
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isEditing = true
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = .black
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isEditing = false
            // Only set placeholder if text is empty
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.lightGray
                parent.internalText = "" // Clear internal text
            } else {
                parent.internalText = textView.text // Save actual content when editing ends
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.internalText = textView.text // Update internal text
            textView.invalidateIntrinsicContentSize() // Forces layout update
        }
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        textView.isScrollEnabled = false // Allows natural expansion
        textView.text = placeholder
        textView.textColor = .lightGray
        textView.isScrollEnabled = true
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical) // Avoids conflicts
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        // Placeholder logic for when not editing
        if text.isEmpty && !isEditing {
            if uiView.text != placeholder {
                uiView.text = placeholder
                uiView.textColor = .lightGray
            }
        } else if isEditing || !text.isEmpty {
            uiView.text = text
            uiView.textColor = .black
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
