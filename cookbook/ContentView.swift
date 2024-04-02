//
//  ContentView.swift
//  cookbook
//
//  Created by Aarush Patil on 3/31/24.
//

import SwiftUI

struct ContentView: View {
    // set to state because we load the data with ui first time
    @State private var meals: [Meal] = []
    @State private var errorMessage: String?
    @State private var isLoading: Bool = true
    
    func fetchMeals() {
        
        let apiService = APIService()
        let urlString = "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert"
        
        apiService.fetchDataMeals(urlString: urlString) { (result: Result<MealsResponse, Error>) in
            switch result {
            case .success(let mealsResponse):
                self.meals = mealsResponse.meals
                print(self.meals)
                
            case .failure(let error):
                errorMessage = "Error fetching data: \(error.localizedDescription)"
            }
            
            isLoading = false // Set isLoading to false when data fetching is complete
        }

    }
    
    
    var body: some View {
        VStack(alignment: .leading){
            // Row contains pfp and title
            HStack{
                Circle()
                    .fill(Color(red: 0.5, green: 0, blue: 0))
                    .frame(width: 25, height: 25)
                Text("Cookbook")
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .font(.system(size: 25))
                Spacer()
                
            }
            if isLoading {
                ProgressView()
            } else {
                // scroll
                NavigationView {
                    ScrollView{
                        // vertical
                        VStack(alignment: .leading){
                            // meals not empty
                            if !meals.isEmpty {
                                ForEach(meals, id: \.idMeal) { meal in
                                    // iteration
                                    MealView(meal: meal)
                                        .padding(.bottom, 10) // Add spacing between MealViews
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            fetchMeals()
        }
        .background(Color.white.opacity(0.3))
    }
    
    
}

struct MealView: View {
    let meal: Meal

    var body: some View {
        
        NavigationLink(destination: DestinationView(mealID: meal.idMeal)) {
            VStack(alignment: .leading) {
                AsyncImage(url: URL(string: meal.strMealThumb)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(5)
                    case .failure(let error):
                        Text("Failed to load image: \(error.localizedDescription)")
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                Spacer().frame(height: 15)
                Text(meal.strMeal.uppercased())
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .font(.system(size: 20))
                Spacer().frame(height: 5)
                Text(meal.idMeal.uppercased())
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .font(.system(size: 10))
            }
        }
    }
}

struct DestinationView: View {
    
    @State private var isLoading: Bool = true
    @State private var mealDes: [String: String] = [:]
    @State private var InandMes: [IngredientMeasurement] = []
    
    let mealID: String
    
    struct IngredientMeasurement {
        let ingredient: String
        let measurement: String
    }

    func parseTogether(from dictionary: [String: String]) -> [IngredientMeasurement] {
        var result: [IngredientMeasurement] = []

        for i in 1...20 { // Assuming there are up to 20 ingredients
            guard let ingredient = dictionary["strIngredient\(i)"],
                  !ingredient.isEmpty,
                  let measurement = dictionary["strMeasure\(i)"],
                  !measurement.isEmpty else { continue }
            
            let pair = IngredientMeasurement(ingredient: ingredient, measurement: measurement)
            result.append(pair)
        }

        return result
    }
    func filterMealDescription(_ meal: MealDescription?) -> [String: String] {
        guard let meal = meal else { return [:] }

        var filteredProperties = [String: String]()

        let mirror = Mirror(reflecting: meal)
        for child in mirror.children {
            if let propertyName = child.label,
               let propertyValue = child.value as? String, !(propertyValue == " ") , !propertyValue.isEmpty {
                filteredProperties[propertyName] = propertyValue
            }
        }

        return filteredProperties
    }

    func fetchMeals() {
        
        let apiService = APIService()
        let urlString = "https://themealdb.com/api/json/v1/1/lookup.php?i="+String(mealID)
        print(urlString)
        
        // Call fetchData function with MealDescription struct
        apiService.fetchData(urlString: urlString, responseType: MealDescriptionWrapper.self) { result in
            switch result {
            case .success(let mealDescriptionWrapper):
                let mealDescription = mealDescriptionWrapper.meals.first
                
                // Use the filter function here
                let filteredMealDescription = filterMealDescription(mealDescription)
                mealDes = filteredMealDescription
                // Setting both the Ingredient and Measurements together
                InandMes = parseTogether(from: mealDes)
                print(mealDes)
                
                isLoading = false
                
            case .failure(let error):
                // Handle failure
                print("Error fetching meal data: \(error)")
                isLoading = false
            }
        }
    }

    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) { // Set alignment to .leading
                if isLoading {
                    ProgressView()
                } else {
                    VStack(alignment: .leading) {
                        AsyncImage(url: URL(string: mealDes["strMealThumb"] ?? " ")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(5)
                            case .failure(let error):
                                Text("Failed to load image: \(error.localizedDescription)")
                            case .empty:
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                            Spacer().frame(height: 15)
                            HStack {
                                Text(mealDes["strMeal"] ?? " ")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                .font(.system(size: 20))
                                Spacer()
                            }
                            Spacer().frame(height: 15)
                            ForEach(InandMes, id: \.ingredient) { item in
                                HStack {
                                    Text(item.ingredient)
                                    Spacer()
                                    Text(item.measurement)
                                }
                                .padding(.horizontal)
                            }
                            Spacer().frame(height: 15)
                            Text(mealDes["strInstructions"] ?? " ")
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .font(.system(size: 15))
                        }
                    }
                }
            }
            .onAppear() {
                fetchMeals()
            }
            .navigationBarBackButtonHidden(false)
        }
    }


}

#Preview {
    ContentView()
}
