//
//  AssistantViewModel.swift
//  VoiceAssistant
//
//  Created by Shivansh Gaur on 10/03/25.
//

import Foundation

class AssistantViewModel {
    
    // A reusable function to make GET API calls
    func performGetRequest(urlString: String, httpBody: Data? = nil, completion: @escaping (Result<Data, Error>) -> Void) {
        
        // Validate the URL
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 400, userInfo: [NSLocalizedDescriptionKey: "The URL is invalid."])))
            return
        }
        
        // Create token
        let timestamp = String(Int(Date().timeIntervalSince1970))
        let deviceId = UUID().uuidString
        let token = TokenGeneration.createAppToken(timestamp: String(timestamp), deviceId: deviceId) // write token generation code
        
        // Create a URLRequest object
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add required headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("SDK \(token ?? "N/A")", forHTTPHeaderField: "Authorization")
        request.addValue(String(timestamp), forHTTPHeaderField: "timestamp")
        request.addValue(deviceId, forHTTPHeaderField: "device_id")
        request.addValue("iPhone", forHTTPHeaderField: "device_info")
        request.addValue("1.2.3", forHTTPHeaderField: "app_version")
        request.addValue("en", forHTTPHeaderField: "language")
        request.addValue(/*AssistantUtils.appType*/"app", forHTTPHeaderField: "platform")
        // TODO: Enable them before Hitting API
        request.addValue(AssistantUtils.sdkVersion, forHTTPHeaderField: "sdk_version")
        request.addValue(UserDefaults.standard.string(forKey: "keySessionID") ?? "Unknown", forHTTPHeaderField: "session_id")
        request.addValue(AssistantUtils.osVersion, forHTTPHeaderField: "os_version")
        request.addValue(AssistantUtils.networkIP ?? "1.4.5.6", forHTTPHeaderField: "network_ip")
        
        // Perform the network call
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check for valid response
            guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                completion(.failure(NSError(domain: "HTTPError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP error with status code \(statusCode)."])))
                return
            }
            
            // Return the data
            if let data = data {
                
// Try parsing JSON
//                do {
//                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
//                    let prettyJsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
//
//                    if let jsonString = String(data: prettyJsonData, encoding: .utf8) {
//                        print("✅ Response JSON:\n\(jsonString)")
//                    }
//                } catch {
//                    print("⚠️ JSON Parsing Error:", error)
//                }
                
                completion(.success(data))
            } else {
                completion(.failure(NSError(domain: "NoData", code: 204, userInfo: [NSLocalizedDescriptionKey: "No data received."])))
            }
        }
        
        task.resume()
    }
}
