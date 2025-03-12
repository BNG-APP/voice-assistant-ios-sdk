//
//  TokenGeneration.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 10/03/25.
//

import Foundation
import CommonCrypto

class TokenGeneration {
    private static let algorithm = kCCAlgorithmAES // AES algorithm
    private static let blockSize = kCCBlockSizeAES128 // Block size: 128 bits
    private static let keySize = kCCKeySizeAES256 // Key size: 256 bits (32 bytes)
    private static let options = CCOptions(kCCOptionPKCS7Padding | kCCOptionECBMode) // Padding and ECB mode
    private static let secretKey = "A1b2C3d4E5f6G7h8I9j0K!@#La%^&*Mn" // 32-character secret key
    
    static func createAppToken(timestamp: String, deviceId: String) -> String? {
        let key = "SECURE_timestamp=\(timestamp)&deviceId=\(deviceId)_BACKEND"
        do {
            return try encrypt(key)
        } catch {
            print("Error encrypting token: \(error)")
            return nil
        }
    }
    
    private static func encrypt(_ plainText: String) throws -> String {
        guard let keyData = secretKey.data(using: .utf8),
              let dataToEncrypt = plainText.data(using: .utf8) else {
            throw NSError(domain: "EncryptionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid key or data."])
        }
        
        var cryptLength = size_t(dataToEncrypt.count + blockSize)
        var cryptData = Data(count: cryptLength)
        
        var bytesEncrypted = 0
        
        // Perform the AES encryption
        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            dataToEncrypt.withUnsafeBytes { dataBytes in
                keyData.withUnsafeBytes { keyBytes in
                    CCCrypt(
                        CCOperation(kCCEncrypt), // Encryption operation
                        CCAlgorithm(algorithm), // Algorithm: AES
                        options,                // Options: PKCS7 + ECB
                        keyBytes.baseAddress,   // Encryption key
                        keySize,                // Key size: 256 bits
                        nil,                    // No initialization vector (IV) for ECB
                        dataBytes.baseAddress,  // Input data
                        dataToEncrypt.count,    // Input data length
                        cryptBytes.baseAddress, // Output buffer
                        cryptLength,            // Output buffer length
                        &bytesEncrypted         // Actual output length
                    )
                }
            }
        }
        
        // Check for encryption success
        guard status == kCCSuccess else {
            throw NSError(domain: "EncryptionError", code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Encryption failed with status \(status)."])
        }
        
        // Trim the cryptData buffer to the actual size
        cryptData.removeSubrange(bytesEncrypted..<cryptData.count)
        
        // Encode the encrypted data in Base64 and return it
        return cryptData.base64EncodedString()
    }
}
