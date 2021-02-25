//
//  RecipeTranscriber.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/16/20.
//  Coded by Daniel Nybo

import Foundation
import SwiftyJSON

class ImageTranscriber: ObservableObject {
    let MAX_SPACE_X = 250
    let MAX_SPACE_Y = 10
    var fonts:[Int] = []
    
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

    func createTranscription(fromImage uiImage: UIImage, setRecipe: @escaping (Recipe?, String?) -> Void) {
        guard let imageBase64 = base64EncodeImage(uiImage) else {return}

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "vision.googleapis.com"
        urlComponents.path = "/v1/images:annotate"
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: Keys.cloudVisionApi)
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
                
                var transcription = Transcription()

                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(jsonObject)
                    if let responses = jsonObject["responses"] as? [Any] {
                            if let response = responses[0] as? [String: Any] {
                                if let textAnnotations = response["textAnnotations"] as? [Any] {
                                    var annotations = [Annotation]()
                                    
                                    for textAnnotation in textAnnotations {
                                        if let textAnnotation = textAnnotation as? [String: Any] {
                                            var annotation = Annotation()
                                            
                                            if let boundingPoly = textAnnotation["boundingPoly"] as? [String:Any] {                                              if let boundingPolyVertices = boundingPoly["vertices"] as? [Any] {
                                                    var vertices = [Vertex]()
                                                
                                                    for boundingPolyVertex in boundingPolyVertices {
                                                        if let boundingPolyVertex = boundingPolyVertex as? [String: Any] {
                                                            var vertex = Vertex()
                                                            if let x = boundingPolyVertex["x"] as? Int {
                                                                vertex.x = x
                                                            }
                                                            if let y = boundingPolyVertex["y"] as? Int {
                                                                vertex.y = y
                                                            }
                                                            vertices.append(vertex)
                                                        }
                                                    }
                                                    annotation.boundingPoly = vertices
                                                }
                                            }
                                            if let description = textAnnotation["description"] as? String {
                                                annotation.description = description
                                            }
                                            annotations.append(annotation)
                                        }
                                    }
                                    transcription.annotations = annotations
                                    let analyzedTranscription = self.analyzeTranscription(transcription)
                                    let recipeText = transcription.annotations[0].description
                                    DispatchQueue.main.async {
                                        setRecipe(analyzedTranscription, recipeText)
                                    }
                                }
                            }
                    }
                }
            }
            catch {
                print("error transcribing image")
            }
        }
        .resume()
    }
    
    func analyzeTranscription(_ transcription: Transcription) -> Recipe? {
        // first annotation is the whole recipe in text including new lines
        if transcription.annotations.count == 0 {
            return nil
        }
        
        //index the vertecies by their location
        let topLeft = 0
        let topRight = 1
        let bottomLeft = 3
        
        //bools
        var lookingForTitle = true
        var ingredientsLocationSet = false
        var directionsLocationSet = false
        var isDirection = false
        var isIngredient = false

        //key font sizes init
        var maxFontSize = 0
        var currFontHeight = 0
        var currFontSize = 0

        //location values for ingredients and directions
        var ingredientsLocationX = 0
        var ingredientsLocationY = 0
        var directionLocationX = 0
        var directionLocationY = 0
        
        var currLine = ""

        //dictionary for holding each section
        var sections = [String:[String]]()
        sections = ["title" : [] , "ingredients": [] , "directions" : []]
        
        //the recipe title
        var title:String = ""

        //the last annotation
        var lastAnnotation:Annotation = transcription.annotations[0]
        
        //loop through each annotation enumerating each index
        //this loop finds the title of the recipe by comparing its relative font size
        //theis loop also will separate lines into sections based on their location
        for index in 0..<transcription.annotations.count {
            var x = 0
            var y = 0
            let boundingPoly = transcription.annotations[index].boundingPoly
            let lastAnn_boundingPoly = lastAnnotation.boundingPoly
            //get all vertecies from bounding poly for current annotation
            for vertex in boundingPoly{
                x = vertex.x
                y = vertex.y
            }

          //get the description which is the word or string value from the annotation
            let description = transcription.annotations[index].description

          //set the locations of keywords like ingredients or directions
            if (!ingredientsLocationSet && index > 1 && (description.localizedCaseInsensitiveContains("ingredient"))){
                ingredientsLocationX = boundingPoly[topLeft].x
                ingredientsLocationY = boundingPoly[topLeft].y
                ingredientsLocationSet = true
            }

            if (!directionsLocationSet && index > 1 && (description.localizedCaseInsensitiveContains("direction") || description.localizedCaseInsensitiveContains("method") || description.localizedCaseInsensitiveContains("instruction") || description.localizedCaseInsensitiveContains("step"))) {
                directionLocationX = boundingPoly[topLeft].x
                directionLocationY = boundingPoly[topLeft].y
                directionsLocationSet = true
            }

          //check if current annotation is in the current line
            if (isInLine(left: boundingPoly[topRight], right: lastAnn_boundingPoly[topLeft]) && !lookingForTitle){
                currLine = currLine + description
                if description.count > 1 {
                    currLine += " "
                }
            }
            else{
                if (currLine != ""){
                    if isIngredient {
                        if !RecipeTranscriber.isIngredientsHeader(line: currLine) {
                            sections["ingredients"]?.append(currLine)
                        }
                    }
                    else if isDirection {
                        if !RecipeTranscriber.isDirectionsHeader(line: currLine) {
                            sections["directions"]?.append(RecipeTranscriber.cleanDirection(currLine))
                        }
                    }
                    
                    currLine = description + " "
                    if (ingredientsLocationSet) {
                        if (directionsLocationSet &&
                            (x >= (directionLocationX - 20) || x <= (directionLocationX + 20)) &&
                            y > directionLocationY) {
                            isIngredient = false
                            isDirection = true
                        }
                        else if ((x >= (ingredientsLocationX - 20) || x <= (ingredientsLocationX + 20)) &&
                              (y > ingredientsLocationY)) {
                            isDirection = false
                            isIngredient = true
                        }
                        else {
                            isDirection = false
                            isIngredient = false
                        }
                     }
                  }
              }
                  

            if (lookingForTitle && index != 0){
                //check if current annotation has max font size
                currFontHeight = boundingPoly[bottomLeft].y - boundingPoly[topLeft].y

                currFontSize = getFontSize(topToBottom: currFontHeight)

                //check is the current annotation, besides the first, has the largest font size
                if currFontSize > maxFontSize && index != 0 {
                    maxFontSize = currFontSize
                }
                //if the current font size is max then it should be a part of the title
                if currFontSize == maxFontSize {
                    title += (description + " ")
                }
                if (currFontSize < maxFontSize) {
                    lookingForTitle = false
                    sections["title"]?.append(title)
                    currLine = description + " "
                }
            }
            lastAnnotation = transcription.annotations[index]
        }
        
        var ingredients = [Ingredient]()
        var directions = [Direction]()
        var recipe_title = ""
        if let title = sections["title"], title.count > 0 {
            recipe_title = title[0]
        }
        
        for ing in (sections["ingredients"] ?? []) {
            ingredients.append(Ingredient(ingredientString: ing))
        }
        var stepNum = 0
        for dir in (sections["directions"] ?? []) {
            directions.append(Direction(step: stepNum, direction: dir))
            stepNum += 1
        }
        let imageRecipe:Recipe = Recipe(name: recipe_title, ingredients: ingredients, directions: directions, images: [], servings: 0, source: "")

        return imageRecipe
    }

    //check to see if the space between the two annotations is the right ammount of space
    //between two words in a sentence
    func isInLine(left leftAnnPos:Vertex,right rightAnnPos:Vertex)-> Bool{
        if ((abs(rightAnnPos.x - leftAnnPos.x) > MAX_SPACE_X) || (abs(rightAnnPos.y - leftAnnPos.y) > MAX_SPACE_Y)) {
            return false
        }
        return true
    }
    
    //checks the given difference in y-space and returns a font size
    func getFontSize(topToBottom rawFontSize:Int)->Int{
        //if fonts is not populated yet, this is the first font size
        for currFont:Int in fonts {
            if ((rawFontSize >= (currFont - 6)) && (rawFontSize <= (currFont + 6))){
                return currFont
            }
        }
        //if there are no matches return a new font size
        fonts.append(rawFontSize)
        return rawFontSize
    }
}
