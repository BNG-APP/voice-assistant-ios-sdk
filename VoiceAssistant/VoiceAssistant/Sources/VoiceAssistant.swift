//
//  VoiceAssistant.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 10/03/25.
//

import UIKit

@objc public protocol VoiceAssistantDelegate: AnyObject {
    // Nothing
}

@objc
public class VoiceAssistant: NSObject {
    
    private static var floatingButton: UIButton?
    private static var floatingContainer: UIView?
    private static var assistantViewModel = AssistantViewModel()
    private static var fontRegistered: Bool = false
    public static var delegate: VoiceAssistantDelegate?
    
    @objc
    public static func addButton(
        to viewController: UIViewController,
        with config: VoiceAssistantConfig,
        assistantModel: AssistantModel
    ) {
        
        guard !config.tenantId.isEmpty else {
            debugPrint("Please provide Tenant-ID before initialising")
            return
        }
        
        ///  Generate New User Id everytime
        UserDefaults.standard.set(UUID().uuidString, forKey: "keyUserID")
        UserDefaults.standard.set(UUID().uuidString, forKey: "keySessionID")
        UserDefaults.standard.set(config.tenantId, forKey: "keyTenantId")
        UserDefaults.standard.set(assistantModel.id, forKey: "keyAssistantId")
        UserDefaults.standard.set(assistantModel.name, forKey: "keyAssistantName")
        UserDefaults.standard.set(config.buttonImage, forKey: "keyAssistantImage") // TODO: Replace it with URL Downloader
        // Add: Gender, Language, voiceName, TTSModel, LLMModel
        
        // Perform setup asynchronously for better performance
        DispatchQueue.global(qos: .userInitiated).async {
            
            // MARK: Register font only once
            /// Register Default Framework Fonts
            if !fontRegistered {
                FontManager.registerAllFonts()
                fontRegistered = true
            }
            
            let url = "https://evainternal.bngrenew.com/evaportalbackend/sdk/theme-config?tenantId=\(config.tenantId)&assistantId=\(assistantModel.id)"
            assistantViewModel.performGetRequest(urlString: url) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        do {
                            let responseModel = try JSONDecoder().decode(AssistantConfig.self, from: data)
                            
                            configureButton(in: viewController,
                                            with: config,
                                            be: responseModel,
                                            assistantModel: assistantModel)
                        } catch {
                            print("Error decoding JSON: \(error.localizedDescription)")
                        }
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private static func configureButton(
        in viewController: UIViewController,
        with config: VoiceAssistantConfig, // User's populated model
        be fetchedData: AssistantConfig, // Model Created from BE
        assistantModel: AssistantModel
    ) {
        
        // Ensure this method runs on the main thread
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                configureButton(in: viewController,
                                with: config,
                                be: fetchedData,
                                assistantModel: assistantModel)
            }
            return
        }
        
        /// Remove any existing button first
        removeButton()
        
        /// Then Create a New button
        /// Based on `interactionMethod` add button to hosting app
        let buttonFrames = CGRect(x: viewController.view.frame.width - 80,
                                  y: viewController.view.frame.height - 80,
                                  width: 60, height: 60)
        
        let button = VoiceAssistantButtonFactory.createButton(with: config, frame: buttonFrames)
        
        // TODO: Add Analytics later
            // In DraggableContainerView add another parameter to show or hide "text" based on fetchedData.didShowCallout: Bool
            let textToShow = fetchedData.response.configJson.config.didShowCallout ?
                        "Hi! I am Chat Assistant.\nClick here for any assistance" : nil
            let draggableContainer = DraggableContainerView(button: button,
                                                            gifName: "loader_gif_4",
                                                            text: textToShow,
                                                            viewController: viewController,
                                                            themeSetup: fetchedData)
            viewController.view.addSubview(draggableContainer)
            floatingContainer = draggableContainer
    }
    
    @objc
    public static func removeButton() {
        if let floatingButtonView = floatingButton {
            floatingButtonView.removeFromSuperview()
            floatingButton = nil
        } else if let floatingContainerView = floatingContainer {
            floatingContainerView.removeFromSuperview()
            floatingContainer = nil
        }
    }
}
