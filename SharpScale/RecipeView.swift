//
//  RecipeView.swift
//  SharpScale
//
//  Created by Jonathan Dow on 1/28/24.
//

import SwiftUI

struct RecipeView: View {
    @State private var recipes: [Recipe] = []
    let dbHelper = SQLiteHelper()
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: AddRecipeView()){
                    Text("Add A New Recipe")
                    
                }
                Section(header: Text("Recipes")) {
                    ForEach(recipes, id: \.id) { recipe in
                        NavigationLink(destination:RecipeDetailView(recipe: recipe)) {
                            Text(recipe.name)
                        }
                    }
                }
            }
            .onAppear {
                loadRecipes()
            }
            .navigationTitle("Manage Recipes")
        }
    }
    private func loadRecipes() {
        recipes = dbHelper.fetchAllRecipes()
    }
}

struct Recipe {
    let id: Int
    let name: String
    let ingredients: String
    let steps: String
}

#Preview {
    RecipeView()
}

struct RecipeDetailView: View {
    let dbHelper = SQLiteHelper()
    let recipe: Recipe
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(recipe.name)
                    .font(.title)
                Text("Ingredients: \(recipe.ingredients)")
                    .font(.headline)
                VStack(alignment: .leading) {
                    ForEach(nonEmptySteps, id: \.self) { index in
                        Text(index)
                    }
                }
                .font(.headline)
                
                Spacer()
            }
        }
        .padding()
        .navigationBarItems(trailing: Button("Delete") {
            deleteRecipe()
        })
    }
    
    private var stepsArray: [String] {
        recipe.steps.components(separatedBy: "\n")
    }
    
    private var nonEmptySteps: [String] {
        stepsArray.filter { !$0.isEmpty }.enumerated().map { index, step in
            "Step \(index + 1): \(step)"
        }
    }
    
    private func deleteRecipe() {
        if dbHelper.deleteRecipe(id: recipe.id) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct AddRecipeView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var recipeName = ""
    @State private var ingredients = ""
    @State private var steps = [String](repeating: "", count: 1)
    
    let dbHelper = SQLiteHelper()
    
    var body: some View {
        
        Form {
            Section {
                TextField("Recipe Name", text: $recipeName)
                TextField("Ingredients", text: $ingredients)
                ForEach(0..<steps.count, id: \.self) { index in
                    TextField("Step \(index + 1)", text: $steps[index])
                        .onChange(of: steps[index]) { newValue in
                            if index == steps.count - 1 && !newValue.isEmpty {
                                steps.append("")
                            }
                        }
                }
            }
            Section {
                Button("Add Recipe") {
                    addRecipe()
                }
            }
        }
        .navigationBarTitle("Add Recipe", displayMode: .inline)
    }
    private func addRecipe() {
        let stepsString = steps.joined(separator: "\n")
        _ = dbHelper.insertRecipe(name: recipeName, ingredients: ingredients, steps: stepsString)
        presentationMode.wrappedValue.dismiss()
    }
}

struct DeleteRecipeView: View {
    var body: some View {
        Text("Delete Recipe")
    }
}
