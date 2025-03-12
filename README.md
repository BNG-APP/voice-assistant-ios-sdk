# VoiceAssistant SDK

VoiceAssistant is an iOS SDK that provides voice assistant capabilities. It supports easy integration via Swift Package Manager (SPM).

## 📥 Installation

### Using Swift Package Manager (SPM)

1. Open your Xcode project.
2. Navigate to **File** > **Add Packages...**.
3. In the search bar, enter the repository URL:
   ```
   https://github.com/BNG-APP/voice-assistant-ios-sdk.git
   ```
4. Choose the latest version (`0.0.1`) and click **Add Package**.
5. Import `VoiceAssistant` in your project:
   ```swift
   import VoiceAssistant
   ```

## 🛠️ Usage

### Initialize the VoiceAssistant SDK

```swift
import VoiceAssistant

// MARK: - Add Button
VoiceAssistant.addButton(to: <#T##UIViewController#>, with: <#T##VoiceAssistantConfig#>, assistantModel: <#T##AssistantModel#>)

// MARK: - Remove Button
VoiceAssistant.removeButton()
```

## ⚡ Configuration

You can configure the SDK using `VoiceAssistantConfig`:

```swift

/// tenantId required in order to use the assistant intelligence
VoiceAssistantConfig(tenantId: "need_to_buy_from_owner")
```

## 🏗 Requirements
- iOS 15.0+
- Swift 5.5+

## 📝 License
VoiceAssistant is available under the ... license. See the LICENSE file for more info.

## 📩 Support
For any issues or questions, please open an issue on GitHub.

---

<p align="center"><strong>BNG-crafted ❤️ Future-approved</strong></p>

