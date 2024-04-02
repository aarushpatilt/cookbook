//
//  ApiCalls.swift
//  cookbook
//
//  Created by Aarush Patil on 3/31/24.
//

import Foundation


// use case: once data is called, converted and organized using this structure
struct MealsResponse: Decodable {
    let meals: [Meal]
}

// Define a struct to represent a single meal
struct Meal: Decodable {
    let strMeal: String
    let strMealThumb: String
    let idMeal: String
}

struct MealDescriptionWrapper: Decodable {
    let meals: [MealDescription]
}

struct MealDescription: Decodable {
    let idMeal: String?
    let strMeal: String?
    let strDrinkAlternate: String?
    let strCategory: String?
    let strArea: String?
    let strInstructions: String?
    let strMealThumb: String?
    let strTags: String?
    let strYoutube: String?
    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    let strIngredient6: String?
    let strIngredient7: String?
    let strIngredient8: String?
    let strIngredient9: String?
    let strIngredient10: String?
    let strIngredient11: String?
    let strIngredient12: String?
    let strIngredient13: String?
    let strIngredient14: String?
    let strIngredient15: String?
    let strIngredient16: String?
    let strIngredient17: String?
    let strIngredient18: String?
    let strIngredient19: String?
    let strIngredient20: String?
    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    let strMeasure6: String?
    let strMeasure7: String?
    let strMeasure8: String?
    let strMeasure9: String?
    let strMeasure10: String?
    let strMeasure11: String?
    let strMeasure12: String?
    let strMeasure13: String?
    let strMeasure14: String?
    let strMeasure15: String?
    let strMeasure16: String?
    let strMeasure17: String?
    let strMeasure18: String?
    let strMeasure19: String?
    let strMeasure20: String?
    let strSource: String?
    let strImageSource: String?
    let strCreativeCommonsConfirmed: String?
    let dateModified: String?
}


// api call struct, all the data calling is processed through this
struct APIService {
    
    // fetch data (String: url, struct: Food?, error: Error?) (optional)
    // retuns list of meals (struct)
    func fetchDataMeals<T: Decodable>(urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        // Unwrap URL, if error persists then notify
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        // Fetch the data
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // If there is an error, no completion and return error
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Set data
            guard let responseData = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            // Try to decode data
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: responseData)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    
    // generic function call another way to call json data 
    func fetchData<T: Decodable>(urlString: String, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        // unwrap url, if error persists then notify
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        // fetch the data
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            //if there is an error, no completion and return error
            if let error = error {
                completion(.failure(error))
                return
            }
            // set data
            guard let responseData = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            // try to decode data
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: responseData)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }


}
