//
//  RecipeSearchApiHandler.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/4/21.
//

import Foundation

// search recipes with spoonacular api
class RecipeSearchHandler: ObservableObject {
    @Published var recipeList = [Recipe]()
    @Published var recipeDetail: Recipe?
    @Published var recipeDetailError = false
    @Published var recipesStore = [Int: Recipe]()
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
        urlComponents.host = "api.spoonacular.com"
        urlComponents.path = "/recipes/complexSearch"
        var queryItems = [
            URLQueryItem(name: "offset", value: recipeListIndex.toString()),
            URLQueryItem(name: "number", value: requestPageSize.toString()),
            URLQueryItem(name: "apiKey", value: Keys.spoonacularApi)
        ]
        
        if query != "" {
            queryItems.append(URLQueryItem(name: "query", value: query))
        }
        
        self.recipeListIndex += self.requestPageSize
        
        urlComponents.queryItems = queryItems
        
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        
        var recipes = [Recipe]()
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                guard let data = data else {
                    print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                    return
                }
                
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let count = jsonObject["totalResults"] as? Int {
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
                                let name = recipe["title"] as? String
                                let id = recipe["id"] as? Int
                                if let recipeId = id, let recipeName = name {
                                    recipes.append(Recipe(detailId: recipeId, name: recipeName))
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
    func setRecipeList(_ recipeList: [Recipe]) {
        var updatedList = self.recipeList
        updatedList.append(contentsOf: recipeList)
        self.recipeList = updatedList
        listingRecipes = false
    }
    
    func reset() {
        self.recipeDetail = nil
        self.recipeDetailError = false
    }
    
    // lists detail for a recipe (gets the parts of the recipe)
    // very deep api result caused a very deep function
    func listRecipeDetail(_ recipe: Recipe) {
        var recipe = recipe
        recipeDetailError = false
        if recipe.detailId == nil {
            return
        }
        if self.recipesStore[recipe.detailId!] != nil {
            self.recipeDetail = self.recipesStore[recipe.detailId!] 
            return
        }
        let idString = recipe.detailId!.toString()
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.spoonacular.com"
        urlComponents.path = "/recipes/\(idString)/information"
        let queryItems = [
            URLQueryItem(name: "apiKey", value: Keys.spoonacularApi)
        ]
        
        urlComponents.queryItems = queryItems
        
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var request = URLRequest(url: urlComponents.url!)
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
                
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // name
                    if let name = jsonObject["title"] as? String {
                        recipe.name = name
                    }
                    
                    if let imageURL = jsonObject["image"] as? String {
                        var images = [RecipeImage]()
                        if imageURL != "" {
                            images.append(RecipeImage(type: ImageType.url, data: imageURL, recipeId: Recipe.defaultId))
                        }
                        recipe.images = images
                    }
                    
                    // instructions, TODO they do have analyzed instructions for future improvement
                    if let instructions = jsonObject["instructions"] as? String {
                        let cleanedInstructions = HTMLTranscriber.cleanHtmlTags(fromHtml: instructions, returnTitle: false)
                        let recipeInstructions = cleanedInstructions.components(separatedBy: "\n")
                        recipe.directions = Direction.toDirections(directionStrings: recipeInstructions, withRecipeId: Recipe.defaultId)
                    }
                    
                    // servings
                    if let servings = jsonObject["servings"] as? Int, servings > 0 {
                        recipe.servings = servings
                    }
                    
                    if let recipeSource = jsonObject["sourceUrl"] as? String {
                        recipe.source = recipeSource
                    }

                    if let ingredients = jsonObject["extendedIngredients"] as? [Any] {
                        var recipeIngredients = [Ingredient]()

                        for ingredient in ingredients {
                            if let ingredient = ingredient as? [String: Any] {
                                let id = recipeIngredients.count
                                var amount = 1.0
                                var unitName =  ""
                                var name = ""
                                
                                // name
                                if let ingredientName = ingredient["name"] as? String {
                                    name = ingredientName
                                }
                                
                                if let measures = ingredient["measures"] as? [String: Any] {
                                    if let measurement = measures["us"] as? [String: Any] {
                                                    
                                        // ingredientAmount
                                        if let ingredientAmount = measurement["amount"] as? Double {
                                            amount = ingredientAmount
                                        }
                                            
                                        if let ingredientUnitName = measurement["unitLong"] as? String {
                                            unitName = ingredientUnitName
                                        }
                                    }
                                }
                                let recipeIngredient = Ingredient(id: id.toString(), name: name, amount: amount, unitName: Ingredient.makeUnit(fromUnit: unitName))
                                recipeIngredients.append(recipeIngredient)
                            }
                        }
                        recipe.ingredients = recipeIngredients
                    }
                        
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
    func setRecipeDetail(_ recipe: Recipe) {
        if isValid(recipe) && recipe.detailId != nil {
            self.recipeDetail = recipe
            self.recipesStore[recipe.detailId!] = recipe
        }
        else {
            print("error getting recipe with id \(String(describing: recipe.detailId))")
            self.recipeDetailError = true
        }
    }
    
    // recipe is valid
    func isValid(_ recipe: Recipe) -> Bool {
        if recipe.name == "", recipe.directions.count == 0, recipe.ingredients.count == 0 {
            return false
        }
        return true
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

extension NSNumber {
    func toString() -> String? {
        let formatter = NumberFormatter()
        return formatter.string(from: self)
    }
}
