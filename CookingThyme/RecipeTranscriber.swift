//
//  RecipeTranscriber.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/16/20.
//

import Foundation
import SwiftyJSON

class RecipeTranscriber: ObservableObject {
    @Published var recipeText: String?
    
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = newImage!.pngData()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    func base64EncodeImage(_ image: UIImage) -> String? {
        let imageData = image.pngData()
        if var imageData = imageData {
            // Resize the image if it exceeds the 2MB API limit
            if (imageData.count > 2097152) {
                let oldSize: CGSize = image.size
                let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
                imageData = resizeImage(newSize, image: image)
            }
            
            return imageData.base64EncodedString(options: .endLineWithCarriageReturn)
        }
        return nil
    }

    func transcribe(uiImage: UIImage) {
        guard let imageBase64 = base64EncodeImage(uiImage) else {return}

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "vision.googleapis.com"
        urlComponents.path = "/v1/images:annotate"
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: CloudVisionAPI.key)
        ]
        
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        request.httpMethod = "POST"
        
        let jsonRequest: [String: Any] = [
                    "requests": [
                        "image": [
                            "content": imageBase64
                        ],
                        "features": [
                          [
                            "type": "DOCUMENT_TEXT_DETECTION"
                          ]
                        ]
                    ]
                ]
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonRequest)
        
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                guard let data = data else {
                    print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                    return
                }
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(jsonObject)
                    if let responses = jsonObject["responses"] as? [Any] {
//                        for response in responses {
                            if let response = responses[0] as? [String: Any] {
                                if let textAnnotations = response["textAnnotations"] as? [Any] {
                                    if let textAnnotation = textAnnotations[0] as? [String: Any] {
                                        if let description = textAnnotation["description"] as? String {
                                            DispatchQueue.main.async {
                                                self.setTranscription(description)
                                            }
                                        }
                                    }
                                }
                            }
//                        }
                    }
                }
            }
            catch {
                print("error transcribing image")
            }
        }
        .resume()
    }
    
    func setTranscription(_ transcription: String) {
        let setTranscription = transcription
        print(setTranscription)
        self.recipeText = transcription
    }
}
