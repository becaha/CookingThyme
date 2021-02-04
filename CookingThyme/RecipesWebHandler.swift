//
//  RecipesWebHandler.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/9/20.
//

import Foundation

class RecipesWebHandler: ObservableObject {
    @Published var recipeList = [WebRecipe]()
    @Published var recipeDetail: WebRecipe?
    @Published var recipeDetailError = false
    @Published var recipesStore = [Int: WebRecipe]()
    @Published var listingRecipes = false
    @Published var isMore = false
        
    var lastQuery = ""
    
    var recipeListIndex = 0
    var requestPageSize = 20

    init() {}
    
    // lists paginated recipes with last used query string
    func listMoreRecipes() {
        internalListRecipes(withQuery: lastQuery)
    }
    
    // lists recipes with given query string, first call to api
    func listRecipes(withQuery query: String) {
        recipeListIndex = 0
        recipeList = []
        lastQuery = query
        internalListRecipes(withQuery: query)
    }
        
    // lists recipes with given query string
    func internalListRecipes(withQuery query: String) {
        listingRecipes = true
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "tasty.p.rapidapi.com"
        urlComponents.path = "/recipes/list"
        var queryItems = [
            URLQueryItem(name: "from", value: recipeListIndex.toString()),
            URLQueryItem(name: "size", value: requestPageSize.toString())
        ]
        
        if query != "" {
            queryItems.append(URLQueryItem(name: "q", value: query))
        }
        
        self.recipeListIndex += self.requestPageSize
        
        urlComponents.queryItems = queryItems
        
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var request = URLRequest(url: urlComponents.url!)
        request.setValue(Keys.tastyApi, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("tasty.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.httpMethod = "GET"
        
        var recipes = [WebRecipe]()
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                guard let data = data else {
                    print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                    return
                }
                
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let count = jsonObject["count"] as? Int {
                        if self.recipeListIndex < count {
                            DispatchQueue.main.async {
                                self.isMore = true
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                self.isMore = false
                            }
                        }
                    }
                    if let results = jsonObject["results"] as? [Any] {
                        for result in results {
                            if let recipe = result as? [String: Any] {
                                let name = recipe["name"] as? String
                                let id = recipe["id"] as? Int
                                if let recipeId = id, let recipeName = name {
                                    recipes.append(WebRecipe(id: recipeId, name: recipeName))
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.setRecipeList(recipes)
                        }
                    }
                }
            }
            catch {
                print(error)
            }
        }.resume()
    }
    
    // sets list of recipes
    func setRecipeList(_ recipeList: [WebRecipe]) {
        self.recipeList.append(contentsOf: recipeList)
        listingRecipes = false
    }
    
    // lists detail for a recipe (gets the parts of the recipe)
    // very deep api result caused a very deep function
    func listRecipeDetail(_ recipe: WebRecipe) {
        recipeDetailError = false
        if self.recipesStore[recipe.id] != nil {
            self.recipeDetail = recipe
            return
        }
        let idString = recipe.id.toString()
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "tasty.p.rapidapi.com"
        urlComponents.path = "/recipes/detail"
        urlComponents.queryItems = [
            URLQueryItem(name: "id", value: idString)
        ]
        
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var request = URLRequest(url: urlComponents.url!)
        request.setValue(Keys.tastyApi, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("tasty.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                guard let data = data else {
                    print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        self.recipeDetailError = true
                        return
                    }
                    
                }

                var recipe = recipe
                
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // name
                    if let name = jsonObject["name"] as? String {
                        recipe.name = name
                    }
                    
                    if let thumbnail_url = jsonObject["thumbnail_url"] as? String {
                        recipe.imageURL = thumbnail_url
                    }
                    
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
                    if let servings = jsonObject["num_servings"] as? Double {
                        recipe.servings = Int(max(1, round(servings)))
                    }
                    else if let servings = jsonObject["num_servings"] as? Int {
                        recipe.servings = servings
                    }

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
                                                if let name = ingredient["name"] as? String {
                                                    sectionIngredient.name = name
                                                }
                                            }
                                            if let measurements = component["measurements"] as? [Any] {
                                                // measurements
                                                var ingredientMeasurements = [WebMeasurement]()
                                                
                                                for measurement in measurements {
                                                    // measurement
                                                    var ingredientMeasurement = WebMeasurement()
                                                    
                                                    if let measurement = measurement as? [String: Any] {
                                                        // quantity
                                                        if let quantity = measurement["quantity"] as? String {
                                                            ingredientMeasurement.quantity = quantity
                                                        }
                                                        
                                                        // unit
                                                        if let unit = measurement["unit"] as? [String: Any] {
                                                            var measurementUnit = WebUnit()
                                                            
                                                            if let unitName = unit["name"] as? String {
                                                                measurementUnit.name = unitName
                                                            }
                                                            if let abbreviation = unit["abbreviation"] as? String {
                                                                measurementUnit.abbreviation = abbreviation
                                                            }
                                                            
                                                            ingredientMeasurement.unit = measurementUnit
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
                        self.setRecipeDetail(recipe)
                    }
                }
            }
            catch {
                print(error)
                self.recipeDetailError = true
            }
            
        }.resume()
    }
    
    // sets the detail of a recipe
    func setRecipeDetail(_ recipe: WebRecipe) {
        if isValid(recipe) {
            self.recipeDetail = recipe
            self.recipesStore[recipe.id] = recipe
        }
        else {
            print("error getting recipe with id \(recipe.id)")
        }
    }
    
    // recipe is valid
    func isValid(_ recipe: WebRecipe) -> Bool {
        if recipe.name != "", recipe.directions.count > 0, recipe.sections.count > 0,
           recipe.sections[0].ingredients.count > 0 {
            return true
        }
        return false
    }
    
//    func prettyPrinting(data: Data) {
//        if let object = try? JSONSerialization.jsonObject(with: data, options: []) {
//            if let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) {
//                let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
//                print(prettyPrintedString)
//            }
//        }
//    }
}

//extension NSNumber {
//    func toString() -> String? {
//        let formatter = NumberFormatter()
//        return formatter.string(from: self)
//    }
//}
