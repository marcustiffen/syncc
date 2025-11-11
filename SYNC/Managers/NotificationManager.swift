import Foundation
import FirebaseFunctions

class NotificationManager: ObservableObject {
    
    static let shared = NotificationManager()
    
    private lazy var functions = Functions.functions()
    
    func sendSingularPushNotification(token: String, message: String, title: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        #if STAGING
        guard let url = URL(string: "https://us-central1-syncc-staging.cloudfunctions.net/sendNotification") else {
            print("Invalid URL")
            return
        }
        #else
        guard let url = URL(string: "https://us-central1-sync-69d00.cloudfunctions.net/sendNotification") else {
            print("Invalid URL")
            return
        }
        #endif
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare the data to be sent to the Cloud Function
        let data: [String: Any] = [
            "token": token,
            "message": message,
            "title": title
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
        } catch {
            print("Error serializing JSON:", error)
            completion(.failure(error))
            return
        }
        
        // Debugging: Print the request body being sent
        print("Request body:", String(data: request.httpBody!, encoding: .utf8) ?? "")
        
        // Perform the HTTP request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error calling function:", error)
                completion(.failure(error))
                return
            }
            
            // Check for valid response
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Notification sent successfully")
                completion(.success(true))
            } else {
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                print("Failed to send notification:", errorMessage)
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            }
        }
        
        // Start the task
        task.resume()
    }
}
