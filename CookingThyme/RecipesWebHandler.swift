//
//  RecipesWebHandler.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/9/20.
//

import Foundation

class RecipesWebHandler: ObservableObject {
    @Published var foundRecipes = [WebRecipe]()
    
    var recipeList = [NSNumber]() {
        didSet {
            setRecipes()
        }
    }
    
    // tasty
    
    static let tastyAppKey = "9bacb7affdmsh5c06e2b4dd670efp196956jsn7dc7caf94abd"


    
    init() {}
    
    
    func listRecipes(withQuery query: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "tasty.p.rapidapi.com"
        urlComponents.path = "/recipes/list"
        urlComponents.queryItems = [
            URLQueryItem(name: "from", value: "0"),
            URLQueryItem(name: "size", value: "10"),
            URLQueryItem(name: "q", value: query)
        ]
        
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var request = URLRequest(url: urlComponents.url!)
        request.setValue(RecipesWebHandler.tastyAppKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("tasty.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.httpMethod = "GET"
        
        var recipeList = [NSNumber]()
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                guard let data = data else {
                    print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                    return
                }
                
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let results = jsonObject["results"] as? [Any] {
                        for result in results {
                            if let recipe = result as? [String: Any] {
                                let name = recipe["name"] as? String
                                let id = recipe["id"] as? NSNumber
                                if let recipeId = id {
                                    recipeList.append(recipeId)
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.setRecipeList(recipeList)
                        }
                    }
                }
            }
            catch {
                print(error)
            }
            
        }.resume()
    }
    
    func setRecipeList(_ recipeList: [NSNumber]) {
        self.recipeList = recipeList
    }
    
    func setRecipes() {
        for recipeId in recipeList {
            listRecipeDetail(withId: recipeId)
        }
    }
    
    func listRecipeDetail(withId id: NSNumber) {
        guard let idString = id.toString() else {return}
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "tasty.p.rapidapi.com"
        urlComponents.path = "/recipes/detail"
        urlComponents.queryItems = [
            URLQueryItem(name: "id", value: idString)
        ]
        
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var request = URLRequest(url: urlComponents.url!)
        request.setValue(RecipesWebHandler.tastyAppKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("tasty.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                guard let data = data else {
                    print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                    return
                }

                var recipe = WebRecipe()
                recipe.id = id
                
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // name
                    let name = jsonObject["name"] as? String
                    recipe.name = name
                    
                    // instructions
                    if let instructions = jsonObject["instructions"] as? [Any] {
                        var recipeInstructions = [String]()
                        
                        for instruction in instructions {
                            if let instruction = instruction as? [String: Any] {
                                if let instructionText = instruction["display_text"] as? String {
                                    recipeInstructions.append(instructionText)
                                }
                            }
                        }
                        
                        recipe.directions = recipeInstructions
                    }
                    
                    // servings
                    let servings = jsonObject["num_servings"] as? NSNumber
                    recipe.servings = servings

                    // sections
                    var recipeSections = [WebSection]()
                    
                    if let sections = jsonObject["sections"] as? [Any] {
                        for section in sections {
                            if let section = section as? [String: Any] {
                                // section
                                var recipeSection = WebSection()
                                // name
                                if let name = section["name"] as? String {
                                    recipeSection.name = name
                                }
                                if let components = section["components"] as? [Any] {
                                    
                                    // ingredients
                                    var sectionIngredients = [WebIngredient]()
                                    
                                    for component in components {
                                        if let component = component as? [String: Any] {
                                            // ingredient
                                            var sectionIngredient = WebIngredient()
                                            
                                            if let ingredient = component["ingredient"] as? [String: Any] {
                                                let name = ingredient["name"] as? String
                                                sectionIngredient.name = name
                                            }
                                            if let measurements = component["measurements"] as? [Any] {
                                                // measurements
                                                var ingredientMeasurements = [WebMeasurement]()
                                                
                                                for measurement in measurements {
                                                    // measurement
                                                    var ingredientMeasurement = WebMeasurement()
                                                    
                                                    if let measurement = measurement as? [String: Any] {
                                                        // quantity
                                                        let quantity = measurement["quantity"] as? String
                                                        ingredientMeasurement.quantity = quantity
                                                        
                                                        // unit
                                                        if let unit = measurement["unit"] as? [String: Any] {
                                                            let unitName = unit["name"] as? String
                                                            let abbreviation = unit["abbreviation"] as? String
                                                            
                                                            ingredientMeasurement.unit = WebUnit(name: unitName, abbreviation: abbreviation)
                                                        }
                                                    }
                                                    
                                                    ingredientMeasurements.append(ingredientMeasurement)
                                                }
                                                
                                                sectionIngredient.measurements = ingredientMeasurements
                                            }
                                            
                                            sectionIngredients.append(sectionIngredient)
                                        }
                                    }
                                    
                                    recipeSection.ingredients = sectionIngredients
                                }
                                
                                recipeSections.append(recipeSection)
                            }
                        }
                    }
                        
                    recipe.sections = recipeSections
                    DispatchQueue.main.async {
                        self.setRecipe(recipe)
                    }
                }
            }
            catch {
                print(error)
            }
            
        }.resume()
    }
    
    func setRecipe(_ recipe: WebRecipe) {
        self.foundRecipes.append(recipe)
    }
    
    func prettyPrinting(data: Data) {
        if let object = try? JSONSerialization.jsonObject(with: data, options: []) {
            if let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) {
                let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print(prettyPrintedString)
            }
        }
    }
}

extension NSNumber {
    func toString() -> String? {
        let formatter = NumberFormatter()
        return formatter.string(from: self)
    }
}
