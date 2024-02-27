//
//  IngredientView.swift
//  SharpScale
//
//  Created by Jonathan Dow on 1/28/24.
//

import SwiftUI

struct IngredientView: View {
//    private let logger = Logger(subsystem: "com.sharpscale", category: "IngredientView")
    @State private var ingredients: [Ingredient] = []
    let dbHelper = SQLiteHelper()
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: AddIngredientView()){
                    Text("Add A New Ingredient")
                }
                Section(header: Text("Ingredients")) {
                    ForEach(ingredients, id: \.id) { ingredient in
                        
                        NavigationLink(destination: IngredientDetailView(ingredient: ingredient)){
                            Text(ingredient.name)
                        }
                    }
                }
            }
            .onAppear {
                loadIngredients()
            }
            .navigationTitle("Manage Ingredients")
        }
    }
    private func loadIngredients() {
        ingredients = dbHelper.fetchAllIngredients()
    }
}

struct Ingredient {
    let id: Int
    let name: String
    let density: Double
}

#Preview {
    IngredientView()
}

struct AddIngredientView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var ingredientName = ""
    @State private var density = ""
    
    let dbHelper = SQLiteHelper()
    
    var body: some View {
        Form {
            Section {
                TextField("Ingredient Name", text: $ingredientName)
                TextField("Ingredient Density", text: $density)
            }
            Section {
                Button("Add Ingredient") {
                    addIngredient()
                }
            }
        }
        .navigationBarTitle("Add Ingredient", displayMode: .inline)
    }
    private func addIngredient() {
        if let densityVal = Double(density){
            _ = dbHelper.insertIngredient(name: ingredientName, density: densityVal)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct IngredientDetailView: View {
    let dbHelper = SQLiteHelper()
    let ingredient: Ingredient
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(ingredient.name)
                .font(.title)
            Text("Density: \(String(format: "%.3f", ingredient.density))")
                .font(.headline)
            
            Spacer()
        }
        .padding()
        .navigationBarItems(trailing: Button("Delete") {
            deleteIngredient()
        })
    }
    private func deleteIngredient() {
        if dbHelper.deleteIngredient(id: ingredient.id) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct DeleteIngredientView: View {
    var body: some View {
        Text("Delete Ingredient")
    }
}
