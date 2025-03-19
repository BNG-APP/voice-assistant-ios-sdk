//
//  DraggableContainerView.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 10/03/25.
//

import UIKit
import SwiftUI

class DraggableContainerView: UIView {
    
    private let button: UIButton
    private var viewController: UIViewController
    private var themeConfig: AssistantConfig
    private let textPadding: CGFloat = 8
    private let margin: CGFloat = 16
    
    private let normalSize: CGFloat = 90
    private let enlargedSize: CGFloat = 110 // Adjusted size
    
    // Timer to hide initial message
    private var hideMessageTimer: Timer?
    
    // Lazy views: Only created when accessed
    private lazy var gifView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var textView: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: themeConfig.response.configJson.themes.light.chat.bot.textColor)
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: themeConfig.response.configJson.themes.light.chat.bot.messageBgcolor)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    init(button: UIButton, gifName: String? = nil, text: String? = nil, viewController: UIViewController, themeSetup: AssistantConfig) {
        self.button = button
        self.viewController = viewController
        self.themeConfig = themeSetup
        super.init(frame: .zero)
        
        setupView()
        setupGestures()
        
        if let text = text {
            textView.text = text
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        self.frame = CGRect(
            x: UIScreen.main.bounds.width - normalSize - margin,
            y: UIScreen.main.bounds.height - normalSize - margin,
            width: normalSize,
            height: normalSize
        )
        
        addSubview(button)
        button.center = CGPoint(x: bounds.midX, y: bounds.midY)
        button.addTarget(self, action: #selector(startCallTapped), for: .touchUpInside)
        
        addSubview(backgroundView)
        addSubview(textView)
        
        DispatchQueue.main.async {
            self.button.alpha = 1.0
            self.backgroundView.isHidden = false
            self.textView.isHidden = false
            
            // Ensure text appears at correct position
            self.updateTextViewPosition()
            
            // Hide message after 3 seconds
            self.hideMessageTimer?.invalidate()
            self.hideMessageTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                self?.hideInitialMessage()
            }
        }
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        self.addGestureRecognizer(panGesture)
        self.isUserInteractionEnabled = true
    }
    
    private func hideInitialMessage() {
        hideMessageTimer?.invalidate()
        textView.isHidden = true
        backgroundView.isHidden = true
    }
    
    // Update UI when call state changes
    private func updateCallUI(startingCall: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                let size = startingCall ? self.enlargedSize : self.normalSize
                self.bounds.size = CGSize(width: size, height: size)
                self.button.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
                self.gifView.frame = self.bounds
            }
        }
    }
    
    // Handle End Call Button Tap
    @objc private func endCallButtonTapped() { }
    
    // Handle Hold Call Button Tap
    @objc private func holdCallButtonTapped() { }
    
    private func noInternetPopup() {
        DispatchQueue.main.async {
            AlertManager.showAlert(
                on: self.viewController,
                title: "No Internet Connection",
                message: "Please check your internet settings.",
                buttonTitles: ["Settings", "Cancel"],
                actions: [
                    {
                        // Open device settings
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(url)
                    },
                    {
                        // Cancel action
                        print("Internet Connection not found and cancel button tapped")
                    }
                ])
        }
    }
    
    @objc private func startCallTapped() {
        // Check Internet Connection
        guard NetworkMonitor.shared.isConnectedToInternet() else {
            noInternetPopup()
            return
        }
        let chatViewModel = ChatViewModel()
        let chatScreen = ChatView(themeConfig: themeConfig.response.configJson)
            .environmentObject(chatViewModel)
        
        let hostingController = UIHostingController(rootView: chatScreen)
        hostingController.modalPresentationStyle = .fullScreen
        viewController.present(hostingController, animated: true)
    }
    
    private func updateTextViewPosition() {
        
        let maxWidth = UIScreen.main.bounds.width * 0.6
        let textSize = textView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame = CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height)
        
        backgroundView.frame = CGRect(
            x: 0, y: 0,
            width: textView.frame.width + textPadding * 2,
            height: textView.frame.height + textPadding * 2
        )
        
        // Position text beside the button
        if center.x <= UIScreen.main.bounds.width / 2 {
            backgroundView.center = CGPoint(x: button.frame.maxX + backgroundView.frame.width / 2 + 10,
                                            y: button.center.y)
        } else {
            backgroundView.center = CGPoint(x: button.frame.minX - backgroundView.frame.width / 2 - 10,
                                            y: button.center.y)
        }
        textView.center = backgroundView.center
    }
    
    @objc private func handleDrag(_ sender: UIPanGestureRecognizer) {
        guard let parentView = superview else { return }
        
        let translation = sender.translation(in: parentView)
        self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
        sender.setTranslation(.zero, in: parentView)
        
        if sender.state == .ended {
            snapToEdges()
        }
        
        // Update text position
//        updateTextViewPosition()
    }
    
    private func snapToEdges() {
        guard let parentView = superview else { return }
        let safeAreaInsets = parentView.safeAreaInsets
        let parentWidth = parentView.frame.width
        let parentHeight = parentView.frame.height
        
        let finalX: CGFloat = (self.center.x <= parentWidth / 2) ? margin + self.frame.width / 2 : parentWidth - margin - self.frame.width / 2
        let finalY = max(self.frame.height / 2 + safeAreaInsets.top, min(self.center.y, parentHeight - self.frame.height / 2 - safeAreaInsets.bottom))
        
        UIView.animate(withDuration: 0.2) {
            self.center = CGPoint(x: finalX, y: finalY)
        }
    }
}
